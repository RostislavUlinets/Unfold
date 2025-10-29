import Foundation

/// Controller for managing password reset confirmation flow
@MainActor
final class PasswordResetConfirmationController: ObservableObject {

    // MARK: - Published Properties

    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isUpdating: Bool = false
    @Published var errorMessage: String? = nil
    @Published var success: Bool = false

    // MARK: - Dependencies

    private let authService: AuthServiceProtocol
    private let resetToken: DeepLinkParser.PasswordResetToken

    // MARK: - Computed Properties

    /// Real-time password validation error
    var passwordValidationError: String? {
        guard !password.isEmpty else { return nil }
        return PasswordValidator.validationMessage(for: password)
    }

    /// Whether passwords match
    var passwordsMatch: Bool {
        guard !password.isEmpty && !confirmPassword.isEmpty else { return false }
        return PasswordValidator.passwordsMatch(password, confirmPassword)
    }

    /// Password strength
    var passwordStrength: PasswordValidator.Strength {
        PasswordValidator.strength(of: password)
    }

    /// Whether the form can be submitted
    var canSubmit: Bool {
        PasswordValidator.isValid(password) &&
        passwordsMatch &&
        !isUpdating
    }

    // MARK: - Initialization

    init(authService: AuthServiceProtocol, resetToken: DeepLinkParser.PasswordResetToken) {
        self.authService = authService
        self.resetToken = resetToken
    }

    // MARK: - Actions

    /// Updates the user's password
    func updatePassword() async {
        guard canSubmit else {
            errorMessage = "Please fix the errors before continuing"
            return
        }

        isUpdating = true
        errorMessage = nil

        do {
            // Simple approach: just try to verify the token and update password
            try await authService.verifyTokenAndUpdatePassword(
                token: resetToken.token,
                newPassword: password
            )

            #if DEBUG
            print("✅ [PasswordReset] Password updated successfully")
            #endif

            success = true

        } catch {
            #if DEBUG
            print("❌ [PasswordReset] Failed to update password: \(error.localizedDescription)")
            #endif

            // Parse specific errors
            errorMessage = parseError(error)
        }

        isUpdating = false
    }

    /// Parses error messages into user-friendly text
    private func parseError(_ error: Error) -> String {
        let description = error.localizedDescription.lowercased()

        if description.contains("expired") || description.contains("invalid") {
            return "This reset link has expired. Please request a new password reset."
        } else if description.contains("network") || description.contains("connection") {
            return "Network error. Please check your connection and try again."
        } else if description.contains("weak") || description.contains("password") {
            return "Password does not meet requirements. Please try a stronger password."
        } else {
            return "An error occurred. Please try again."
        }
    }

    /// Clears error message
    func clearError() {
        errorMessage = nil
    }
}
