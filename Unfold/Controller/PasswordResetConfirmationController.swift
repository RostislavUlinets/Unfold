import Foundation

@MainActor
final class PasswordResetConfirmationController: ObservableObject {

    // MARK: - Published Properties

    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isUpdating: Bool = false
    @Published var errorMessage: String? = nil
    @Published var success: Bool = false

    // MARK: - Dependencies

    private let authController: AuthController
    private let resetToken: DeepLinkParser.PasswordResetToken

    // MARK: - Computed Properties

    var passwordValidationError: String? {
        guard !password.isEmpty else { return nil }
        return PasswordValidator.validationMessage(for: password)
    }

    var passwordsMatch: Bool {
        guard !password.isEmpty && !confirmPassword.isEmpty else { return false }
        return PasswordValidator.passwordsMatch(password, confirmPassword)
    }

    var passwordStrength: PasswordValidator.Strength {
        PasswordValidator.strength(of: password)
    }

    var canSubmit: Bool {
        PasswordValidator.isValid(password) &&
        passwordsMatch &&
        !isUpdating
    }

    // MARK: - Initialization

    init(authController: AuthController, resetToken: DeepLinkParser.PasswordResetToken) {
        self.authController = authController
        self.resetToken = resetToken
    }

    // MARK: - Public Methods

    func updatePassword() async {
        guard canSubmit else {
            errorMessage = "Please fix the errors before continuing"
            return
        }

        isUpdating = true
        errorMessage = nil

        do {
            try await authController.verifyTokenAndUpdatePassword(
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

            errorMessage = parseError(error)
        }

        isUpdating = false
    }

    func clearError() {
        errorMessage = nil
    }

    // MARK: - Private Methods

    private func parseError(_ error: Error) -> String {
        let description = error.localizedDescription.lowercased()

        if description.contains("same") || description.contains("different from the old") {
            return "New password must be different from your current password."
        } else if description.contains("expired") {
            return "This reset link has expired. Please request a new password reset."
        } else if description.contains("invalid") || description.contains("token") {
            return "Invalid or expired reset link. Please request a new password reset."
        } else if description.contains("network") || description.contains("connection") {
            return "Network error. Please check your connection and try again."
        } else if description.contains("weak") {
            return "Password is too weak. Please use a stronger password."
        } else if description.contains("password") && description.contains("requirements") {
            return "Password does not meet requirements. Use at least 8 characters with a special character."
        } else {
            return "An error occurred: \(error.localizedDescription)"
        }
    }
}
