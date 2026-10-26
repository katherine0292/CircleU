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
        AppBootstrap.live.run(for: startup)
        #if DEBUG
        // UI tests: show Welcome again, while still letting Get started save the choice.
        if startup == .guestJournal, ProcessInfo.processInfo.arguments.contains("-CircleUResetWelcome") {
            UserDefaults.standard.removeObject(forKey: "circleu.guest.welcomeSeen.v1")
        }
        #endif
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
