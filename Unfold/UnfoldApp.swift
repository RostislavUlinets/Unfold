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

    /// State to manage password reset flow from deep links
    @StateObject private var resetTokenHolder = PasswordResetTokenHolder()

    /// Location controller managing GPS tracking and permissions
    @StateObject private var locationController = LocationController()

    /// Map controller managing exploration detection and fog state
    @StateObject private var mapController = MapController()

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authController)
                .environmentObject(resetTokenHolder)
                .environmentObject(locationController)
                .environmentObject(mapController)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
                .onAppear {
                    mapController.setAuthController(authController)
                }
        }
    }

    // MARK: - Deep Link Handling

    /// Handles incoming deep links
    /// - Parameter url: The deep link URL to process
    private func handleDeepLink(_ url: URL) {
        #if DEBUG
        print("🔗 [DeepLink] Received URL: \(url)")
        #endif

        let linkType = DeepLinkParser.parse(url)

        switch linkType {
        case .passwordReset(let token):
            guard token.isValid else {
                #if DEBUG
                print("❌ [DeepLink] Invalid password reset token")
                #endif
                return
            }

            #if DEBUG
            print("✅ [DeepLink] Valid password reset link detected")
            #endif

            // Store the token to trigger password reset confirmation view
            resetTokenHolder.token = token

        case .unknown:
            #if DEBUG
            print("⚠️ [DeepLink] Unknown or unsupported deep link type")
            #endif
        }
    }
}

// MARK: - Password Reset Token Holder

/// Observable object to hold password reset token that can be cleared
@MainActor
class PasswordResetTokenHolder: ObservableObject {
    @Published var token: DeepLinkParser.PasswordResetToken?
}

