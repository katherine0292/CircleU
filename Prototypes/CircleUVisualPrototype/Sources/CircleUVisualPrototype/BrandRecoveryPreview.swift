import SwiftUI

/// Invented, process-memory fixtures. Never authenticates, sends email or reads user data.
public enum BrandRecoveryScreen: String, CaseIterable {
    case logIn, checking, loginError, offline, resetRequest, sendingReset, resetSent
    case resetError, linkExpired, linkInvalid, newPassword, changingPassword, passwordChanged, passwordError
    case backupReview, noBackup, backupError, recovering, recoveryError, recovered, privacy, help
}

public enum BrandRecoveryScenario: String, CaseIterable {
    case available, loginError, offline, noBackup, backupError, resetError, recoveryError
}

public struct BrandRecoveryPreview: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var route: [BrandRecoveryScreen]
    @State private var email = ""
    @State private var password = ""
    @State private var newPassword = ""
    @State private var confirmation = ""
    @State private var validation: String?
    @State private var recoverMessage = false
    @FocusState private var focusedField: Field?
    private let scenario: BrandRecoveryScenario
    private let advancesProgress: Bool
    private let renderingSnapshot: Bool
    private let onBack: () -> Void
    private let onContinue: () -> Void

    private enum Field: Hashable { case email, password, newPassword, confirmation }
    private var screen: BrandRecoveryScreen { route.last ?? .logIn }

    public init(initialScreen: BrandRecoveryScreen = .logIn,
                scenario: BrandRecoveryScenario = .available,
                advancesProgress: Bool = true, renderingSnapshot: Bool = false,
                onBack: @escaping () -> Void = {}, onContinue: @escaping () -> Void = {}) {
        _route = State(initialValue: initialScreen == .logIn ? [.logIn] : [.logIn, initialScreen])
        self.scenario = scenario
        self.advancesProgress = advancesProgress
        self.renderingSnapshot = renderingSnapshot
        self.onBack = onBack
        self.onContinue = onContinue
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: back) { Label("Back", systemImage: "chevron.left") }
                .font(font(17, .medium)).buttonStyle(.plain)
                .foregroundStyle(BrandDemoColor.blue).frame(minHeight: 44)
                .padding(.horizontal, 24)
            ViewThatFits(in: .vertical) {
                content
                ScrollView { content }
                    .scrollDismissesKeyboard(.interactively)
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .foregroundStyle(BrandDemoColor.ink)
        .background(BrandDemoColor.ice.ignoresSafeArea())
        .environment(\.colorScheme, .light)
        .tint(BrandDemoColor.blue)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: screen)
        .task(id: screen) { await advanceProgress() }
        .onDisappear { clearSecrets() }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 20) {
            BrandWordmark(size: 19)
                .accessibilityElement(children: .ignore).accessibilityLabel("CircleU")
                .padding(.bottom, 8)
            Text(title).font(font(30, .bold, relativeTo: .largeTitle))
                .fixedSize(horizontal: false, vertical: true).accessibilityAddTraits(.isHeader)
            screenContent
        }
        .font(font(17))
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder private var screenContent: some View {
        switch screen {
        case .logIn:
            helper("Use your earlier CircleU account. Nothing imports automatically.")
            emailField
            passwordField("Password", text: $password, field: .password)
            validationMessage
            action("Log in") { submitLogin() }
            HStack(spacing: 12) {
                secondary("Forgot password?") { navigate(.resetRequest) }
                secondary("Used Google?") { navigate(.help) }
            }
            secondary("Privacy and data") { navigate(.privacy) }
            secondary("Continue locally") { leaveLocally() }
        case .checking:
            progress("Checking your earlier account and backup.")
            secondary("Cancel") { back() }
        case .loginError:
            status("Couldn’t log in", symbol: "person.crop.circle.badge.exclamationmark",
                   detail: "Check your email, password or original login method. Your entries are unchanged.")
            action("Try again") { returnToLogin() }
            secondary("Reset password") { navigate(.resetRequest) }
            secondary("Continue locally") { leaveLocally() }
        case .offline:
            status("You’re offline", symbol: "wifi.slash", detail: "Connect to check your earlier account. Local entries are unchanged.")
            action("Try again") { replace(.checking) }
            secondary("Continue locally") { leaveLocally() }
        case .resetRequest:
            helper("We’ll send a link to your earlier account’s email.")
            emailField
            validationMessage
            action("Send reset link") { submitReset() }
            secondary("Back to Log in") { returnToLogin() }
            secondary("Privacy and data") { navigate(.privacy) }
        case .sendingReset:
            progress("Requesting a reset link…")
            secondary("Cancel") { back() }
        case .resetSent:
            status("Reset link", symbol: "envelope", detail: "If an account uses this email, you’ll receive a reset link.")
            helper("Check spam, or request another link.")
            action("Back to Log in") { returnToLogin() }
            secondary("Send again") { navigate(.resetRequest) }
        case .resetError:
            status("Couldn’t request a link", symbol: "envelope.badge", detail: "Try again when you’re connected. Your password hasn’t changed.")
            action("Try again") { replace(.resetRequest) }
            secondary("Back to Log in") { returnToLogin() }
        case .linkExpired, .linkInvalid:
            status(screen == .linkExpired ? "Link expired" : "Link can’t be used", symbol: "clock.arrow.circlepath", detail: "Request a new reset link. Your password hasn’t changed.")
            action("Request new link") { replace(.resetRequest) }
            secondary("Back to Log in") { returnToLogin() }
        case .newPassword:
            helper("Use at least 9 characters.")
            passwordField("New password", text: $newPassword, field: .newPassword)
            passwordField("Confirm password", text: $confirmation, field: .confirmation)
            validationMessage
            action("Update password") { submitNewPassword() }
        case .changingPassword:
            progress("Updating your password…")
            secondary("Cancel") { back() }
        case .passwordChanged:
            status("Password updated", symbol: "checkmark.shield", detail: "Use your new password to log in. Nothing has been imported.")
            action("Log in") { returnToLogin() }
        case .passwordError:
            status("Couldn’t update your password", symbol: "lock", detail: "Your password hasn’t changed. Try again or request a new link.")
            action("Try again") { replace(.newPassword) }
            secondary("Request new link") { replace(.resetRequest) }
        case .backupReview:
            helper("Choose what to recover. Your current entries stay unchanged.")
            recoverySelection
            status("Keep this device’s version", symbol: "iphone", detail: "Your edited reflection won’t be replaced.")
            validationMessage
            action("Recover selected") {
                guard recoverMessage else { validation = "Choose a message to recover."; return }
                navigate(.recovering)
            }
            secondary("Continue without importing") { leaveLocally() }
        case .noBackup:
            status("No backup found", symbol: "tray", detail: "The check finished for this account. Earlier entries may still be on your old device.")
            action("Try another account") { returnToLogin() }
            secondary("Continue locally") { leaveLocally() }
        case .backupError:
            status("Couldn’t check your backup", symbol: "icloud.slash", detail: "This doesn’t mean your backup is empty. Your entries are unchanged.")
            action("Retry check") { replace(.checking) }
            secondary("Continue locally") { leaveLocally() }
        case .recovering:
            progress("Preparing your selected message…")
            secondary("Cancel") { back() }
        case .recoveryError:
            status("Couldn’t recover the message", symbol: "exclamationmark.arrow.triangle.2.circlepath",
                   detail: "Your selection and earlier backup are unchanged. Try again.")
            action("Review selection") { replace(.backupReview) }
            secondary("Continue locally") { leaveLocally() }
        case .recovered:
            status("Your message is ready", symbol: "checkmark.circle", detail: "Your reflection wasn’t replaced. The earlier cloud copy remains separate.")
            action("Done") { leaveLocally() }
        case .privacy:
            status("Your earlier account", symbol: "person.crop.circle", detail: "Login and password reset contact the earlier account service.")
            status("Your choice", symbol: "hand.raised", detail: "Checking a backup doesn’t import, upload or delete entries.")
            status("Local use", symbol: "iphone", detail: "New entries stay on this device. Device backups may include them.")
            action("Done") { back() }
        case .help:
            helper("Use the same login method as before. Creating a new account won’t recover the old one.")
            status("Used Google?", symbol: "person.crop.circle", detail: "Google recovery isn’t available here yet. Keep your original account and app.")
            status("Keep your earlier app", symbol: "iphone", detail: "Don’t delete the old installation or its data while recovery is unresolved.")
            action("Back to Log in") { returnToLogin() }
            secondary("Continue locally") { leaveLocally() }
        }
    }

    private var title: String {
        switch screen {
        case .logIn: "Log in"
        case .checking: "Checking your account"
        case .loginError, .offline: "Log in"
        case .resetRequest, .sendingReset, .resetError: "Reset password"
        case .resetSent: "Check your email"
        case .linkExpired, .linkInvalid: "Request a new link"
        case .newPassword, .changingPassword, .passwordError: "New password"
        case .passwordChanged: "You’re ready to log in"
        case .backupReview: "Earlier data"
        case .noBackup, .backupError: "Earlier backup"
        case .recovering, .recoveryError, .recovered: "Recover your message"
        case .privacy: "Privacy and data"
        case .help: "Account help"
        }
    }

    private var emailField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Email").font(font(14, .semibold, relativeTo: .subheadline))
            Group {
                if renderingSnapshot {
                    Text("Email address").foregroundStyle(BrandDemoColor.muted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    TextField("Email address", text: $email)
                        .textContentType(.emailAddress)
                        .autocorrectionDisabled().focused($focusedField, equals: .email)
                        .submitLabel(screen == .resetRequest ? .done : .next)
                        .onSubmit {
                            if screen == .resetRequest { submitReset() }
                            else { focusedField = .password }
                        }
                        .accessibilityLabel("Email").privacySensitive()
#if os(iOS)
                        .keyboardType(.emailAddress).textInputAutocapitalization(.never)
#endif
                }
            }
            .padding(16).background(.white, in: RoundedRectangle(cornerRadius: 14))
        }
    }

    private func passwordField(_ label: String, text: Binding<String>, field: Field) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(font(14, .semibold, relativeTo: .subheadline))
            Group {
                if renderingSnapshot {
                    Text(label).foregroundStyle(BrandDemoColor.muted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    SecureField(label, text: text)
                        .textContentType(field == .password ? .password : .newPassword)
                        .focused($focusedField, equals: field).privacySensitive()
                        .submitLabel(.done).onSubmit {
                            if field == .password { submitLogin() }
                            else if field == .newPassword { focusedField = .confirmation }
                            else { submitNewPassword() }
                        }
                }
            }
            .padding(16).background(.white, in: RoundedRectangle(cornerRadius: 14))
        }
    }

    private var recoverySelection: some View {
        Group {
            if renderingSnapshot {
                HStack(spacing: 12) {
                    Image(systemName: "circle").foregroundStyle(BrandDemoColor.blue)
                    selectionLabel
                }
            } else {
                Toggle(isOn: $recoverMessage) { selectionLabel }
                    .onChange(of: recoverMessage) { _, _ in validation = nil }
                    .accessibilityLabel("Recover Ask for an update")
            }
        }
        .padding(18).frame(maxWidth: .infinity, alignment: .leading)
        .background(.white, in: RoundedRectangle(cornerRadius: 18))
    }

    private var selectionLabel: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Practice message").font(font(17, .semibold))
            Text("Ask for an update").foregroundStyle(BrandDemoColor.muted)
        }
    }

    @ViewBuilder private var validationMessage: some View {
        if let validation {
            Label(validation, systemImage: "exclamationmark.circle")
                .font(font(14, .medium, relativeTo: .subheadline))
                .foregroundStyle(BrandDemoColor.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func helper(_ text: String) -> some View {
        Text(text).foregroundStyle(BrandDemoColor.muted)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func status(_ title: String, symbol: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: symbol).font(font(17, .semibold))
            helper(detail)
        }
        .padding(18).frame(maxWidth: .infinity, alignment: .leading)
        .background(.white, in: RoundedRectangle(cornerRadius: 18))
    }

    private func progress(_ text: String) -> some View {
        HStack(spacing: 14) {
            ProgressView().accessibilityLabel(text)
            helper(text)
        }.padding(.vertical, 18)
    }

    private func action(_ title: String, perform: @escaping () -> Void) -> some View {
        Button(action: perform) {
            Text(title).font(font(17, .semibold)).multilineTextAlignment(.center)
                .padding(16).frame(maxWidth: .infinity, minHeight: 54)
                .foregroundStyle(.white)
                .background(BrandDemoColor.blue, in: RoundedRectangle(cornerRadius: 18))
        }.buttonStyle(.plain)
    }

    private func secondary(_ title: String, perform: @escaping () -> Void) -> some View {
        Button(title, action: perform).font(font(14, .semibold, relativeTo: .subheadline))
            .buttonStyle(.plain).foregroundStyle(BrandDemoColor.blue)
            .frame(maxWidth: .infinity, minHeight: 44)
    }

    private func font(_ size: CGFloat, _ weight: Font.Weight = .regular,
                      relativeTo style: Font.TextStyle = .body) -> Font {
        .custom(BrandDemoFont.postScriptName, size: size, relativeTo: style).weight(weight)
    }

    private func validEmail() -> Bool {
        email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = email.split(separator: "@", omittingEmptySubsequences: false)
        let validParts = parts.count == 2 && !parts[0].isEmpty
        let labels = validParts ? parts[1].split(separator: ".", omittingEmptySubsequences: false) : []
        let validDomain = labels.count >= 2 && labels.allSatisfy { label in
            !label.isEmpty && !label.hasPrefix("-") && !label.hasSuffix("-") &&
            label.allSatisfy { $0.isLetter || $0.isNumber || $0 == "-" }
        }
        guard validParts, validDomain, !email.contains(where: { $0.isWhitespace }) else {
            validation = "Enter a valid email address."; focusedField = .email; return false
        }
        return true
    }

    private func submitLogin() {
        guard screen == .logIn, validEmail() else { return }
        guard !password.isEmpty else { validation = "Enter your password."; focusedField = .password; return }
        clearSecrets(); navigate(.checking)
    }

    private func submitReset() {
        guard screen == .resetRequest, validEmail() else { return }
        navigate(.sendingReset)
    }

    private func submitNewPassword() {
        guard screen == .newPassword else { return }
        guard newPassword.count >= 9 else {
            validation = "Use at least 9 characters."; focusedField = .newPassword; return
        }
        guard newPassword == confirmation else {
            validation = "The passwords don’t match."; focusedField = .confirmation; return
        }
        clearSecrets(); navigate(.changingPassword)
    }

    private func navigate(_ next: BrandRecoveryScreen) {
        validation = nil; focusedField = nil; route.append(next)
    }

    private func replace(_ next: BrandRecoveryScreen) {
        validation = nil; focusedField = nil; route[route.count - 1] = next
    }

    private func back() {
        if screen == .passwordChanged { returnToLogin(); return }
        if screen == .recovered { leaveLocally(); return }
        clearSecrets(); validation = nil; focusedField = nil
        if route.count > 1 { route.removeLast() } else { onBack() }
    }

    private func returnToLogin() {
        clearSecrets(); validation = nil; focusedField = nil; route = [.logIn]
    }

    private func clearSecrets() { password = ""; newPassword = ""; confirmation = "" }
    private func leaveLocally() { clearSecrets(); focusedField = nil; onContinue() }

    /// Review latency only. View-scoped task cancellation prevents a late fixture result after Back.
    private func advanceProgress() async {
        let destination: BrandRecoveryScreen
        switch screen {
        case .checking:
            switch scenario {
            case .loginError: destination = .loginError
            case .offline: destination = .offline
            case .noBackup: destination = .noBackup
            case .backupError: destination = .backupError
            default: destination = .backupReview
            }
        case .sendingReset: destination = (scenario == .resetError || scenario == .offline) ? .resetError : .resetSent
        case .changingPassword: destination = (scenario == .resetError || scenario == .offline) ? .passwordError : .passwordChanged
        case .recovering: destination = (scenario == .recoveryError || scenario == .offline) ? .recoveryError : .recovered
        default: return
        }
        guard advancesProgress else { return }
        do { try await Task.sleep(for: .seconds(2)) } catch { return }
        guard !Task.isCancelled else { return }
        replace(destination)
    }
}

public struct BrandRecoveryGallery: View {
    private let screens: [BrandRecoveryScreen]
    public init(screens: [BrandRecoveryScreen] = [.logIn, .resetRequest, .backupReview]) {
        self.screens = screens
    }
    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Account recovery · Native previews").font(BrandDemoFont.font(24, .bold))
            Text("Invented fixtures · No authentication, emails or data changes · Never enter real credentials")
                .font(BrandDemoFont.font(13)).foregroundStyle(BrandDemoColor.muted)
            HStack(alignment: .top, spacing: 24) {
                ForEach(screens, id: \.rawValue) { screen in
                    specimen(screen, title: screen.rawValue)
                }
            }
        }.padding(28).background(.white).foregroundStyle(BrandDemoColor.ink)
    }
    private func specimen(_ screen: BrandRecoveryScreen, title: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(BrandDemoFont.font(13, .medium))
            BrandRecoveryPreview(initialScreen: screen, advancesProgress: false, renderingSnapshot: true)
                .frame(width: 390, height: 844)
        }
    }
}

#Preview("Recovery · Log in") { BrandOnboardingPreview(initialScreen: .logIn) }
#Preview("Recovery · Reset password") { BrandOnboardingPreview(initialScreen: .logIn, recoveryScreen: .resetRequest) }
#Preview("Recovery · Check email") { BrandOnboardingPreview(initialScreen: .logIn, recoveryScreen: .resetSent) }
#Preview("Recovery · Expired link") { BrandOnboardingPreview(initialScreen: .logIn, recoveryScreen: .linkExpired) }
#Preview("Recovery · New password") { BrandOnboardingPreview(initialScreen: .logIn, recoveryScreen: .newPassword) }
#Preview("Recovery · Login error") { BrandOnboardingPreview(initialScreen: .logIn, recoveryScreen: .loginError) }
#Preview("Recovery · No backup") { BrandOnboardingPreview(initialScreen: .logIn, recoveryScreen: .noBackup) }
#Preview("Recovery · Recovery error") { BrandOnboardingPreview(initialScreen: .logIn, recoveryScreen: .recoveryError) }
#Preview("Recovery · Largest text") { BrandOnboardingPreview(initialScreen: .logIn).environment(\.dynamicTypeSize, .accessibility5) }
#Preview("Recovery · Earlier data") { BrandOnboardingPreview(initialScreen: .logIn, recoveryScreen: .backupReview) }
#Preview("Recovery · Offline") { BrandOnboardingPreview(initialScreen: .logIn, recoveryScreen: .offline) }
#Preview("Recovery · Reset error") { BrandOnboardingPreview(initialScreen: .logIn, recoveryScreen: .resetError) }
#Preview("Recovery · Invalid link") { BrandOnboardingPreview(initialScreen: .logIn, recoveryScreen: .linkInvalid) }
#Preview("Recovery · Password update error") { BrandOnboardingPreview(initialScreen: .logIn, recoveryScreen: .passwordError) }
#Preview("Recovery · Password updated") { BrandOnboardingPreview(initialScreen: .logIn, recoveryScreen: .passwordChanged) }
#Preview("Recovery · Backup check error") { BrandOnboardingPreview(initialScreen: .logIn, recoveryScreen: .backupError) }
#Preview("Recovery · Message ready") { BrandOnboardingPreview(initialScreen: .logIn, recoveryScreen: .recovered) }
