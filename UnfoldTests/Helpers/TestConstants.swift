import Foundation

/// Reusable test constants for all test files
struct TestConstants {

    // MARK: - Valid Test Data

    struct ValidData {
        static let emails = [
            "user@example.com",
            "test.user@example.com",
            "user+tag@example.co.uk",
            "user_name@example-domain.com",
            "123@example.com",
            "user@sub.example.com"
        ]

        static let passwords = [
            "SecurePass123!",
            "MyP@ssw0rd",
            "Test123!@#",
            "Strong!Pass99"
        ]

        static let tokens = [
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9",
            "1234567890abcdef",
            "reset-token-abc123",
            "pkce-code-verifier-example"
        ]

        static let resetURLs = [
            "unfold://reset-password?code=abc123",
            "unfold://reset-password?token=xyz789",
            "unfold://reset-password?token_hash=hash123",
            "unfold://reset-password?access_token=access123"
        ]
    }

    // MARK: - Invalid Test Data

    struct InvalidData {
        static let emails = [
            "",
            "notanemail",
            "@example.com",
            "user@",
            "user@.com",
            "user @example.com",
            "user@example",
            "user@@example.com"
        ]

        static let passwords = [
            "",
            "short",
            "no special chars 123",
            "NoNumbers!",
            "1234567"  // Too short, no special char
        ]

        static let urls = [
            "unfold://reset-password",  // No token
            "unfold://other-path?token=abc",  // Wrong path
            "https://example.com?token=abc",  // Wrong scheme
            "unfold://reset-password?other=value"  // Wrong param
        ]
    }

    // MARK: - Edge Cases

    struct EdgeCases {
        static let emptyString = ""
        static let whitespace = "   "
        static let veryLongPassword = String(repeating: "a", count: 1000) + "!"
        static let unicodePassword = "Pässwörd123!"
        static let emojiPassword = "Pass123!😀"

        static let specialChars = "!@#$%^&*()_+-=[]{}|;:,.<>?"
        static let allSpecialCharPasswords = specialChars.map { "Pass123\($0)" }
    }

    // MARK: - Password Strength Examples
    // Score calculation: length>=8 (+1), length>=12 (+1), upper (+1), lower (+1), number (+1), special (+1)
    // weak: score < 3, medium: score 3-4, strong: score >= 5

    struct PasswordStrength {
        static let weak = [
            "1234567",      // 7 chars, only number: score 1
            "abcdefg",      // 7 chars, only lower: score 1
            "ABCDEFG"       // 7 chars, only upper: score 1
        ]

        static let medium = [
            "12345678!",        // 8 chars (+1), number (+1), special (+1) = score 3
            "abcdefgh!",        // 8 chars (+1), lower (+1), special (+1) = score 3
            "Abcdefgh1"         // 8 chars (+1), upper (+1), lower (+1), number (+1) = score 4
        ]

        static let strong = [
            "Pass123!",                 // 8 chars (+1), upper (+1), lower (+1), number (+1), special (+1) = score 5
            "SuperSecure!Pass2024",     // 12+ chars (+2), upper (+1), lower (+1), number (+1), special (+1) = score 6
            "MyP@ssw0rd12"              // 12+ chars (+2), upper (+1), lower (+1), number (+1), special (+1) = score 6
        ]
    }

    // MARK: - Deep Link URLs

    struct DeepLinks {
        static let validResetWithCode = URL(string: "unfold://reset-password?code=abc123def456")!
        static let validResetWithToken = URL(string: "unfold://reset-password?token=xyz789")!
        static let validResetWithTokenHash = URL(string: "unfold://reset-password?token_hash=hash123")!
        static let validResetWithAccessToken = URL(string: "unfold://reset-password?access_token=access123")!

        static let invalidNoToken = URL(string: "unfold://reset-password")!
        static let invalidWrongPath = URL(string: "unfold://other-page?token=abc")!
        static let invalidWrongParam = URL(string: "unfold://reset-password?wrong=value")!
        static let invalidEmptyToken = URL(string: "unfold://reset-password?token=")!
    }
}
