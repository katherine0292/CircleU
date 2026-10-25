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
