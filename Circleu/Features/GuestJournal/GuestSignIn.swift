import Combine
import SwiftUI

/// Builds the account service and cloud reader only when Log in is used, so the guest journal
/// starts without Firebase.
struct GuestAccountFactory {
    var make: @MainActor () -> (account: any GuestAccountService, reader: any GuestCloudBackupReading)

    static var live: GuestAccountFactory {
        GuestAccountFactory {
            #if DEBUG
            if UserDefaults.standard.bool(forKey: "CircleUFakeAccount") { return (FakeAccounts.account, FakeAccounts.reader) }
            #endif
            return (LiveGuestAccountService(), LiveGuestCloudBackupReader())
        }
    }
}

#if DEBUG
/// One shared fake per launch, so deleting the account is remembered across screens.
@MainActor
enum FakeAccounts {
    static let account = FakeGuestAccountService()
    static let reader = FakeGuestCloudBackupReader()
}
#endif

/// One account operation at a time across screens (log in and copy, or delete), so one can never
/// act on the session another started.
@MainActor
enum GuestAccountGate {
    private(set) static var isBusy = false
    static let busyMessage = "Another account action is still running. Try again in a moment."

    static func enter() -> Bool {
        guard !isBusy else { return false }
        isBusy = true
        return true
    }

    static func leave() { isBusy = false }

    #if DEBUG
    static func resetForTesting() { isBusy = false }
    #endif
}

enum GuestAccountMessages {
    static func text(for error: Error) -> String {
        switch error as? GuestAccountError {
        case .couldNotLogIn?: "Check your email and password. Your entries are unchanged."
        case .offline?: "You’re offline. Logging in needs a connection; your journal still works."
        case .tooManyAttempts?: "Too many tries. Wait a moment, then try again."
        case .unavailable?: "Logging in isn’t available in this version."
        case .needsRecentLogIn?: "Please log in again, then try once more."
        default: "Something went wrong. Your entries are unchanged. Try again."
        }
    }
}

// MARK: - Log in and bring in the cloud backup

/// Log in → preview the account's cloud backup → copy it in → signed out automatically.
@MainActor
final class GuestSignInViewModel: ObservableObject {
    enum Step: Equatable {
        case form
        case working
        case preview(GuestCloudBackup, alreadyCopied: Int)
        case done(added: Int, skipped: [GuestLegacyScan.Skip], isProtected: Bool, signedOut: Bool)
    }

    @Published var email = ""
    @Published var password = ""
    @Published private(set) var step: Step = .form
    @Published private(set) var message: String?
    /// After repeated failures, Log in waits before it can be tried again.
    @Published private(set) var retryAfter: Date?

    static let lockedMessage = "Too many tries. Wait a moment, then try again."

    private let factory: GuestAccountFactory
    private let store: any GuestImportStore
    private let journal: GuestJournalViewModel
    private let practice: GuestPracticeViewModel
    private var services: (account: any GuestAccountService, reader: any GuestCloudBackupReading)?
    private var failures = 0
    private var holdsGate = false

    private func releaseGate() {
        if holdsGate { GuestAccountGate.leave() }
        holdsGate = false
    }
    /// Results from an earlier request (cancelled, or replaced) are ignored.
    private var request = 0
    private let now: () -> Date

    init(factory: GuestAccountFactory, store: any GuestImportStore, journal: GuestJournalViewModel,
         practice: GuestPracticeViewModel, now: @escaping () -> Date = Date.init) {
        self.factory = factory
        self.store = store
        self.journal = journal
        self.practice = practice
        self.now = now
    }

    var canLogIn: Bool {
        step == .form && !email.trimmingCharacters(in: .whitespaces).isEmpty && !password.isEmpty
    }

    private func account() -> (account: any GuestAccountService, reader: any GuestCloudBackupReading) {
        if let services { return services }
        let made = factory.make()
        services = made
        return made
    }

    func logIn() async {
        guard canLogIn else { return }
        if let retryAfter, retryAfter > now() {
            message = Self.lockedMessage
            return
        }
        let (account, reader) = account()
        guard account.isAvailable else {
            message = GuestAccountMessages.text(for: GuestAccountError.unavailable)
            return
        }
        guard holdsGate || GuestAccountGate.enter() else {
            message = GuestAccountGate.busyMessage
            return
        }
        holdsGate = true
        request += 1
        let current = request
        inFlight = true
        defer { inFlight = false }
        message = nil
        step = .working
        do {
            try account.discardEarlierSession() // A leftover session is never trusted.
            let session = try await account.logIn(email: email.trimmingCharacters(in: .whitespaces), password: password)
            password = ""
            // Cancelled or replaced while logging in: undo the late log in, read nothing.
            guard current == request else { settleCancelled(account); return }
            let backup = try await reader.readBackup(uid: session.uid, project: session.project)
            guard current == request else { settleCancelled(account); return }
            var already = 0
            var fresh = GuestCloudBackup(skipped: backup.skipped)
            for entry in backup.entries {
                if try await store.isImported(entry.legacyID) { already += 1 } else { fresh.entries.append(entry) }
            }
            for message in backup.messages {
                if try await store.isImported(message.legacyID) { already += 1 } else { fresh.messages.append(message) }
            }
            guard current == request else { settleCancelled(account); return }
            failures = 0
            retryAfter = nil
            step = .preview(fresh, alreadyCopied: already)
        } catch {
            guard current == request else { settleCancelled(account); return }
            let signedOut = account.signOut()
            releaseGate()
            password = ""
            if case GuestAccountError.couldNotLogIn = error {
                failures += 1
                if failures >= 3 { // Back off: 30 s, 60 s, … up to 5 minutes.
                    retryAfter = now().addingTimeInterval(min(300, 30 * pow(2, Double(failures - 3))))
                }
            }
            message = GuestAccountMessages.text(for: error)
            noteSignOut(signedOut) // Added after, so it isn't overwritten.
            step = .form
        }
    }

    var canCopy: Bool {
        if case .preview(let backup, _) = step { return !backup.entries.isEmpty || !backup.messages.isEmpty }
        return false
    }

    /// Copies, then signs out whatever happens.
    func copy() async {
        guard case .preview(let backup, _) = step, canCopy else { return }
        step = .working
        do {
            let result = try await store.importLegacy(entries: backup.entries, messages: backup.messages)
            let signedOut = services?.account.signOut() ?? true
            releaseGate()
            await journal.load()
            await practice.load()
            step = .done(added: result.added, skipped: backup.skipped, isProtected: result.isProtected, signedOut: signedOut)
        } catch {
            let signedOut = services?.account.signOut() ?? true
            releaseGate()
            message = GuestImportViewModel.failedMessage
            noteSignOut(signedOut)
            step = .form
        }
    }

    /// Leaving without copying signs out too. A log in still in progress keeps the gate until it
    /// settles, so no other account action can start under it.
    func cancel() {
        request += 1
        password = ""
        if inFlight {
            pendingCancel = true // The pending work signs out and lets go when it settles.
        } else {
            if let account = services?.account { noteSignOut(account.signOut()) }
            releaseGate()
        }
        if step != .form, !isDone { step = .form }
    }

    private var pendingCancel = false
    private var inFlight = false

    private func settleCancelled(_ account: any GuestAccountService) {
        noteSignOut(account.signOut())
        pendingCancel = false
        releaseGate()
    }

    static let signOutUnfinishedMessage = "Signing out didn’t finish. Close and reopen CircleU; nothing syncs either way."

    private func noteSignOut(_ succeeded: Bool) {
        guard !succeeded else { return }
        message = [message, Self.signOutUnfinishedMessage].compactMap { $0 }.joined(separator: " ")
    }

    private var isDone: Bool { if case .done = step { true } else { false } }
}

struct GuestSignInView: View {
    @StateObject private var model: GuestSignInViewModel
    let onSkip: (() -> Void)?
    let factory: GuestAccountFactory

    init(factory: GuestAccountFactory, store: any GuestImportStore, journal: GuestJournalViewModel,
         practice: GuestPracticeViewModel, onSkip: (() -> Void)? = nil) {
        _model = StateObject(wrappedValue: GuestSignInViewModel(factory: factory, store: store, journal: journal,
                                                                practice: practice))
        self.factory = factory
        self.onSkip = onSkip
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                switch model.step {
                case .form, .working: form
                case .preview(let backup, let already): preview(backup, already: already)
                case .done(let added, let skipped, let isProtected, let signedOut): done(added, skipped, isProtected, signedOut)
                }
            }
            .padding(24)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(GuestBrand.ice.ignoresSafeArea())
        .navigationTitle("Log in")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { model.cancel() } // Never stays signed in.
    }

    private var form: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Bring in your earlier journal").font(GuestBrand.font(.title2, .bold))
                .foregroundStyle(GuestBrand.ink).accessibilityAddTraits(.isHeader)
            GuestSummary("Nothing new is uploaded, and you’re signed out after.")
            labelled("Email") {
                TextField("Email", text: $model.email)
                    .textContentType(.username).keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never).autocorrectionDisabled()
            }
            labelled("Password") {
                SecureField("Password", text: $model.password).textContentType(.password)
            }
            if let message = model.message {
                Label(message, systemImage: "exclamationmark.circle")
                    .font(GuestBrand.font(.subheadline)).foregroundStyle(GuestBrand.ink)
            }
            Button(model.step == .working ? "Logging in…" : "Log in") { Task { await model.logIn() } }
                .buttonStyle(GuestBrandButtonStyle())
                .disabled(!model.canLogIn)
            NavigationLink { GuestPasswordResetView(factory: factory) } label: {
                Text("Forgot password?").frame(minWidth: 44, minHeight: 44).contentShape(Rectangle())
            }
            .font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(GuestBrand.blue)
            if let onSkip {
                Button("Continue without logging in", action: onSkip)
                    .buttonStyle(GuestBrandButtonStyle(filled: false))
            }
            GuestLearnMore {
                Text("Logging in only fetches your account’s backup so you can copy it here.")
                Text("Accounts can’t be created here.")
                // copy: detail
                Text("A journal the earlier app kept only on this iPhone stays sealed, because it can’t be shown to be yours.")
            }
        }
        .disabled(model.step == .working)
    }

    @ViewBuilder private func preview(_ backup: GuestCloudBackup, already: Int) -> some View {
        Text("Your account’s backup").font(GuestBrand.font(.title2, .bold)).foregroundStyle(GuestBrand.ink)
            .accessibilityAddTraits(.isHeader)
        GuestSummary("\(backup.entries.count + backup.messages.count) to copy" + (already > 0 ? " · \(already) already copied" : ""))
        ForEach(Array(backup.entries.prefix(3).enumerated()), id: \.offset) { _, entry in
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.originalWords).lineLimit(2).foregroundStyle(GuestBrand.ink)
                Text(entry.createdAt, format: .dateTime.day().month().year())
                    .font(GuestBrand.font(.caption)).foregroundStyle(GuestBrand.muted)
            }
            .padding(12).frame(maxWidth: .infinity, alignment: .leading)
            .background(.white, in: RoundedRectangle(cornerRadius: 14))
        }
        if model.canCopy {
            Button("Copy into this journal") { Task { await model.copy() } }
                .buttonStyle(GuestBrandButtonStyle())
        }
        Button("Don’t copy") { model.cancel() }
            .buttonStyle(GuestBrandButtonStyle(filled: false))
        GuestLearnMore {
            Text("Your account’s backup isn’t changed.")
            Text("Titles, tags, quests, coaching and images aren’t copied.")
            GuestImportView.leftOut(backup.skipped)
        }
    }

    @ViewBuilder private func done(_ added: Int, _ skipped: [GuestLegacyScan.Skip], _ isProtected: Bool,
                                   _ signedOut: Bool) -> some View {
        GuestSuccessBanner(text: added == 0 ? "Nothing new to copy." : "Copied \(added) \(added == 1 ? "item" : "items") into your journal.",
                           asset: "GuestPinguReading")
        if !isProtected {
            Label(GuestJournalViewModel.savedButUnprotectedMessage, systemImage: "exclamationmark.shield")
                .font(GuestBrand.font(.subheadline)).foregroundStyle(GuestBrand.ink)
        }
        GuestSummary(signedOut ? "You’re signed out." : "Signing out didn’t finish. Close and reopen CircleU.")
        if !skipped.isEmpty {
            GuestLearnMore(title: "Left out (\(skipped.count))") { GuestImportView.leftOut(skipped) }
        }
        if let onSkip {
            Button("Continue", action: onSkip).buttonStyle(GuestBrandButtonStyle())
        }
    }

    private func labelled<Content: View>(_ title: String, @ViewBuilder _ field: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(GuestBrand.muted)
            field().padding(12).background(.white, in: RoundedRectangle(cornerRadius: 14))
        }
    }
}

// MARK: - Password reset

struct GuestPasswordResetView: View {
    let factory: GuestAccountFactory
    @State private var email = ""
    @State private var sent = false
    @State private var message: String?
    @State private var working = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if sent {
                    Text("Check your email").font(GuestBrand.font(.title2, .bold)).foregroundStyle(GuestBrand.ink)
                        .accessibilityAddTraits(.isHeader)
                    GuestSummary("If an account uses this email, a link is on its way.")
                } else {
                    GuestSummary("We’ll email you a reset link.")
                    TextField("Email", text: $email)
                        .textContentType(.username).keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never).autocorrectionDisabled()
                        .padding(12).background(.white, in: RoundedRectangle(cornerRadius: 14))
                    if let message {
                        Label(message, systemImage: "exclamationmark.circle").font(GuestBrand.font(.subheadline))
                    }
                    Button(working ? "Sending…" : "Send reset link") { Task { await send() } }
                        .buttonStyle(GuestBrandButtonStyle())
                        .disabled(working || email.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .padding(24)
        }
        .background(GuestBrand.ice.ignoresSafeArea())
        .navigationTitle("Reset password")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func send() async {
        working = true
        defer { working = false }
        let account = factory.make().account
        do {
            try await account.sendPasswordReset(email: email.trimmingCharacters(in: .whitespaces))
            sent = true
        } catch {
            message = GuestAccountMessages.text(for: error)
        }
    }
}

// MARK: - Delete my account

/// Deletes the earlier account and its cloud backup after a fresh log in. Entries on this iPhone
/// stay. Nothing is reported as deleted unless it was.
@MainActor
final class GuestDeleteAccountViewModel: ObservableObject {
    enum Step: Equatable { case form, working, done(keptCircles: Int) }

    @Published var email = ""
    @Published var password = ""
    @Published private(set) var step: Step = .form
    @Published private(set) var message: String?

    static let backupNotDeletedMessage = "Couldn’t delete your cloud data, so the account wasn’t deleted. Try again."
    static let accountNotDeletedMessage = "Your cloud content was deleted, but the account itself couldn’t be. Try again."

    private let factory: GuestAccountFactory

    init(factory: GuestAccountFactory) { self.factory = factory }

    var canDelete: Bool { step == .form && !email.trimmingCharacters(in: .whitespaces).isEmpty && !password.isEmpty }

    func delete() async {
        guard canDelete else { return }
        let (account, reader) = factory.make()
        guard account.isAvailable else {
            message = GuestAccountMessages.text(for: GuestAccountError.unavailable)
            return
        }
        guard GuestAccountGate.enter() else {
            message = GuestAccountGate.busyMessage
            return
        }
        step = .working
        message = nil
        defer {
            if !account.signOut() {
                message = [message, GuestSignInViewModel.signOutUnfinishedMessage].compactMap { $0 }.joined(separator: " ")
            }
            GuestAccountGate.leave()
            password = ""
        }
        let uid: String
        var keptCircles = 0
        do {
            try account.discardEarlierSession()
            uid = try await account.logIn(email: email.trimmingCharacters(in: .whitespaces), password: password).uid // Fresh log in.
        } catch {
            message = GuestAccountMessages.text(for: error)
            step = .form
            return
        }
        do {
            keptCircles = try await reader.deleteOwnedContent(uid: uid)
        } catch {
            message = Self.backupNotDeletedMessage
            step = .form
            return
        }
        do {
            try await account.deleteAccount(uid: uid) // Only the account just logged in to.
        } catch {
            message = Self.accountNotDeletedMessage
            step = .form
            return
        }
        step = .done(keptCircles: keptCircles)
    }
}

struct GuestDeleteAccountView: View {
    @StateObject private var model: GuestDeleteAccountViewModel
    @State private var confirm = false

    init(factory: GuestAccountFactory) {
        _model = StateObject(wrappedValue: GuestDeleteAccountViewModel(factory: factory))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if case .done(let kept) = model.step {
                    GuestSuccessBanner(text: "Your earlier account and its cloud content were deleted.", asset: "GuestPinguWelcome")
                    GuestSummary("Your entries on this iPhone are still here.")
                    if kept > 0 {
                        GuestSummary("\(kept) \(kept == 1 ? "circle" : "circles") kept for other people’s posts.")
                    }
                } else {
                    GuestSummary("Deletes your earlier account, backup, posts and memberships. Entries here stay.")
                    GuestLearnMore {
                        Text("Your backup, posts and circle memberships are deleted.")
                        // copy: detail
                        Text("Circles you made stay if others posted in them. Replies and likes on others’ posts can’t be removed here.")
                    }
                    TextField("Email", text: $model.email)
                        .textContentType(.username).keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never).autocorrectionDisabled()
                        .padding(12).background(.white, in: RoundedRectangle(cornerRadius: 14))
                    SecureField("Password", text: $model.password).textContentType(.password)
                        .padding(12).background(.white, in: RoundedRectangle(cornerRadius: 14))
                    if let message = model.message {
                        Label(message, systemImage: "exclamationmark.circle")
                            .font(GuestBrand.font(.subheadline)).foregroundStyle(GuestBrand.ink)
                    }
                    Button(role: .destructive) { confirm = true } label: {
                        Text(model.step == .working ? "Deleting…" : "Delete my account")
                            .frame(maxWidth: .infinity, minHeight: 44).contentShape(Rectangle())
                    }
                    .font(GuestBrand.font(.headline, .semibold)).foregroundStyle(GuestBrand.danger)
                    .disabled(!model.canDelete)
                }
            }
            .padding(24)
        }
        .background(GuestBrand.ice.ignoresSafeArea())
        .navigationTitle("Delete my account")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(model.step == .working) // Can't leave while it's deleting.
        .alert("Delete your earlier account?", isPresented: $confirm) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) { Task { await model.delete() } }
        } message: {
            Text("The account and its cloud backup are deleted for good. Your entries on this iPhone stay.")
        }
    }
}
