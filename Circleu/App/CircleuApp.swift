//
//  CircleuApp.swift
//  Circleu
//
//  Created by David Oyarekhua on 2/6/2026.
//

import SwiftUI

@main
struct CircleuApp: App {
    private let startup = AppStartup.resolve()

    init() {
        // The hidden guest journal (DEBUG only) starts without Firebase or analytics.
        #if DEBUG
        // UI tests: start from a fresh guest journal (no entries, drafts, chosen Pingu or Welcome
        // choice), so each test owns its state. Guest mode only; the legacy app is never touched.
        if startup == .guestJournal, ProcessInfo.processInfo.arguments.contains("-CircleUResetGuestData"),
           let support = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask,
                                                      appropriateFor: nil, create: false) {
            for folder in ["GuestJournal", "GuestJournalSetup"] {
                try? FileManager.default.removeItem(at: support.appendingPathComponent(folder))
            }
            for key in ["circleu.guest.welcomeSeen.v1", GuestAvatars.storageKey] {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
        #endif
        AppBootstrap.live.run(for: startup)
    }

    var body: some Scene {
        WindowGroup {
            switch startup {
            case .existingApp:
                ContentView()
            case .guestJournal:
                GuestRootView()
            }
        }
    }
}
