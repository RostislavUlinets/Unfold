import Testing
@testable import Unfold

struct EmailValidatorTests {

    // MARK: - Valid Email Tests

    @Test func validEmailFormats() {
        for email in TestConstants.ValidData.emails {
            #expect(EmailValidator.isValid(email), "Expected '\(email)' to be valid")
        }
    }

    @Test func standardEmailFormat() {
        #expect(EmailValidator.isValid("user@example.com"))
    }

    @Test func emailWithDots() {
        #expect(EmailValidator.isValid("first.last@example.com"))
    }

    @Test func emailWithPlus() {
        #expect(EmailValidator.isValid("user+tag@example.com"))
    }

    @Test func emailWithUnderscore() {
        #expect(EmailValidator.isValid("user_name@example.com"))
    }

    @Test func emailWithHyphenInDomain() {
        #expect(EmailValidator.isValid("user@my-domain.com"))
    }

    @Test func emailWithSubdomain() {
        #expect(EmailValidator.isValid("user@mail.example.com"))
    }

    @Test func emailWithMultipleSubdomains() {
        #expect(EmailValidator.isValid("user@mail.subdomain.example.com"))
    }

    @Test func emailWithNumbers() {
        #expect(EmailValidator.isValid("user123@example456.com"))
    }

    @Test func emailWithTwoLetterTLD() {
        #expect(EmailValidator.isValid("user@example.co"))
    }

    @Test func emailWithLongTLD() {
        #expect(EmailValidator.isValid("user@example.museum"))
    }

    // MARK: - Invalid Email Tests

    @Test func invalidEmailFormats() {
        for email in TestConstants.InvalidData.emails {
            #expect(!EmailValidator.isValid(email), "Expected '\(email)' to be invalid")
        }
    }

    @Test func emptyString() {
        #expect(!EmailValidator.isValid(""))
    }

    @Test func missingAtSymbol() {
        #expect(!EmailValidator.isValid("userexample.com"))
    }

    @Test func missingUsername() {
        #expect(!EmailValidator.isValid("@example.com"))
    }

    @Test func missingDomain() {
        #expect(!EmailValidator.isValid("user@"))
    }

    @Test func missingTLD() {
        #expect(!EmailValidator.isValid("user@example"))
    }

    @Test func doubleAtSymbol() {
        #expect(!EmailValidator.isValid("user@@example.com"))
    }

    @Test func spaceInEmail() {
        #expect(!EmailValidator.isValid("user @example.com"))
    }

    @Test func spaceInDomain() {
        #expect(!EmailValidator.isValid("user@exam ple.com"))
    }

    @Test func dotAtStart() {
        // Note: Current regex allows dot at start
        #expect(EmailValidator.isValid(".user@example.com"))
    }

    @Test func dotAtEnd() {
        // Note: Current regex allows dot at end of username
        #expect(EmailValidator.isValid("user.@example.com"))
    }

    @Test func consecutiveDots() {
        // Note: Current regex allows consecutive dots in username
        #expect(EmailValidator.isValid("user..name@example.com"))
    }

    @Test func invalidCharacters() {
        #expect(!EmailValidator.isValid("user!name@example.com"))
        #expect(!EmailValidator.isValid("user#name@example.com"))
        #expect(!EmailValidator.isValid("user$name@example.com"))
    }

    @Test func tldTooLong() {
        // TLD max length is 64 characters per regex
        let tld = String(repeating: "a", count: 65)
        #expect(!EmailValidator.isValid("user@example.\(tld)"))
    }

    @Test func onlyWhitespace() {
        #expect(!EmailValidator.isValid("   "))
    }
}
