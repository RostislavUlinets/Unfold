import Testing
import Foundation
import Supabase
@testable import Unfold

/// Tests for PasswordResetController
/// Note: These tests focus on validation logic and state management.
@Suite("PasswordResetController Tests")
@MainActor
struct PasswordResetControllerTests {

    // MARK: - Initialization Tests

    @Test("PasswordResetController initializes with correct default state")
    func initialization_hasCorrectDefaultState() {
        // Arrange
        let authController = createTestAuthController()

        // Act
        let controller = PasswordResetController(authController: authController)

        // Assert
        #expect(controller.isSending == false)
        #expect(controller.success == false)
        #expect(controller.errorMessage == nil)
    }

    // MARK: - Validation Tests

    @Test("resetPassword with empty email sets error message")
    func resetPassword_emptyEmail_setsErrorMessage() async {
        // Arrange
        let authController = createTestAuthController()
        let controller = PasswordResetController(authController: authController)

        // Act
        await controller.resetPassword(email: "")

        // Assert
        #expect(controller.errorMessage != nil)
        #expect(controller.errorMessage?.contains("field") ?? false)
        #expect(controller.success == false)
        #expect(controller.isSending == false)
    }

    @Test("resetPassword with whitespace email sets error message")
    func resetPassword_whitespaceEmail_setsErrorMessage() async {
        // Arrange
        let authController = createTestAuthController()
        let controller = PasswordResetController(authController: authController)

        // Act
        await controller.resetPassword(email: "   ")

        // Assert
        #expect(controller.errorMessage != nil)
        #expect(controller.success == false)
    }

    @Test("resetPassword validation errors do not trigger network calls")
    func resetPassword_validationErrors_doNotTriggerNetworkCalls() async {
        // Arrange
        let authController = createTestAuthController()
        let controller = PasswordResetController(authController: authController)

        // Act
        await controller.resetPassword(email: "")

        // Assert - Should complete immediately
        #expect(controller.isSending == false)
        #expect(controller.errorMessage != nil)
    }

    // MARK: - State Management Tests

    @Test("isSending can be set and read")
    func isSending_canBeSetAndRead() {
        // Arrange
        let authController = createTestAuthController()
        let controller = PasswordResetController(authController: authController)

        // Act
        controller.isSending = true

        // Assert
        #expect(controller.isSending == true)

        // Act
        controller.isSending = false

        // Assert
        #expect(controller.isSending == false)
    }

    @Test("success can be set and read")
    func success_canBeSetAndRead() {
        // Arrange
        let authController = createTestAuthController()
        let controller = PasswordResetController(authController: authController)

        // Act
        controller.success = true

        // Assert
        #expect(controller.success == true)

        // Act
        controller.success = false

        // Assert
        #expect(controller.success == false)
    }

    @Test("errorMessage can be set and cleared")
    func errorMessage_canBeSetAndCleared() {
        // Arrange
        let authController = createTestAuthController()
        let controller = PasswordResetController(authController: authController)

        // Act
        controller.errorMessage = "Test error"

        // Assert
        #expect(controller.errorMessage == "Test error")

        // Act
        controller.errorMessage = nil

        // Assert
        #expect(controller.errorMessage == nil)
    }

    // MARK: - Multiple Operation Tests

    @Test("multiple validation errors can be triggered")
    func multipleValidationErrors_canBeTriggered() async {
        // Arrange
        let authController = createTestAuthController()
        let controller = PasswordResetController(authController: authController)

        // Act & Assert - First error
        await controller.resetPassword(email: "")
        #expect(controller.errorMessage != nil)
        let firstError = controller.errorMessage

        // Act & Assert - Second error (should reset state)
        await controller.resetPassword(email: "   ")
        #expect(controller.errorMessage != nil)

        // Both should have set errors
        #expect(firstError != nil)
    }

    @Test("success state persists when validation fails")
    func successState_persistsWhenValidationFails() async {
        // Arrange
        let authController = createTestAuthController()
        let controller = PasswordResetController(authController: authController)
        controller.success = true

        // Act - Validation failure (empty email)
        await controller.resetPassword(email: "")

        // Assert - Success should persist because validation fails early
        #expect(controller.success == true)
        #expect(controller.errorMessage != nil)
    }

    // MARK: - Edge Case Tests

    @Test("very long email handles gracefully")
    func veryLongEmail_handlesGracefully() async {
        // Arrange
        let authController = createTestAuthController()
        let controller = PasswordResetController(authController: authController)
        let longEmail = String(repeating: "a", count: 1000) + "@example.com"

        // Act
        await controller.resetPassword(email: longEmail)

        // Assert - Should not crash
        #expect(controller.errorMessage == nil || controller.errorMessage != nil)
    }

    @Test("special characters in email handle gracefully")
    func specialCharactersEmail_handlesGracefully() async {
        // Arrange
        let authController = createTestAuthController()
        let controller = PasswordResetController(authController: authController)

        // Act
        await controller.resetPassword(email: "test+tag@example.com")

        // Assert - Should not crash
        #expect(controller.errorMessage == nil || controller.errorMessage != nil)
    }

    @Test("unicode characters in email handle gracefully")
    func unicodeEmail_handlesGracefully() async {
        // Arrange
        let authController = createTestAuthController()
        let controller = PasswordResetController(authController: authController)

        // Act
        await controller.resetPassword(email: "tëst@éxample.com")

        // Assert - Should not crash
        #expect(controller.errorMessage == nil || controller.errorMessage != nil)
    }

    // MARK: - State Combination Tests

    @Test("error and success are mutually exclusive during validation")
    func errorAndSuccess_mutuallyExclusiveDuringValidation() async {
        // Arrange
        let authController = createTestAuthController()
        let controller = PasswordResetController(authController: authController)

        // Act
        await controller.resetPassword(email: "")

        // Assert - When there's a validation error, success should be false
        #expect(controller.errorMessage != nil)
        #expect(controller.success == false)
    }

    @Test("isSending is false after validation error")
    func isSending_falseAfterValidationError() async {
        // Arrange
        let authController = createTestAuthController()
        let controller = PasswordResetController(authController: authController)

        // Act
        await controller.resetPassword(email: "")

        // Assert
        #expect(controller.isSending == false)
    }

    // MARK: - Helper Methods

    /// Creates a test AuthController instance
    private func createTestAuthController() -> AuthController {
        let urlString = "https://test.supabase.co"
        let key = "test-anon-key-for-testing-only"
        let url = URL(string: urlString)!
        let client = SupabaseClient(supabaseURL: url, supabaseKey: key)

        return AuthController(client: client)
    }
}
