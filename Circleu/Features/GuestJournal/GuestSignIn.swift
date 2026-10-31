import Combine
import SwiftUI
import UIKit

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
    @Environment(\.dynamicTypeSize) private var typeSize

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
        .toolbar { ToolbarItem(placement: .primaryAction) { info } }
        .onDisappear { model.cancel() } // Never stays signed in.
    }

    /// The detail that used to sit behind Learn more, one tap away on each step.
    @ViewBuilder private var info: some View {
        switch model.step {
        case .form, .working:
            GuestInfoButton(label: "What logging in does") {
                Text("Logging in only fetches your account’s backup so you can copy it here.")
                Text("Accounts can’t be created here.")
                // copy: detail
                Text("A journal the earlier app kept only on this iPhone stays sealed, because it can’t be shown to be yours.")
            }
        case .preview:
            GuestInfoButton(label: "What isn’t copied") {
                Text("Your account’s backup isn’t changed.")
                Text("Titles, tags, quests, coaching and images aren’t copied.")
            }
        case .done:
            EmptyView()
        }
    }

    private var form: some View {
        VStack(alignment: .leading, spacing: 14) {
            if !typeSize.isAccessibilitySize {
                GuestScene(.keepsakeShelf).clipShape(RoundedRectangle(cornerRadius: 24))
            }
            Text("Bring in your earlier journal").font(GuestBrand.font(.title2, .bold))
                .foregroundStyle(GuestBrand.ink).accessibilityAddTraits(.isHeader)
            GuestChipRow {
                GuestChip(text: "Nothing uploaded", systemImage: "icloud.slash")
                GuestChip(text: "Signed out after", systemImage: "rectangle.portrait.and.arrow.right")
            }
            TextField("Email", text: $model.email)
                .textContentType(.username).keyboardType(.emailAddress)
                .textInputAutocapitalization(.never).autocorrectionDisabled()
                .guestField()
            SecureField("Password", text: $model.password).textContentType(.password)
                .guestField()
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
        }
        .disabled(model.step == .working)
    }

    @ViewBuilder private func preview(_ backup: GuestCloudBackup, already: Int) -> some View {
        Text("Your account’s backup").font(GuestBrand.font(.title2, .bold)).foregroundStyle(GuestBrand.ink)
            .accessibilityAddTraits(.isHeader)
        GuestChipRow {
            GuestChip(text: "\(backup.entries.count + backup.messages.count) to copy", systemImage: "square.and.arrow.down")
            if already > 0 { GuestChip(text: "\(already) already copied", systemImage: "checkmark", muted: true) }
        }
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
        if !backup.skipped.isEmpty {
            GuestLearnMore(title: "Left out (\(backup.skipped.count))") { GuestImportView.leftOut(backup.skipped, heading: false) }
        }
        Button("Don’t copy") { model.cancel() }
            .buttonStyle(GuestBrandButtonStyle(filled: false))
    }

    @ViewBuilder private func done(_ added: Int, _ skipped: [GuestLegacyScan.Skip], _ isProtected: Bool,
                                   _ signedOut: Bool) -> some View {
        let title = added == 0 ? "Nothing new to copy" : "Copied \(added) \(added == 1 ? "item" : "items")"
        VStack(spacing: 12) {
            GuestPinguDecoration(asset: "GuestPinguReading", height: 160)
            Text(title).font(GuestBrand.font(.title2, .bold)).foregroundStyle(GuestBrand.ink)
                .multilineTextAlignment(.center).accessibilityAddTraits(.isHeader)
            if signedOut {
                GuestChip(text: "Signed out", systemImage: "rectangle.portrait.and.arrow.right")
            }
        }
        .frame(maxWidth: .infinity)
        .onAppear { UIAccessibility.post(notification: .announcement, argument: title) }
        if !signedOut {
            Label("Signing out didn’t finish. Close and reopen CircleU.", systemImage: "exclamationmark.circle")
                .font(GuestBrand.font(.subheadline)).foregroundStyle(GuestBrand.ink)
        }
        if !isProtected {
            Label(GuestJournalViewModel.savedButUnprotectedMessage, systemImage: "exclamationmark.shield")
                .font(GuestBrand.font(.subheadline)).foregroundStyle(GuestBrand.ink)
        }
        if !skipped.isEmpty {
            GuestLearnMore(title: "Left out (\(skipped.count))") { GuestImportView.leftOut(skipped, heading: false) }
        }
        if let onSkip {
            Button("Continue", action: onSkip).buttonStyle(GuestBrandButtonStyle())
        }
    }
}

// MARK: - Password reset

/// Sends a reset link. The same "on its way" answer shows whether or not an account uses the email.
@MainActor
final class GuestPasswordResetModel: ObservableObject {
    @Published var email = ""
    @Published private(set) var sent = false
    @Published private(set) var message: String?
    @Published private(set) var working = false
    private let factory: GuestAccountFactory

    init(factory: GuestAccountFactory) { self.factory = factory }

    var canSend: Bool { !working && !email.trimmingCharacters(in: .whitespaces).isEmpty }

    func send() async {
        guard canSend else { return }
        working = true
        message = nil
        defer { working = false }
        do {
            try await factory.make().account.sendPasswordReset(email: email.trimmingCharacters(in: .whitespaces))
            sent = true
        } catch {
            message = GuestAccountMessages.text(for: error)
        }
    }
}

struct GuestPasswordResetView: View {
    @StateObject private var model: GuestPasswordResetModel

    init(factory: GuestAccountFactory) {
        _model = StateObject(wrappedValue: GuestPasswordResetModel(factory: factory))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                GuestSymbolArt(systemImage: model.sent ? "envelope.badge" : "envelope")
                if model.sent {
                    Text("Check your email").font(GuestBrand.font(.title2, .bold)).foregroundStyle(GuestBrand.ink)
                        .frame(maxWidth: .infinity).accessibilityAddTraits(.isHeader)
                    // Same answer whether or not an account uses the email.
                    GuestSummary("If an account uses this email, a link is on its way.")
                        .multilineTextAlignment(.center).frame(maxWidth: .infinity)
                } else {
                    TextField("Email", text: $model.email)
                        .textContentType(.username).keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never).autocorrectionDisabled()
                        .guestField()
                    if let message = model.message {
                        Label(message, systemImage: "exclamationmark.circle").font(GuestBrand.font(.subheadline))
                    }
                    Button(model.working ? "Sending…" : "Send reset link") { Task { await model.send() } }
                        .buttonStyle(GuestBrandButtonStyle())
                        .disabled(!model.canSend)
                }
            }
            .padding(24)
        }
        .background(GuestBrand.ice.ignoresSafeArea())
        .navigationTitle("Reset password")
        .navigationBarTitleDisplayMode(.inline)
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
                    GuestPinguDecoration(asset: "GuestPinguThoughtful", height: 110)
                    ViewThatFits(in: .horizontal) {
                        HStack(alignment: .top, spacing: 10) { deletedCard; staysCard }
                        VStack(spacing: 10) { deletedCard; staysCard }
                    }
                    GuestLearnMore {
                        // copy: detail
                        Text("Circles you made stay if others posted in them. Replies and likes on others’ posts can’t be removed here.")
                    }
                    TextField("Email", text: $model.email)
                        .textContentType(.username).keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never).autocorrectionDisabled()
                        .guestField()
                    SecureField("Password", text: $model.password).textContentType(.password)
                        .guestField()
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

    private var deletedCard: some View {
        GuestFactCard(title: "Will be deleted", systemImage: "xmark.icloud", tint: GuestBrand.danger,
                      items: ["Account", "Cloud backup", "Posts", "Memberships"])
    }

    private var staysCard: some View {
        GuestFactCard(title: "Stays", systemImage: "iphone", tint: GuestBrand.ink, items: ["Entries on this iPhone"])
    }
}

// MARK: - Icons over labels (docs/design/screen-content-guidelines.md)

/// A short icon-and-word fact, where a sentence used to say the same thing.
struct GuestChip: View {
    let text: String
    let systemImage: String
    var muted = false

    var body: some View {
        let tint = muted ? GuestBrand.muted : GuestBrand.blue
        Label(text, systemImage: systemImage)
            .font(GuestBrand.font(.footnote, .semibold)).foregroundStyle(tint)
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(tint.opacity(0.1), in: Capsule())
    }
}

/// Chips side by side, stacked when they don't fit (large text).
struct GuestChipRow<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 8) { content() }
            VStack(alignment: .leading, spacing: 8) { content() }
        }
    }
}

/// An (i) toolbar button whose sheet holds the detail a screen used to keep behind Learn more.
/// Its spoken name is the sheet's title.
struct GuestInfoButton<Content: View>: View {
    let label: String
    @ViewBuilder let content: () -> Content
    @State private var isOpen = false

    var body: some View {
        Button { isOpen = true } label: {
            Image(systemName: "info.circle").frame(minWidth: 44, minHeight: 44).contentShape(Rectangle())
        }
        .accessibilityLabel(label)
        .sheet(isPresented: $isOpen) {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) { content() }
                        .font(GuestBrand.font(.subheadline)).foregroundStyle(GuestBrand.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(24)
                }
                .background(GuestBrand.ice.ignoresSafeArea())
                .navigationTitle(label)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) { Button("Done") { isOpen = false } }
                }
            }
            .presentationDetents([.medium, .large])
        }
    }
}

/// A large decorative symbol at the top of a short screen.
struct GuestSymbolArt: View {
    let systemImage: String
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        if !typeSize.isAccessibilitySize {
            Image(systemName: systemImage).font(.system(size: 64, weight: .light)).foregroundStyle(GuestBrand.blue)
                .frame(maxWidth: .infinity).padding(.vertical, 12)
                .accessibilityHidden(true)
        }
    }
}

/// A titled card with a short list, such as what's deleted and what stays.
struct GuestFactCard: View {
    let title: String
    let systemImage: String
    let tint: Color
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: systemImage)
                .font(GuestBrand.font(.subheadline, .bold)).foregroundStyle(tint)
                .accessibilityAddTraits(.isHeader)
            ForEach(items, id: \.self) { Text($0) }
                .font(GuestBrand.font(.subheadline)).foregroundStyle(GuestBrand.ink)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white, in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
    }
}

extension View {
    /// A text field on a white rounded background; its placeholder is its spoken name.
    func guestField() -> some View {
        padding(12).background(.white, in: RoundedRectangle(cornerRadius: 14))
    }
}
