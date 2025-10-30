import Foundation

struct User: Identifiable, Equatable {

    /// Unique identifier for the user
    let id: String

    /// User's email address
    let email: String

    /// User's display name (optional)
    var displayName: String?

    /// User's profile picture URL (optional)
    var profilePictureURL: URL?

    /// Date when the user account was created
    let createdAt: Date


    /// Returns a display name or email if display name is not set
    var displayNameOrEmail: String {
        displayName ?? email
    }

    /// Returns initials from display name or email
    var initials: String {
        if let displayName = displayName {
            let components = displayName.components(separatedBy: " ")
            let initials = components.compactMap { $0.first }.prefix(2)
            return String(initials).uppercased()
        } else {
            return String(email.prefix(2)).uppercased()
        }
    }
}
