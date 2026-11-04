# Guest Test install: two traps, and the owner route

- Recorded: 2026-11-05 09:45 +11:00; Australia/Sydney.
- Agent / role: Claude Code.
- Status: build verified; install handed to the owner (Xcode account needed).
- Related: [27 October native Practice QA](../qa/native-practice-2026-10-27/README.md), [26 October phone handoff](2026-10-26-193000-claude-visual-today-phone-handoff.md).

## What happened

Owner asked for the phone walkthrough after PRs 61–63. The iPhone 11 Pro Max was paired, so I tried to update Guest Test (`com.tuannm3812.circleu.guesttest`) in place from `main` (`24c04ef`).

1. **`-configuration Debug` overrides the scheme.** `xcodebuild build -scheme 'CircleU Guest Review' -configuration Debug` produced a bundle with the legacy id `edu.uts.tuannm3812.Circleu`: the explicit flag replaced the scheme's own `GuestReview` configuration, which is where `PRODUCT_BUNDLE_IDENTIFIER = $(CIRCLEU_REVIEW_BUNDLE_ID)` lives. Installing that would have overwritten the legacy app. Always build the review scheme with `-configuration GuestReview` or no configuration flag, and check `CFBundleIdentifier` in the built `Info.plist` before any install.
2. **The local `Config/Signing.xcconfig` needs `CIRCLEU_REVIEW_BUNDLE_ID`.** The main checkout's copy lacked it (Codex's worktree copy has it); without it the review id is empty. Added locally; the file is gitignored.
3. **Signing the Guest Test id needs the owner's Apple ID in Xcode.** With the id right, `xcodebuild … -allowProvisioningUpdates` failed with "No Accounts" and no development profile for `com.tuannm3812.circleu.guesttest`; no such profile exists on disk and Xcode holds no account in this session. The 27 October install was done through Xcode with the owner's account. I did not and cannot sign in for the owner.

## Owner route

Open `Circleu.xcodeproj`, choose the **CircleU Guest Review** scheme and the iPhone as destination, unlock the phone, press Run. Xcode creates the profile with the signed-in account and installs over the existing Guest Test, keeping its entries. Never uninstall to fix a signing problem.

## Not done

No install, no phone screenshots. The `.gitignore` now excludes `firestore-tests/node_modules` and its lock file, which the emulator run created.
