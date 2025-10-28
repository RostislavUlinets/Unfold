/// UnfoldApp - Main application entry point.
///
/// This file initializes the app and sets up the root dependency injection.
/// The AuthController is created using the factory pattern and injected into the view hierarchy
/// as an environment object, making it accessible throughout the app while maintaining
/// loose coupling and testability.

import SwiftUI

@main
struct UnfoldApp: App {
    // MARK: - Properties

    /// Authentication controller managing user auth state
    /// Created using factory method for proper dependency injection
    @StateObject private var authController = AuthController.createDefault()

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authController)
        }
    }
}

