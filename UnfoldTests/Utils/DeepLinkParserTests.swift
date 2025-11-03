import Testing
import Foundation
@testable import Unfold

struct DeepLinkParserTests {

    // MARK: - Valid Password Reset URL Tests

    @Test func parsePasswordResetWithCodeParameter() {
        let url = TestConstants.DeepLinks.validResetWithCode
        let result = DeepLinkParser.parse(url)

        guard case .passwordReset(let token) = result else {
            Issue.record("Expected passwordReset, got \(result)")
            return
        }

        #expect(token.token == "abc123def456")
        #expect(token.isValid)
    }

    @Test func parsePasswordResetWithTokenParameter() {
        let url = TestConstants.DeepLinks.validResetWithToken
        let result = DeepLinkParser.parse(url)

        guard case .passwordReset(let token) = result else {
            Issue.record("Expected passwordReset, got \(result)")
            return
        }

        #expect(token.token == "xyz789")
        #expect(token.isValid)
    }

    @Test func parsePasswordResetWithTokenHashParameter() {
        let url = TestConstants.DeepLinks.validResetWithTokenHash
        let result = DeepLinkParser.parse(url)

        guard case .passwordReset(let token) = result else {
            Issue.record("Expected passwordReset, got \(result)")
            return
        }

        #expect(token.token == "hash123")
        #expect(token.isValid)
    }

    @Test func parsePasswordResetWithAccessTokenParameter() {
        let url = TestConstants.DeepLinks.validResetWithAccessToken
        let result = DeepLinkParser.parse(url)

        guard case .passwordReset(let token) = result else {
            Issue.record("Expected passwordReset, got \(result)")
            return
        }

        #expect(token.token == "access123")
        #expect(token.isValid)
    }

    // MARK: - Parameter Priority Tests

    @Test func codeParameterHasPriority() {
        // When multiple parameters exist, 'code' should be found first
        let url = URL(string: "unfold://reset-password?code=first&token=second")!
        let result = DeepLinkParser.parse(url)

        guard case .passwordReset(let token) = result else {
            Issue.record("Expected passwordReset")
            return
        }

        #expect(token.token == "first")
    }

    @Test func tokenParameterUsedWhenCodeMissing() {
        let url = URL(string: "unfold://reset-password?token=mytoken&access_token=other")!
        let result = DeepLinkParser.parse(url)

        guard case .passwordReset(let token) = result else {
            Issue.record("Expected passwordReset")
            return
        }

        #expect(token.token == "mytoken")
    }

    // MARK: - Invalid URL Tests

    @Test func parseURLWithoutToken() {
        let url = TestConstants.DeepLinks.invalidNoToken
        let result = DeepLinkParser.parse(url)

        guard case .unknown = result else {
            Issue.record("Expected unknown for URL without token")
            return
        }
    }

    @Test func parseURLWithWrongPath() {
        let url = TestConstants.DeepLinks.invalidWrongPath
        let result = DeepLinkParser.parse(url)

        guard case .unknown = result else {
            Issue.record("Expected unknown for wrong path")
            return
        }
    }

    @Test func parseURLWithWrongParameter() {
        let url = TestConstants.DeepLinks.invalidWrongParam
        let result = DeepLinkParser.parse(url)

        guard case .unknown = result else {
            Issue.record("Expected unknown for wrong parameter")
            return
        }
    }

    @Test func parseURLWithEmptyToken() {
        let url = TestConstants.DeepLinks.invalidEmptyToken
        let result = DeepLinkParser.parse(url)

        guard case .unknown = result else {
            Issue.record("Expected unknown for empty token")
            return
        }
    }

    // MARK: - Host vs Path Tests

    @Test func parseWithHostResetPassword() {
        let url = URL(string: "unfold://reset-password?token=abc123")!
        let result = DeepLinkParser.parse(url)

        guard case .passwordReset = result else {
            Issue.record("Expected passwordReset for host-based URL")
            return
        }
    }

    @Test func parseWithPathResetPassword() {
        let url = URL(string: "unfold://app/reset-password?token=abc123")!
        let result = DeepLinkParser.parse(url)

        guard case .passwordReset = result else {
            Issue.record("Expected passwordReset for path-based URL")
            return
        }
    }

    // MARK: - Token Validity Tests

    @Test func nonEmptyTokenIsValid() {
        let token = DeepLinkParser.PasswordResetToken(token: "abc123")
        #expect(token.isValid)
    }

    @Test func emptyTokenIsInvalid() {
        let token = DeepLinkParser.PasswordResetToken(token: "")
        #expect(!token.isValid)
    }

    @Test func whitespaceOnlyTokenIsValid() {
        // Whitespace is considered valid (not empty)
        let token = DeepLinkParser.PasswordResetToken(token: "   ")
        #expect(token.isValid)
    }

    // MARK: - Token Equality Tests

    @Test func tokensWithSameValueAreEqual() {
        let token1 = DeepLinkParser.PasswordResetToken(token: "abc123")
        let token2 = DeepLinkParser.PasswordResetToken(token: "abc123")

        #expect(token1 == token2)
    }

    @Test func tokensWithDifferentValuesAreNotEqual() {
        let token1 = DeepLinkParser.PasswordResetToken(token: "abc123")
        let token2 = DeepLinkParser.PasswordResetToken(token: "xyz789")

        #expect(token1 != token2)
    }

    // MARK: - Edge Cases

    @Test func parseURLWithSpecialCharactersInToken() {
        let url = URL(string: "unfold://reset-password?token=abc%2B123%2Fxyz%3D%3D")!
        let result = DeepLinkParser.parse(url)

        guard case .passwordReset(let token) = result else {
            Issue.record("Expected passwordReset")
            return
        }

        // URL encoding should be handled: %2B = +, %2F = /, %3D = =
        #expect(token.token == "abc+123/xyz==")
    }

    @Test func parseURLWithVeryLongToken() {
        let longToken = String(repeating: "a", count: 1000)
        let url = URL(string: "unfold://reset-password?token=\(longToken)")!
        let result = DeepLinkParser.parse(url)

        guard case .passwordReset(let token) = result else {
            Issue.record("Expected passwordReset")
            return
        }

        #expect(token.token == longToken)
        #expect(token.isValid)
    }

    @Test func parseURLWithMultipleTokenParameters() {
        // Only first matching parameter should be used
        let url = URL(string: "unfold://reset-password?token=first&token=second")!
        let result = DeepLinkParser.parse(url)

        guard case .passwordReset(let token) = result else {
            Issue.record("Expected passwordReset")
            return
        }

        #expect(token.token == "first")
    }

    @Test func parseURLWithExtraParameters() {
        let url = URL(string: "unfold://reset-password?token=abc123&extra=value&other=param")!
        let result = DeepLinkParser.parse(url)

        guard case .passwordReset(let token) = result else {
            Issue.record("Expected passwordReset")
            return
        }

        #expect(token.token == "abc123")
    }

    @Test func parseDifferentScheme() {
        let url = URL(string: "https://example.com/reset-password?token=abc123")!
        let result = DeepLinkParser.parse(url)

        // Path contains "reset-password", so it will match and extract token
        guard case .passwordReset(let token) = result else {
            Issue.record("Expected passwordReset since path contains reset-password")
            return
        }

        #expect(token.token == "abc123")
    }

    @Test func parseURLWithFragment() {
        let url = URL(string: "unfold://reset-password?token=abc123#section")!
        let result = DeepLinkParser.parse(url)

        guard case .passwordReset(let token) = result else {
            Issue.record("Expected passwordReset")
            return
        }

        #expect(token.token == "abc123")
    }

    // MARK: - DeepLinkType Matching Tests

    @Test func unknownTypeDoesNotMatchPasswordReset() {
        let result = DeepLinkParser.DeepLinkType.unknown

        if case .passwordReset = result {
            Issue.record("Unknown should not match passwordReset")
        }
    }

    @Test func passwordResetTypeMatchesCorrectly() {
        let token = DeepLinkParser.PasswordResetToken(token: "test")
        let result = DeepLinkParser.DeepLinkType.passwordReset(token)

        if case .passwordReset(let extractedToken) = result {
            #expect(extractedToken.token == "test")
        } else {
            Issue.record("Expected passwordReset type")
        }
    }
}
