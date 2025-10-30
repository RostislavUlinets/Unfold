import Foundation

/// Validates password strength and requirements
struct PasswordValidator {

    /// Password validation errors
    enum ValidationError: LocalizedError {
        case tooShort
        case missingSpecialCharacter
        case passwordsDoNotMatch

        var errorDescription: String? {
            switch self {
            case .tooShort:
                return "Password must be at least 8 characters"
            case .missingSpecialCharacter:
                return "Password must contain at least one special character (!@#$%^&*)"
            case .passwordsDoNotMatch:
                return "Passwords do not match"
            }
        }
    }

    /// Password strength levels
    enum Strength {
        case weak
        case medium
        case strong

        var description: String {
            switch self {
            case .weak: return "Weak"
            case .medium: return "Medium"
            case .strong: return "Strong"
            }
        }

        var color: String {
            switch self {
            case .weak: return "red"
            case .medium: return "orange"
            case .strong: return "green"
            }
        }
    }

    /// Special characters that satisfy the requirement
    private static let specialCharacters = "!@#$%^&*()_+-=[]{}|;:,.<>?"

    /// Validates a password against all requirements
    /// - Parameter password: The password to validate
    /// - Returns: Array of validation errors (empty if valid)
    static func validate(_ password: String) -> [ValidationError] {
        var errors: [ValidationError] = []

        // Check minimum length (8 characters)
        if password.count < 8 {
            errors.append(.tooShort)
        }

        // Check for special character
        if !containsSpecialCharacter(password) {
            errors.append(.missingSpecialCharacter)
        }

        return errors
    }

    /// Checks if password is valid (meets all requirements)
    /// - Parameter password: The password to validate
    /// - Returns: true if valid, false otherwise
    static func isValid(_ password: String) -> Bool {
        return validate(password).isEmpty
    }

    /// Gets a user-friendly validation message
    /// - Parameter password: The password to validate
    /// - Returns: Error message if invalid, nil if valid
    static func validationMessage(for password: String) -> String? {
        let errors = validate(password)
        guard !errors.isEmpty else { return nil }
        return errors.first?.errorDescription
    }

    /// Validates that two passwords match
    /// - Parameters:
    ///   - password: The password
    ///   - confirmation: The confirmation password
    /// - Returns: true if they match, false otherwise
    static func passwordsMatch(_ password: String, _ confirmation: String) -> Bool {
        return password == confirmation && !password.isEmpty
    }

    /// Calculates password strength
    /// - Parameter password: The password to evaluate
    /// - Returns: Strength level (weak, medium, strong)
    static func strength(of password: String) -> Strength {
        var score = 0

        // Length scoring
        if password.count >= 8 { score += 1 }
        if password.count >= 12 { score += 1 }

        // Character variety scoring
        if password.contains(where: { $0.isUppercase }) { score += 1 }
        if password.contains(where: { $0.isLowercase }) { score += 1 }
        if password.contains(where: { $0.isNumber }) { score += 1 }
        if containsSpecialCharacter(password) { score += 1 }

        // Map score to strength
        if score >= 5 {
            return .strong
        } else if score >= 3 {
            return .medium
        } else {
            return .weak
        }
    }

    /// Checks if password contains at least one special character
    /// - Parameter password: The password to check
    /// - Returns: true if contains special character, false otherwise
    private static func containsSpecialCharacter(_ password: String) -> Bool {
        return password.contains(where: { specialCharacters.contains($0) })
    }

    /// Gets all validation requirements as strings
    static var requirements: [String] {
        return [
            "At least 8 characters",
            "At least one special character (!@#$%^&*)"
        ]
    }
}
