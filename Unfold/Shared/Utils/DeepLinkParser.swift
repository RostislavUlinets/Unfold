import Foundation

/// Simple deep link parser for password reset
struct DeepLinkParser {

    /// Simple token structure - just holds whatever we extracted
    struct PasswordResetToken: Equatable {
        let token: String

        var isValid: Bool {
            !token.isEmpty
        }
    }

    /// Type of deep link
    enum DeepLinkType {
        case passwordReset(PasswordResetToken)
        case unknown
    }

    /// Parse a deep link URL - super simple version
    static func parse(_ url: URL) -> DeepLinkType {
        #if DEBUG
        print("🔗 [DeepLink] Received URL: \(url)")
        #endif

        // Check if this is a password reset link
        guard url.host == "reset-password" || url.path.contains("reset-password") else {
            #if DEBUG
            print("⚠️ [DeepLink] Not a reset-password URL")
            #endif
            return .unknown
        }

        // Extract any token we can find from query parameters
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
           let queryItems = components.queryItems {

            // Look for common parameter names
            let parameterNames = ["code", "token", "token_hash", "access_token"]

            for paramName in parameterNames {
                if let value = queryItems.first(where: { $0.name == paramName })?.value,
                   !value.isEmpty {
                    #if DEBUG
                    print("✅ [DeepLink] Found token in '\(paramName)' parameter")
                    print("   Token: \(value.prefix(10))...")
                    #endif

                    return .passwordReset(PasswordResetToken(token: value))
                }
            }
        }

        #if DEBUG
        print("❌ [DeepLink] No token found in URL")
        #endif
        return .unknown
    }
}
