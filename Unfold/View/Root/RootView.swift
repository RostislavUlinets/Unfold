import SwiftUI

struct RootView: View {
    @EnvironmentObject var auth: AuthController
    @EnvironmentObject var resetTokenHolder: PasswordResetTokenHolder
    @State private var showContent = false
    @State private var showLoggedInAlert = false

    var body: some View {
        ZStack {
            Color.authBackground
                .ignoresSafeArea()

            Group {
                if !showContent {
                    SplashView()
                } else if let resetToken = resetTokenHolder.token {
                    // Show password reset confirmation view if we have a reset token
                    PasswordResetConfirmationView(
                        authController: auth,
                        resetToken: resetToken,
                        onComplete: {
                            // Clear the token to navigate to HomeView
                            Task { @MainActor in
                                resetTokenHolder.token = nil
                            }
                        }
                    )
                    .environmentObject(auth)
                } else if auth.isAuthenticated {
                    HomePageView()
                        .environmentObject(auth)
                } else {
                    AuthPageView()
                }
            }
        }
        .animation(.smooth(duration: 0.4), value: showContent)
        .animation(.smooth(duration: 0.4), value: auth.isAuthenticated)
        .animation(.smooth(duration: 0.4), value: resetTokenHolder.token != nil)
        .alert("Already Logged In", isPresented: $showLoggedInAlert) {
            Button("Sign Out and Reset", role: .destructive) {
                Task {
                    await auth.logout()
                }
            }
            Button("Cancel", role: .cancel) {
                Task { @MainActor in
                    resetTokenHolder.token = nil
                }
            }
        } message: {
            Text("You're currently logged in. Do you want to sign out and reset your password?")
        }
        .task {
            // Show splash for minimum 2 seconds while auth initializes
            async let splashDelay: Void = {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
            }()

            // Wait for auth to load
            while auth.isLoading {
                try? await Task.sleep(nanoseconds: 100_000_000) // Poll every 0.1s
            }

            // Ensure both conditions are met
            await splashDelay
            showContent = true
        }
        .onChange(of: resetTokenHolder.token) { _, newToken in
            // If a reset token arrives while user is logged in, show alert
            if newToken != nil && auth.isAuthenticated {
                showLoggedInAlert = true
            }
        }
    }
}
