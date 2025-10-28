import SwiftUI

@MainActor
final class PasswordResetController: ObservableObject {

    /// Indicates if password reset email is being sent
    @Published var isSending = false

    /// Indicates if password reset email was sent successfully
    @Published var success = false

    /// Contains error message if reset request failed
    @Published var errorMessage: String?


    private let authService: AuthServiceProtocol


    /// Initialize controller with authentication service
    /// - Parameter authService: Service conforming to AuthServiceProtocol
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }


    /// Request a password reset email
    /// - Parameter email: User's email address
    func resetPassword(email: String) async {
        // Validate input
        guard !email.isEmpty else {
            errorMessage = Strings.Auth.fillAllFields
            return
        }

        isSending = true
        errorMessage = nil
        success = false

        do {
            try await authService.resetPassword(email: email)
            success = true
        } catch {
            errorMessage = error.localizedDescription
            #if DEBUG
            print("❌ [PasswordReset] Failed: \(error.localizedDescription)")
            #endif
        }

        isSending = false
    }
}

