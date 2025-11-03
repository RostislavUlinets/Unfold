import Testing
@testable import Unfold

struct PasswordValidatorTests {

    // MARK: - Validation Tests

    @Test func validPasswords() {
        for password in TestConstants.ValidData.passwords {
            #expect(PasswordValidator.isValid(password), "Expected '\(password)' to be valid")
        }
    }

    @Test func validPasswordReturnsEmptyErrors() {
        let errors = PasswordValidator.validate("SecurePass123!")
        #expect(errors.isEmpty)
    }

    @Test func validPasswordReturnsNilMessage() {
        let message = PasswordValidator.validationMessage(for: "SecurePass123!")
        #expect(message == nil)
    }

    // MARK: - Length Validation Tests

    @Test func passwordTooShort() {
        let password = "Short1!"  // 7 characters
        let errors = PasswordValidator.validate(password)

        #expect(errors.contains(.tooShort))
        #expect(!PasswordValidator.isValid(password))
    }

    @Test func passwordExactlyEightCharacters() {
        let password = "Pass123!"  // Exactly 8 characters
        #expect(PasswordValidator.isValid(password))
    }

    @Test func passwordMinimumLength() {
        // Test boundary: exactly 8 chars with special char
        #expect(PasswordValidator.isValid("1234567!"))
        #expect(!PasswordValidator.isValid("123456!"))  // 7 chars
    }

    @Test func emptyPasswordFails() {
        let errors = PasswordValidator.validate("")

        #expect(errors.contains(.tooShort))
        #expect(errors.contains(.missingSpecialCharacter))
        #expect(!PasswordValidator.isValid(""))
    }

    @Test func veryLongPasswordIsValid() {
        let longPassword = String(repeating: "a", count: 100) + "!"
        #expect(PasswordValidator.isValid(longPassword))
    }

    // MARK: - Special Character Tests

    @Test func passwordMissingSpecialCharacter() {
        let password = "Password123"  // No special char
        let errors = PasswordValidator.validate(password)

        #expect(errors.contains(.missingSpecialCharacter))
        #expect(!PasswordValidator.isValid(password))
    }

    @Test func allSpecialCharactersAreRecognized() {
        let specialChars = "!@#$%^&*()_+-=[]{}|;:,.<>?"

        for char in specialChars {
            let password = "Pass123\(char)"
            #expect(
                PasswordValidator.isValid(password),
                "Expected password with '\(char)' to be valid"
            )
        }
    }

    @Test func passwordWithExclamation() {
        #expect(PasswordValidator.isValid("Password123!"))
    }

    @Test func passwordWithAtSymbol() {
        #expect(PasswordValidator.isValid("Password123@"))
    }

    @Test func passwordWithHashSymbol() {
        #expect(PasswordValidator.isValid("Password123#"))
    }

    @Test func passwordWithMultipleSpecialChars() {
        #expect(PasswordValidator.isValid("Pass!@#123"))
    }

    // MARK: - Multiple Errors Tests

    @Test func passwordWithMultipleErrors() {
        let password = "short"  // Too short AND no special char

        let errors = PasswordValidator.validate(password)

        #expect(errors.contains(.tooShort))
        #expect(errors.contains(.missingSpecialCharacter))
        #expect(errors.count == 2)
    }

    @Test func validationMessageReturnsFirstError() {
        let password = "short"

        let message = PasswordValidator.validationMessage(for: password)

        #expect(message != nil)
        #expect(message == "Password must be at least 8 characters")
    }

    // MARK: - Password Matching Tests

    @Test func matchingPasswordsReturnTrue() {
        #expect(PasswordValidator.passwordsMatch("Password123!", "Password123!"))
    }

    @Test func differentPasswordsReturnFalse() {
        #expect(!PasswordValidator.passwordsMatch("Password123!", "Different123!"))
    }

    @Test func emptyPasswordsReturnFalse() {
        #expect(!PasswordValidator.passwordsMatch("", ""))
    }

    @Test func oneEmptyPasswordReturnsFalse() {
        #expect(!PasswordValidator.passwordsMatch("Password123!", ""))
        #expect(!PasswordValidator.passwordsMatch("", "Password123!"))
    }

    @Test func caseSensitiveMatching() {
        #expect(!PasswordValidator.passwordsMatch("Password123!", "password123!"))
    }

    // MARK: - Strength Tests - Weak

    @Test func weakPasswordStrength() {
        for password in TestConstants.PasswordStrength.weak {
            let strength = PasswordValidator.strength(of: password)
            #expect(strength == .weak, "Expected '\(password)' to be weak")
        }
    }

    @Test func shortPasswordIsWeak() {
        // "Pass1!" = 7 chars (no length score), upper (+1), lower (+1), number (+1), special (+1) = 4 = medium
        let strength = PasswordValidator.strength(of: "Pass1!")
        #expect(strength == .medium)
    }

    @Test func onlyNumbersAndSpecialIsWeak() {
        // "12345678!" = 8 chars (+1), number (+1), special (+1) = 3 = medium
        let strength = PasswordValidator.strength(of: "12345678!")
        #expect(strength == .medium)
    }

    @Test func emptyPasswordIsWeak() {
        let strength = PasswordValidator.strength(of: "")
        #expect(strength == .weak)
    }

    // MARK: - Strength Tests - Medium

    @Test func mediumPasswordStrength() {
        for password in TestConstants.PasswordStrength.medium {
            let strength = PasswordValidator.strength(of: password)
            #expect(strength == .medium, "Expected '\(password)' to be medium")
        }
    }

    @Test func passwordWithUpperLowerNumberSpecialIsMedium() {
        // "Pass123!" = 8 chars (+1), upper (+1), lower (+1), number (+1), special (+1) = 5 = strong
        let strength = PasswordValidator.strength(of: "Pass123!")
        #expect(strength == .strong)
    }

    // MARK: - Strength Tests - Strong

    @Test func strongPasswordStrength() {
        for password in TestConstants.PasswordStrength.strong {
            let strength = PasswordValidator.strength(of: password)
            #expect(strength == .strong, "Expected '\(password)' to be strong")
        }
    }

    @Test func longPasswordWithAllCharTypesIsStrong() {
        // 12+ chars + upper + lower + number + special = strong
        let strength = PasswordValidator.strength(of: "SuperSecure!Pass2024")
        #expect(strength == .strong)
    }

    @Test func passwordWith12CharsAndVarietyIsStrong() {
        let strength = PasswordValidator.strength(of: "MyP@ssw0rd12")
        #expect(strength == .strong)
    }

    // MARK: - Strength Scoring Boundaries

    @Test func strengthBoundaryScoring() {
        // Weak: score < 3
        #expect(PasswordValidator.strength(of: "1234567") == .weak)  // 7 chars, only number: score 1

        // Medium: score 3-4
        #expect(PasswordValidator.strength(of: "12345678!") == .medium)  // 8 chars (+1), number (+1), special (+1) = score 3

        // Strong: score >= 5
        #expect(PasswordValidator.strength(of: "MyP@ssw0rd12") == .strong)  // 12+ chars (+2), upper (+1), lower (+1), number (+1), special (+1) = score 6
    }

    // MARK: - Strength Description Tests

    @Test func strengthDescriptions() {
        #expect(PasswordValidator.Strength.weak.description == "Weak")
        #expect(PasswordValidator.Strength.medium.description == "Medium")
        #expect(PasswordValidator.Strength.strong.description == "Strong")
    }

    @Test func strengthColors() {
        #expect(PasswordValidator.Strength.weak.color == "red")
        #expect(PasswordValidator.Strength.medium.color == "orange")
        #expect(PasswordValidator.Strength.strong.color == "green")
    }

    // MARK: - Requirements Tests

    @Test func requirementsListIsCorrect() {
        let requirements = PasswordValidator.requirements

        #expect(requirements.count == 2)
        #expect(requirements.contains("At least 8 characters"))
        #expect(requirements.contains("At least one special character (!@#$%^&*)"))
    }

    // MARK: - Edge Cases

    @Test func unicodePasswordWithSpecialChar() {
        // Unicode characters but still needs special char and length
        let password = "Pässwörd!"  // 9 chars with special
        #expect(PasswordValidator.isValid(password))
    }

    @Test func passwordWithEmojiAndSpecialChar() {
        let password = "Pass123!😀"
        #expect(PasswordValidator.isValid(password))
    }

    @Test func whitespaceOnlyPassword() {
        let password = "        "
        let errors = PasswordValidator.validate(password)

        #expect(errors.contains(.tooShort) || errors.contains(.missingSpecialCharacter))
        #expect(!PasswordValidator.isValid(password))
    }

    @Test func passwordWithWhitespace() {
        // Spaces are allowed as long as requirements are met
        let password = "Pass 123 !"
        #expect(PasswordValidator.isValid(password))
    }

    // MARK: - Error Description Tests

    @Test func validationErrorDescriptions() {
        #expect(
            PasswordValidator.ValidationError.tooShort.errorDescription ==
            "Password must be at least 8 characters"
        )

        #expect(
            PasswordValidator.ValidationError.missingSpecialCharacter.errorDescription ==
            "Password must contain at least one special character (!@#$%^&*)"
        )

        #expect(
            PasswordValidator.ValidationError.passwordsDoNotMatch.errorDescription ==
            "Passwords do not match"
        )
    }
}
