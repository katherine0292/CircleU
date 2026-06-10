//
//  CircleuApp.swift
//  Circleu
//
//  Created by David Oyarekhua on 2/6/2026.
//

import FirebaseCore
import SwiftUI

@main
struct CircleuApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
