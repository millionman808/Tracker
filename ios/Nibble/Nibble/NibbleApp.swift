//
//  NibbleApp.swift
//  Nibble — Sprout Snacks
//
//  App entry point. Creates the AppStore and injects it into the environment.
//

import SwiftUI

@main
struct NibbleApp: App {
    @State private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .tint(Theme.greenD)
        }
    }
}
