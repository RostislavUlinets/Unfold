//
//  UnfoldApp.swift
//  Unfold
//
//  Created by Rostislav on 09.10.2025.
//

import SwiftUI

@main
struct UnfoldApp: App {
    @StateObject private var authController = AuthController()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authController)
        }
    }
}
