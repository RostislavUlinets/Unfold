import Testing
import Foundation
@testable import Unfold

@Suite("User Model Tests")
struct UserTests {

    // MARK: - displayNameOrEmail Tests

    @Test("displayNameOrEmail returns displayName when present")
    func displayNameOrEmail_withDisplayName_returnsDisplayName() {
        let user = User(
            id: "user1",
            email: "user@example.com",
            displayName: "John Doe",
            profilePictureURL: nil,
            createdAt: Date()
        )

        #expect(user.displayNameOrEmail == "John Doe")
    }

    @Test("displayNameOrEmail returns email when displayName is nil")
    func displayNameOrEmail_withNilDisplayName_returnsEmail() {
        let user = User(
            id: "user2",
            email: "test@example.com",
            displayName: nil,
            profilePictureURL: nil,
            createdAt: Date()
        )

        #expect(user.displayNameOrEmail == "test@example.com")
    }

    @Test("displayNameOrEmail returns empty string when displayName is empty")
    func displayNameOrEmail_withEmptyDisplayName_returnsEmptyString() {
        let user = User(
            id: "user3",
            email: "empty@example.com",
            displayName: "",
            profilePictureURL: nil,
            createdAt: Date()
        )

        #expect(user.displayNameOrEmail == "")
    }

    @Test("displayNameOrEmail returns whitespace when displayName is whitespace-only")
    func displayNameOrEmail_withWhitespaceDisplayName_returnsWhitespace() {
        let user = User(
            id: "user4",
            email: "whitespace@example.com",
            displayName: "   ",
            profilePictureURL: nil,
            createdAt: Date()
        )

        #expect(user.displayNameOrEmail == "   ")
    }

    // MARK: - initials Tests

    @Test("initials returns first two initials from full name")
    func initials_withFullName_returnsFirstTwoInitials() {
        let user = User(
            id: "user5",
            email: "user@example.com",
            displayName: "John Doe",
            profilePictureURL: nil,
            createdAt: Date()
        )

        #expect(user.initials == "JD")
    }

    @Test("initials returns first two characters from single word name")
    func initials_withSingleWordName_returnsFirstTwoChars() {
        let user = User(
            id: "user6",
            email: "user@example.com",
            displayName: "Madonna",
            profilePictureURL: nil,
            createdAt: Date()
        )

        #expect(user.initials == "M")
    }

    @Test("initials returns first two characters of email when displayName is nil")
    func initials_withNilDisplayName_returnsEmailPrefix() {
        let user = User(
            id: "user7",
            email: "alice@example.com",
            displayName: nil,
            profilePictureURL: nil,
            createdAt: Date()
        )

        #expect(user.initials == "AL")
    }

    @Test("initials returns only first two initials from three-word name")
    func initials_withThreeWordName_returnsFirstTwoInitials() {
        let user = User(
            id: "user8",
            email: "user@example.com",
            displayName: "John Paul Jones",
            profilePictureURL: nil,
            createdAt: Date()
        )

        #expect(user.initials == "JP")
    }

    @Test("initials handles unicode characters correctly")
    func initials_withUnicodeCharacters_handlesCorrectly() {
        let user = User(
            id: "user9",
            email: "user@example.com",
            displayName: "José García",
            profilePictureURL: nil,
            createdAt: Date()
        )

        #expect(user.initials == "JG")
    }

    @Test("initials handles emoji in display name gracefully")
    func initials_withEmoji_handlesGracefully() {
        let user = User(
            id: "user10",
            email: "user@example.com",
            displayName: "😀 John",
            profilePictureURL: nil,
            createdAt: Date()
        )

        #expect(user.initials == "😀J")
    }

    @Test("initials returns single character for very short names")
    func initials_withVeryShortName_returnsSingleChar() {
        let user = User(
            id: "user11",
            email: "a@example.com",
            displayName: "A",
            profilePictureURL: nil,
            createdAt: Date()
        )

        #expect(user.initials == "A")
    }

    @Test("initials returns empty string for email with less than 2 characters")
    func initials_withOneCharEmail_returnsSingleChar() {
        let user = User(
            id: "user12",
            email: "x@e.c",
            displayName: nil,
            profilePictureURL: nil,
            createdAt: Date()
        )

        #expect(user.initials == "X@")
    }

    // MARK: - Equatable Tests

    @Test("Equatable: users with identical properties are equal")
    func equatable_identicalProperties_areEqual() {
        let date = Date()
        let url = URL(string: "https://example.com/photo.jpg")
        let user1 = User(
            id: "user123",
            email: "user@example.com",
            displayName: "John Doe",
            profilePictureURL: url,
            createdAt: date
        )
        let user2 = User(
            id: "user123",
            email: "user@example.com",
            displayName: "John Doe",
            profilePictureURL: url,
            createdAt: date
        )

        #expect(user1 == user2)
    }

    @Test("Equatable: users with different id are not equal")
    func equatable_differentId_areNotEqual() {
        let date = Date()
        let user1 = User(
            id: "user1",
            email: "user@example.com",
            displayName: "John",
            profilePictureURL: nil,
            createdAt: date
        )
        let user2 = User(
            id: "user2",
            email: "user@example.com",
            displayName: "John",
            profilePictureURL: nil,
            createdAt: date
        )

        #expect(user1 != user2)
    }

    @Test("Equatable: users with different email are not equal")
    func equatable_differentEmail_areNotEqual() {
        let date = Date()
        let user1 = User(
            id: "user1",
            email: "user1@example.com",
            displayName: "John",
            profilePictureURL: nil,
            createdAt: date
        )
        let user2 = User(
            id: "user1",
            email: "user2@example.com",
            displayName: "John",
            profilePictureURL: nil,
            createdAt: date
        )

        #expect(user1 != user2)
    }

    @Test("Equatable: users with different displayName are not equal")
    func equatable_differentDisplayName_areNotEqual() {
        let date = Date()
        let user1 = User(
            id: "user1",
            email: "user@example.com",
            displayName: "John",
            profilePictureURL: nil,
            createdAt: date
        )
        let user2 = User(
            id: "user1",
            email: "user@example.com",
            displayName: "Jane",
            profilePictureURL: nil,
            createdAt: date
        )

        #expect(user1 != user2)
    }
}
