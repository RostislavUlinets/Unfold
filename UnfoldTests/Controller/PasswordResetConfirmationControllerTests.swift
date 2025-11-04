import Testing
import Foundation
import Supabase
@testable import Unfold

/// Tests for PasswordResetConfirmationController
/// Note: These tests focus on validation logic, computed properties, and state management.
@Suite("PasswordResetConfirmationController Tests")
@MainActor
struct PasswordResetConfirmationControllerTests {

    // MARK: - Initialization Tests

    @Test("PasswordResetConfirmationController initializes with correct default state")
    func initialization_hasCorrectDefaultState() {
        // Arrange & Act
        let controller = createTestController()

        // Assert
        #expect(controller.password == "")
        #expect(controller.confirmPassword == "")
        #expect(controller.isUpdating == false)
        #expect(controller.errorMessage == nil)
        #expect(controller.success == false)
    }

    // MARK: - Password Validation Error Tests

    @Test("passwordValidationError returns nil for empty password")
    func passwordValidationError_emptyPassword_returnsNil() {
        // Arrange
        let controller = createTestController()

        // Act & Assert
        #expect(controller.passwordValidationError == nil)
    }

    @Test("passwordValidationError returns error for short password")
    func passwordValidationError_shortPassword_returnsError() {
        // Arrange
        let controller = createTestController()

        // Act
        controller.password = "short"

        // Assert
        #expect(controller.passwordValidationError != nil)
    }

    @Test("passwordValidationError returns error for password without special char")
    func passwordValidationError_noSpecialChar_returnsError() {
        // Arrange
        let controller = createTestController()

        // Act
        controller.password = "NoSpecial123"

        // Assert
        #expect(controller.passwordValidationError != nil)
    }

    @Test("passwordValidationError returns nil for valid password")
    func passwordValidationError_validPassword_returnsNil() {
        // Arrange
        let controller = createTestController()

        // Act
        controller.password = "ValidPass123!"

        // Assert
        #expect(controller.passwordValidationError == nil)
    }

    // MARK: - Passwords Match Tests

    @Test("passwordsMatch returns false when both passwords are empty")
    func passwordsMatch_bothEmpty_returnsFalse() {
        // Arrange
        let controller = createTestController()

        // Act & Assert
        #expect(controller.passwordsMatch == false)
    }

    @Test("passwordsMatch returns false when only password is filled")
    func passwordsMatch_onlyPasswordFilled_returnsFalse() {
        // Arrange
        let controller = createTestController()

        // Act
        controller.password = "ValidPass123!"

        // Assert
        #expect(controller.passwordsMatch == false)
    }

    @Test("passwordsMatch returns false when only confirmPassword is filled")
    func passwordsMatch_onlyConfirmFilled_returnsFalse() {
        // Arrange
        let controller = createTestController()

        // Act
        controller.confirmPassword = "ValidPass123!"

        // Assert
        #expect(controller.passwordsMatch == false)
    }

    @Test("passwordsMatch returns false when passwords differ")
    func passwordsMatch_differentPasswords_returnsFalse() {
        // Arrange
        let controller = createTestController()

        // Act
        controller.password = "ValidPass123!"
        controller.confirmPassword = "DifferentPass456!"

        // Assert
        #expect(controller.passwordsMatch == false)
    }

    @Test("passwordsMatch returns true when passwords match")
    func passwordsMatch_matchingPasswords_returnsTrue() {
        // Arrange
        let controller = createTestController()

        // Act
        controller.password = "ValidPass123!"
        controller.confirmPassword = "ValidPass123!"

        // Assert
        #expect(controller.passwordsMatch == true)
    }

    // MARK: - Password Strength Tests

    @Test("passwordStrength returns weak for empty password")
    func passwordStrength_emptyPassword_returnsWeak() {
        // Arrange
        let controller = createTestController()

        // Act & Assert
        #expect(controller.passwordStrength == .weak)
    }

    @Test("passwordStrength returns weak for short password")
    func passwordStrength_shortPassword_returnsWeak() {
        // Arrange
        let controller = createTestController()

        // Act
        controller.password = "short"

        // Assert
        #expect(controller.passwordStrength == .weak)
    }

    @Test("passwordStrength returns medium for medium password")
    func passwordStrength_mediumPassword_returnsMedium() {
        // Arrange
        let controller = createTestController()

        // Act
        controller.password = "12345678!"

        // Assert
        #expect(controller.passwordStrength == .medium)
    }

    @Test("passwordStrength returns strong for strong password")
    func passwordStrength_strongPassword_returnsStrong() {
        // Arrange
        let controller = createTestController()

        // Act
        controller.password = "StrongPass123!"

        // Assert
        #expect(controller.passwordStrength == .strong)
    }

    // MARK: - Can Submit Tests

    @Test("canSubmit returns false when password is empty")
    func canSubmit_emptyPassword_returnsFalse() {
        // Arrange
        let controller = createTestController()

        // Act
        controller.confirmPassword = "ValidPass123!"

        // Assert
        #expect(controller.canSubmit == false)
    }

    @Test("canSubmit returns false when passwords do not match")
    func canSubmit_passwordsDoNotMatch_returnsFalse() {
        // Arrange
        let controller = createTestController()

        // Act
        controller.password = "ValidPass123!"
        controller.confirmPassword = "DifferentPass456!"

        // Assert
        #expect(controller.canSubmit == false)
    }

    @Test("canSubmit returns false when password is invalid")
    func canSubmit_invalidPassword_returnsFalse() {
        // Arrange
        let controller = createTestController()

        // Act
        controller.password = "short"
        controller.confirmPassword = "short"

        // Assert
        #expect(controller.canSubmit == false)
    }

    @Test("canSubmit returns false when isUpdating is true")
    func canSubmit_isUpdating_returnsFalse() {
        // Arrange
        let controller = createTestController()

        // Act
        controller.password = "ValidPass123!"
        controller.confirmPassword = "ValidPass123!"
        controller.isUpdating = true

        // Assert
        #expect(controller.canSubmit == false)
    }

    @Test("canSubmit returns true when all conditions are met")
    func canSubmit_allConditionsMet_returnsTrue() {
        // Arrange
        let controller = createTestController()

        // Act
        controller.password = "ValidPass123!"
        controller.confirmPassword = "ValidPass123!"

        // Assert
        #expect(controller.canSubmit == true)
    }

    // MARK: - Update Password Validation Tests

    @Test("updatePassword with invalid form sets error message")
    func updatePassword_invalidForm_setsErrorMessage() async {
        // Arrange
        let controller = createTestController()

        // Act
        await controller.updatePassword()

        // Assert
        #expect(controller.errorMessage != nil)
        #expect(controller.errorMessage?.contains("fix the errors") ?? false)
        #expect(controller.success == false)
    }

    @Test("updatePassword with mismatched passwords sets error")
    func updatePassword_mismatchedPasswords_setsError() async {
        // Arrange
        let controller = createTestController()

        // Act
        controller.password = "ValidPass123!"
        controller.confirmPassword = "DifferentPass456!"
        await controller.updatePassword()

        // Assert
        #expect(controller.errorMessage != nil)
        #expect(controller.success == false)
    }

    @Test("updatePassword with weak password sets error")
    func updatePassword_weakPassword_setsError() async {
        // Arrange
        let controller = createTestController()

        // Act
        controller.password = "weak"
        controller.confirmPassword = "weak"
        await controller.updatePassword()

        // Assert
        #expect(controller.errorMessage != nil)
        #expect(controller.success == false)
    }

    // MARK: - Clear Error Tests

    @Test("clearError clears error message")
    func clearError_clearsErrorMessage() {
        // Arrange
        let controller = createTestController()
        controller.errorMessage = "Test error"

        // Act
        controller.clearError()

        // Assert
        #expect(controller.errorMessage == nil)
    }

    @Test("clearError does not affect other state")
    func clearError_doesNotAffectOtherState() {
        // Arrange
        let controller = createTestController()
        controller.password = "ValidPass123!"
        controller.confirmPassword = "ValidPass123!"
        controller.errorMessage = "Test error"

        // Act
        controller.clearError()

        // Assert
        #expect(controller.errorMessage == nil)
        #expect(controller.password == "ValidPass123!")
        #expect(controller.confirmPassword == "ValidPass123!")
    }

    // MARK: - State Management Tests

    @Test("password and confirmPassword can be set independently")
    func passwordFields_canBeSetIndependently() {
        // Arrange
        let controller = createTestController()

        // Act
        controller.password = "Password1!"

        // Assert
        #expect(controller.password == "Password1!")
        #expect(controller.confirmPassword == "")

        // Act
        controller.confirmPassword = "Password2!"

        // Assert
        #expect(controller.password == "Password1!")
        #expect(controller.confirmPassword == "Password2!")
    }

    @Test("isUpdating can be toggled")
    func isUpdating_canBeToggled() {
        // Arrange
        let controller = createTestController()

        // Act
        controller.isUpdating = true

        // Assert
        #expect(controller.isUpdating == true)

        // Act
        controller.isUpdating = false

        // Assert
        #expect(controller.isUpdating == false)
    }

    @Test("success can be toggled")
    func success_canBeToggled() {
        // Arrange
        let controller = createTestController()

        // Act
        controller.success = true

        // Assert
        #expect(controller.success == true)

        // Act
        controller.success = false

        // Assert
        #expect(controller.success == false)
    }

    // MARK: - Edge Case Tests

    @Test("very long password handles gracefully")
    func veryLongPassword_handlesGracefully() {
        // Arrange
        let controller = createTestController()
        let longPassword = String(repeating: "a", count: 1000) + "A1!"

        // Act
        controller.password = longPassword
        controller.confirmPassword = longPassword

        // Assert - Should not crash
        #expect(controller.passwordsMatch == true)
        #expect(controller.passwordStrength == .strong)
    }

    @Test("unicode password handles gracefully")
    func unicodePassword_handlesGracefully() {
        // Arrange
        let controller = createTestController()
        let unicodePassword = "Pässwörd123!"

        // Act
        controller.password = unicodePassword
        controller.confirmPassword = unicodePassword

        // Assert
        #expect(controller.passwordsMatch == true)
    }

    @Test("emoji in password handles gracefully")
    func emojiPassword_handlesGracefully() {
        // Arrange
        let controller = createTestController()
        let emojiPassword = "Pass123!😀"

        // Act
        controller.password = emojiPassword
        controller.confirmPassword = emojiPassword

        // Assert
        #expect(controller.passwordsMatch == true)
    }

    @Test("all special characters in password handle gracefully")
    func allSpecialCharacters_handleGracefully() {
        // Arrange
        let controller = createTestController()
        let specialPassword = "Pass123!@#$%^&*()"

        // Act
        controller.password = specialPassword
        controller.confirmPassword = specialPassword

        // Assert
        #expect(controller.passwordsMatch == true)
        #expect(controller.canSubmit == true)
    }

    // MARK: - Computed Property Reactivity Tests

    @Test("canSubmit updates when password changes")
    func canSubmit_updatesWhenPasswordChanges() {
        // Arrange
        let controller = createTestController()
        controller.confirmPassword = "ValidPass123!"

        // Initially false
        #expect(controller.canSubmit == false)

        // Act
        controller.password = "ValidPass123!"

        // Assert - Should now be true
        #expect(controller.canSubmit == true)
    }

    @Test("canSubmit updates when confirmPassword changes")
    func canSubmit_updatesWhenConfirmPasswordChanges() {
        // Arrange
        let controller = createTestController()
        controller.password = "ValidPass123!"

        // Initially false
        #expect(controller.canSubmit == false)

        // Act
        controller.confirmPassword = "ValidPass123!"

        // Assert - Should now be true
        #expect(controller.canSubmit == true)
    }

    @Test("passwordsMatch updates immediately when passwords change")
    func passwordsMatch_updatesImmediately() {
        // Arrange
        let controller = createTestController()

        // Act - Set matching passwords
        controller.password = "ValidPass123!"
        controller.confirmPassword = "ValidPass123!"

        // Assert
        #expect(controller.passwordsMatch == true)

        // Act - Change password
        controller.password = "DifferentPass456!"

        // Assert - Should immediately be false
        #expect(controller.passwordsMatch == false)
    }

    // MARK: - Helper Methods

    /// Creates a test PasswordResetConfirmationController instance
    private func createTestController() -> PasswordResetConfirmationController {
        let urlString = "https://test.supabase.co"
        let key = "test-anon-key-for-testing-only"
        let url = URL(string: urlString)!
        let client = SupabaseClient(supabaseURL: url, supabaseKey: key)
        let authController = AuthController(client: client)

        let token = DeepLinkParser.PasswordResetToken(token: "test-token-123")

        return PasswordResetConfirmationController(
            authController: authController,
            resetToken: token
        )
    }
}
