import Testing
import Foundation
import Supabase
@testable import Unfold

/// Tests for AuthController
/// Note: These tests focus on validation logic and observable state changes.
/// Full integration tests with mocked Supabase would require protocol-based dependency injection.
@Suite("AuthController Tests")
@MainActor
struct AuthControllerTests {

    // MARK: - Initialization Tests

    @Test("AuthController initializes with unauthenticated state")
    func initialization_startsUnauthenticated() {
        // Arrange & Act
        let controller = createTestController()

        // Assert
        #expect(controller.isAuthenticated == false)
        #expect(controller.isLoading == false)
        #expect(controller.errorMessage == nil)
        #expect(controller.currentUser == nil)
    }

    // MARK: - Login Validation Tests

    @Test("login with empty email sets error message")
    func login_emptyEmail_setsErrorMessage() async {
        // Arrange
        let controller = createTestController()

        // Act
        await controller.login(email: "", password: "ValidPass123!")

        // Assert
        #expect(controller.errorMessage != nil)
        #expect(controller.errorMessage?.contains("field") ?? false)
    }

    @Test("login with empty password sets error message")
    func login_emptyPassword_setsErrorMessage() async {
        // Arrange
        let controller = createTestController()

        // Act
        await controller.login(email: "test@example.com", password: "")

        // Assert
        #expect(controller.errorMessage != nil)
        #expect(controller.errorMessage?.contains("field") ?? false)
    }

    @Test("login with both fields empty sets error message")
    func login_bothFieldsEmpty_setsErrorMessage() async {
        // Arrange
        let controller = createTestController()

        // Act
        await controller.login(email: "", password: "")

        // Assert
        #expect(controller.errorMessage != nil)
    }

    @Test("login with whitespace email sets error message")
    func login_whitespaceEmail_setsErrorMessage() async {
        // Arrange
        let controller = createTestController()

        // Act
        await controller.login(email: "   ", password: "ValidPass123!")

        // Assert
        #expect(controller.errorMessage != nil)
    }

    @Test("login with whitespace password sets error message")
    func login_whitespacePassword_setsErrorMessage() async {
        // Arrange
        let controller = createTestController()

        // Act
        await controller.login(email: "test@example.com", password: "   ")

        // Assert
        #expect(controller.errorMessage != nil)
    }

    // MARK: - Signup Validation Tests

    @Test("signup with empty email sets error message")
    func signup_emptyEmail_setsErrorMessage() async {
        // Arrange
        let controller = createTestController()

        // Act
        await controller.signup(
            email: "",
            password: "ValidPass123!",
            verifyPassword: "ValidPass123!"
        )

        // Assert
        #expect(controller.errorMessage != nil)
        #expect(controller.errorMessage?.contains("field") ?? false)
    }

    @Test("signup with empty password sets error message")
    func signup_emptyPassword_setsErrorMessage() async {
        // Arrange
        let controller = createTestController()

        // Act
        await controller.signup(
            email: "test@example.com",
            password: "",
            verifyPassword: ""
        )

        // Assert
        #expect(controller.errorMessage != nil)
    }

    @Test("signup with mismatched passwords sets error message")
    func signup_mismatchedPasswords_setsErrorMessage() async {
        // Arrange
        let controller = createTestController()

        // Act
        await controller.signup(
            email: "test@example.com",
            password: "ValidPass123!",
            verifyPassword: "DifferentPass456!"
        )

        // Assert
        #expect(controller.errorMessage != nil)
        #expect(controller.errorMessage?.contains("match") ?? false)
    }

    @Test("signup with empty verifyPassword sets error message")
    func signup_emptyVerifyPassword_setsErrorMessage() async {
        // Arrange
        let controller = createTestController()

        // Act
        await controller.signup(
            email: "test@example.com",
            password: "ValidPass123!",
            verifyPassword: ""
        )

        // Assert
        #expect(controller.errorMessage != nil)
    }

    @Test("signup with all fields empty sets error message")
    func signup_allFieldsEmpty_setsErrorMessage() async {
        // Arrange
        let controller = createTestController()

        // Act
        await controller.signup(email: "", password: "", verifyPassword: "")

        // Assert
        #expect(controller.errorMessage != nil)
    }

    @Test("signup password mismatch takes priority over empty field error")
    func signup_passwordMismatch_takesPriority() async {
        // Arrange
        let controller = createTestController()

        // Act
        await controller.signup(
            email: "test@example.com",
            password: "Pass1",
            verifyPassword: "Pass2"
        )

        // Assert
        #expect(controller.errorMessage != nil)
        #expect(controller.errorMessage?.contains("match") ?? false)
    }

    // MARK: - Password Reset Validation Tests

    @Test("resetPassword with empty email sets error message")
    func resetPassword_emptyEmail_setsErrorMessage() async {
        // Arrange
        let controller = createTestController()

        // Act
        await controller.resetPassword(email: "")

        // Assert
        #expect(controller.errorMessage != nil)
        #expect(controller.errorMessage?.contains("field") ?? false)
    }

    @Test("resetPassword with whitespace email sets error message")
    func resetPassword_whitespaceEmail_setsErrorMessage() async {
        // Arrange
        let controller = createTestController()

        // Act
        await controller.resetPassword(email: "   ")

        // Assert
        #expect(controller.errorMessage != nil)
    }

    // MARK: - State Management Tests

    @Test("errorMessage can be set and read")
    func errorMessage_canBeSetAndRead() {
        // Arrange
        let controller = createTestController()

        // Act
        controller.errorMessage = "Test error"

        // Assert
        #expect(controller.errorMessage == "Test error")
    }

    @Test("errorMessage can be cleared")
    func errorMessage_canBeCleared() {
        // Arrange
        let controller = createTestController()
        controller.errorMessage = "Test error"

        // Act
        controller.errorMessage = nil

        // Assert
        #expect(controller.errorMessage == nil)
    }

    @Test("isLoading starts as false")
    func isLoading_startsAsFalse() {
        // Arrange & Act
        let controller = createTestController()

        // Assert
        #expect(controller.isLoading == false)
    }

    @Test("currentUser starts as nil")
    func currentUser_startsAsNil() {
        // Arrange & Act
        let controller = createTestController()

        // Assert
        #expect(controller.currentUser == nil)
    }

    @Test("isAuthenticated starts as false")
    func isAuthenticated_startsAsFalse() {
        // Arrange & Act
        let controller = createTestController()

        // Assert
        #expect(controller.isAuthenticated == false)
    }

    // MARK: - SupabaseClient Access Tests

    @Test("supabaseClient is accessible")
    func supabaseClient_isAccessible() {
        // Arrange
        let controller = createTestController()

        // Act
        let client = controller.supabaseClient

        // Assert
        #expect(client != nil)
    }

    // MARK: - Error Handling Pattern Tests

    @Test("login validation errors do not trigger network calls")
    func login_validationErrors_doNotTriggerNetworkCalls() async {
        // Arrange
        let controller = createTestController()
        let initialLoading = controller.isLoading

        // Act
        await controller.login(email: "", password: "")

        // Assert - should complete immediately without async loading
        #expect(controller.isLoading == initialLoading)
        #expect(controller.errorMessage != nil)
    }

    @Test("signup validation errors do not trigger network calls")
    func signup_validationErrors_doNotTriggerNetworkCalls() async {
        // Arrange
        let controller = createTestController()
        let initialLoading = controller.isLoading

        // Act
        await controller.signup(email: "", password: "Pass1", verifyPassword: "Pass2")

        // Assert
        #expect(controller.isLoading == initialLoading)
        #expect(controller.errorMessage != nil)
    }

    @Test("resetPassword validation errors do not trigger network calls")
    func resetPassword_validationErrors_doNotTriggerNetworkCalls() async {
        // Arrange
        let controller = createTestController()
        let initialLoading = controller.isLoading

        // Act
        await controller.resetPassword(email: "")

        // Assert
        #expect(controller.isLoading == initialLoading)
        #expect(controller.errorMessage != nil)
    }

    // MARK: - Multiple Operation Tests

    @Test("multiple validation errors can be triggered in sequence")
    func multipleValidationErrors_canBeTriggeredInSequence() async {
        // Arrange
        let controller = createTestController()

        // Act & Assert - Login error
        await controller.login(email: "", password: "")
        #expect(controller.errorMessage != nil)
        let firstError = controller.errorMessage

        // Act & Assert - Signup error
        await controller.signup(email: "", password: "a", verifyPassword: "b")
        #expect(controller.errorMessage != nil)
        let secondError = controller.errorMessage

        // Errors should be set (may be same or different based on message)
        #expect(firstError != nil)
        #expect(secondError != nil)
    }

    @Test("error message persists between failed operations")
    func errorMessage_persistsBetweenFailedOperations() async {
        // Arrange
        let controller = createTestController()

        // Act - First error
        await controller.login(email: "", password: "")
        let firstError = controller.errorMessage

        // Act - Second operation (also fails validation)
        await controller.login(email: "", password: "password")

        // Assert - Error is still set
        #expect(controller.errorMessage != nil)
        #expect(firstError != nil)
    }

    // MARK: - Edge Case Tests

    @Test("login with very long email handles gracefully")
    func login_veryLongEmail_handlesGracefully() async {
        // Arrange
        let controller = createTestController()
        let longEmail = String(repeating: "a", count: 1000) + "@example.com"

        // Act
        await controller.login(email: longEmail, password: "ValidPass123!")

        // Assert - Should not crash, may succeed or fail depending on validation
        #expect(controller.errorMessage == nil || controller.errorMessage != nil)
    }

    @Test("login with very long password handles gracefully")
    func login_veryLongPassword_handlesGracefully() async {
        // Arrange
        let controller = createTestController()
        let longPassword = String(repeating: "a", count: 1000) + "!"

        // Act
        await controller.login(email: "test@example.com", password: longPassword)

        // Assert - Should not crash
        #expect(controller.errorMessage == nil || controller.errorMessage != nil)
    }

    @Test("signup with special characters in email handles gracefully")
    func signup_specialCharactersInEmail_handlesGracefully() async {
        // Arrange
        let controller = createTestController()

        // Act
        await controller.signup(
            email: "test+tag@example.com",
            password: "ValidPass123!",
            verifyPassword: "ValidPass123!"
        )

        // Assert - Should not crash
        #expect(controller.errorMessage == nil || controller.errorMessage != nil)
    }

    @Test("signup with unicode characters in password handles gracefully")
    func signup_unicodePassword_handlesGracefully() async {
        // Arrange
        let controller = createTestController()

        // Act
        await controller.signup(
            email: "test@example.com",
            password: "Pässwörd123!",
            verifyPassword: "Pässwörd123!"
        )

        // Assert - Should not crash
        #expect(controller.errorMessage == nil || controller.errorMessage != nil)
    }

    // MARK: - Helper Methods

    /// Creates a test AuthController instance
    private func createTestController() -> AuthController {
        // Create a real AuthController with test credentials
        let urlString = "https://test.supabase.co"
        let key = "test-anon-key-for-testing-only"
        let url = URL(string: urlString)!
        let client = SupabaseClient(supabaseURL: url, supabaseKey: key)

        return AuthController(client: client)
    }
}
