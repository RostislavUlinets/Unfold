# Testing Guide

This document provides comprehensive guidance on testing practices for the Unfold project.

## Overview

Unfold uses the **Swift Testing** framework (introduced in Swift 5.9) with modern `@Test` annotations and `#expect` assertions. We aim for high test coverage of business logic, validation, and state management.

## Test Statistics

- **Total Tests**: 156
- **Test Files**: 11
- **Coverage**: 80%+ of testable business logic
- **CI Status**: ✅ All tests passing

## Test Structure

```
UnfoldTests/
├── Utilities/
│   ├── EmailValidatorTests.swift          (23 tests)
│   ├── PasswordValidatorTests.swift       (37 tests)
│   └── DeepLinkParserTests.swift          (23 tests)
├── Model/
│   └── UserTests.swift                    (14 tests)
├── Controller/
│   ├── AuthControllerTests.swift          (30 tests)
│   ├── LocationControllerTests.swift      (18 tests)
│   ├── PasswordResetControllerTests.swift (13 tests)
│   └── PasswordResetConfirmationControllerTests.swift (33 tests)
└── Helpers/
    └── TestConstants.swift                (shared test data)
```

## Testing Philosophy

### What We Test

✅ **Validation Logic**
- Email validation rules
- Password validation and strength calculation
- Deep link parsing logic
- Form validation shortcuts

✅ **State Management**
- @Published property changes
- Computed properties
- State transitions
- Observable object behavior

✅ **Business Logic**
- Controller validation logic
- Error handling patterns
- Model computed properties (displayNameOrEmail, initials)

✅ **Edge Cases**
- Empty strings, whitespace
- Unicode characters, emoji
- Very long inputs
- Special characters
- Boundary conditions

### What We Don't Test (Currently)

❌ **Network Calls** - Controllers use concrete Supabase types, making mocking difficult
❌ **UI Behavior** - SwiftUI views (testing through UI tests is planned)
❌ **CoreLocation** - Real GPS hardware interactions
❌ **External Services** - Supabase backend integration

## Testing Patterns

### 1. Swift Testing Framework

Use modern Swift Testing syntax:

```swift
import Testing
@testable import Unfold

@Suite("Email Validator Tests")
struct EmailValidatorTests {

    @Test("Valid email formats are accepted")
    func validEmail_returnsTrue() {
        #expect(EmailValidator.isValid("user@example.com") == true)
        #expect(EmailValidator.isValid("test.user@example.co.uk") == true)
    }

    @Test("Invalid email formats are rejected")
    func invalidEmail_returnsFalse() {
        #expect(EmailValidator.isValid("notanemail") == false)
        #expect(EmailValidator.isValid("@example.com") == false)
    }
}
```

### 2. MainActor Testing

Controllers are @MainActor-isolated, so tests must be too:

```swift
@Suite("Auth Controller Tests")
@MainActor
struct AuthControllerTests {

    @Test("Login with empty email sets error")
    func login_emptyEmail_setsError() async {
        let controller = createTestController()
        await controller.login(email: "", password: "Pass123!")

        #expect(controller.errorMessage != nil)
    }
}
```

### 3. Test Organization

Follow this structure for each test:

```swift
@Test("Description of what is being tested")
func testName_condition_expectedResult() {
    // Arrange - Set up test data and dependencies
    let controller = createTestController()

    // Act - Execute the code under test
    await controller.someAction()

    // Assert - Verify the results
    #expect(controller.someProperty == expectedValue)
}
```

### 4. Helper Functions

Use private helper functions to reduce duplication:

```swift
@Suite("Password Reset Controller Tests")
@MainActor
struct PasswordResetControllerTests {

    @Test("Reset with empty email sets error")
    func resetPassword_emptyEmail_setsError() async {
        let controller = createTestController()
        // ... test implementation
    }

    // MARK: - Helper Methods

    private func createTestController() -> PasswordResetController {
        let authController = createTestAuthController()
        return PasswordResetController(authController: authController)
    }

    private func createTestAuthController() -> AuthController {
        let url = URL(string: "https://test.supabase.co")!
        let client = SupabaseClient(supabaseURL: url, supabaseKey: "test-key")
        return AuthController(client: client)
    }
}
```

### 5. Test Data Constants

Use `TestConstants.swift` for reusable test data:

```swift
struct TestConstants {
    struct ValidData {
        static let emails = ["user@example.com", "test@domain.co.uk"]
        static let passwords = ["SecurePass123!", "MyP@ssw0rd"]
    }

    struct InvalidData {
        static let emails = ["", "notanemail", "@example.com"]
        static let passwords = ["short", "NoSpecial123"]
    }
}
```

Usage:

```swift
@Test("Valid emails pass validation")
func validEmails_returnTrue() {
    for email in TestConstants.ValidData.emails {
        #expect(EmailValidator.isValid(email) == true)
    }
}
```

## Running Tests

### Command Line

```bash
# Run all unit tests
xcodebuild test \
  -scheme Unfold \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:UnfoldTests

# Run specific test file
xcodebuild test \
  -scheme Unfold \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:UnfoldTests/EmailValidatorTests

# Run specific test
xcodebuild test \
  -scheme Unfold \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:UnfoldTests/EmailValidatorTests/validEmail_returnsTrue

# Run with code coverage
xcodebuild test \
  -scheme Unfold \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -enableCodeCoverage YES
```

### Xcode

1. Open `Unfold.xcodeproj` in Xcode
2. Press `⌘+U` to run all tests
3. Or navigate to Test Navigator (⌘+6) and click individual tests

### CI/CD

Tests run automatically on:
- Every push to `main` or `develop`
- Every pull request
- See `.github/workflows/test.yml` for configuration

## Test Coverage

### Current Coverage

| Component | Tests | Coverage |
|-----------|-------|----------|
| EmailValidator | 23 | 100% |
| PasswordValidator | 37 | 100% |
| DeepLinkParser | 23 | 100% |
| User Model | 14 | 100% |
| AuthController | 30 | ~80% (validation only) |
| LocationController | 18 | ~70% (state only) |
| PasswordResetController | 13 | ~80% (validation only) |
| PasswordResetConfirmationController | 33 | ~90% (validation + state) |

### Viewing Coverage

```bash
# Generate coverage report
xcodebuild test \
  -scheme Unfold \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -enableCodeCoverage YES

# Find the .xcresult bundle
find ~/Library/Developer/Xcode/DerivedData -name "*.xcresult"

# Extract coverage data
xcrun xccov view --report <path-to-xcresult>
```

In Xcode:
1. Run tests with code coverage enabled
2. Show Report Navigator (⌘+9)
3. Select test run
4. Click "Coverage" tab

## Best Practices

### ✅ DO

- Write descriptive test names that explain what is being tested
- Test one thing per test function
- Use the Arrange-Act-Assert pattern
- Test edge cases (empty, nil, very long inputs, unicode)
- Use helper functions to reduce duplication
- Mark async tests with `async` keyword
- Use `@MainActor` for controller tests
- Focus on testing business logic, not implementation details

### ❌ DON'T

- Don't test private implementation details
- Don't test SwiftUI views directly (use UI tests instead)
- Don't make network calls in unit tests
- Don't test third-party frameworks (trust their tests)
- Don't write overly complex tests
- Don't use `XCTAssert` - use `#expect` instead
- Don't use `XCTestCase` - use `@Suite` and `@Test` instead

## Common Testing Scenarios

### Testing Validation Logic

```swift
@Test("Password must be at least 8 characters")
func shortPassword_isInvalid() {
    #expect(PasswordValidator.isValid("short") == false)
}

@Test("Valid password passes validation")
func validPassword_isValid() {
    #expect(PasswordValidator.isValid("SecurePass123!") == true)
}
```

### Testing Computed Properties

```swift
@Test("User initials from full name")
func initials_withFullName_returnsFirstTwoInitials() {
    let user = User(
        id: "123",
        email: "john@example.com",
        displayName: "John Doe",
        profilePictureURL: nil,
        createdAt: Date()
    )

    #expect(user.initials == "JD")
}
```

### Testing State Management

```swift
@Test("isLoading can be toggled")
func isLoading_canBeToggled() {
    let controller = createTestController()

    controller.isLoading = true
    #expect(controller.isLoading == true)

    controller.isLoading = false
    #expect(controller.isLoading == false)
}
```

### Testing Async Functions

```swift
@Test("Login with empty email sets error")
func login_emptyEmail_setsError() async {
    let controller = createTestController()

    await controller.login(email: "", password: "Pass123!")

    #expect(controller.errorMessage != nil)
    #expect(controller.isLoading == false)
}
```

### Testing Error Handling

```swift
@Test("Error message can be cleared")
func clearError_clearsErrorMessage() {
    let controller = createTestController()
    controller.errorMessage = "Test error"

    controller.clearError()

    #expect(controller.errorMessage == nil)
}
```

## Continuous Improvement

### Adding New Tests

When adding a new feature:

1. Write tests first (TDD approach recommended)
2. Test validation logic
3. Test state management
4. Test edge cases
5. Test error handling
6. Run tests locally before committing
7. Ensure CI passes on PR

### Maintaining Tests

- Keep tests up to date with code changes
- Refactor tests when refactoring code
- Remove obsolete tests
- Update TestConstants when adding new test data
- Monitor code coverage and add tests for uncovered code

## Resources

- [Swift Testing Documentation](https://developer.apple.com/documentation/testing)
- [Testing in Xcode](https://developer.apple.com/documentation/xcode/testing-your-apps-in-xcode)
- [Swift Testing Tutorial](https://www.hackingwithswift.com/swift/testing)

## Questions?

For questions about testing:
1. Check this guide first
2. Look at existing test files for examples
3. Refer to Swift Testing documentation
4. Open an issue on GitHub

---

**Last Updated**: November 2024
**Test Coverage**: 80%+
**Total Tests**: 156
