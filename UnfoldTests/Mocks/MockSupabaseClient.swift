import Foundation
import Supabase

@MainActor
final class MockSupabaseClient {

    var shouldSucceed = true
    var mockError: Error?
    var mockUser: Supabase.User?
    var mockSession: Session?

    private func createMockAuthResponse() throws -> AuthResponse {
        let userJSON: [String: Any] = [
            "id": "test-user-id",
            "email": "test@example.com",
            "app_metadata": [:],
            "user_metadata": [:],
            "aud": "authenticated",
            "created_at": "2024-01-01T00:00:00Z"
        ]

        let sessionJSON: [String: Any] = [
            "access_token": "mock-access-token",
            "token_type": "bearer",
            "expires_in": 3600,
            "refresh_token": "mock-refresh-token",
            "user": userJSON
        ]

        let responseJSON: [String: Any] = [
            "user": userJSON,
            "session": sessionJSON
        ]

        let data = try JSONSerialization.data(withJSONObject: responseJSON)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(AuthResponse.self, from: data)
    }

    func signIn(email: String, password: String) async throws -> AuthResponse {
        if !shouldSucceed {
            throw mockError ?? NSError(domain: "MockAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock sign in failed"])
        }
        return try createMockAuthResponse()
    }

    func signUp(email: String, password: String) async throws -> AuthResponse {
        if !shouldSucceed {
            throw mockError ?? NSError(domain: "MockAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock sign up failed"])
        }
        return try createMockAuthResponse()
    }

    func signOut() async throws {
        if !shouldSucceed {
            throw mockError ?? NSError(domain: "MockAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock sign out failed"])
        }
    }

    func resetPasswordForEmail(_ email: String, redirectTo: URL?) async throws {
        if !shouldSucceed {
            throw mockError ?? NSError(domain: "MockAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock password reset failed"])
        }
    }

    func verifyOTP(tokenHash: String, type: EmailOTPType) async throws -> AuthResponse {
        if !shouldSucceed {
            throw mockError ?? NSError(domain: "MockAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock OTP verification failed"])
        }
        return try createMockAuthResponse()
    }

    func verifyOTP(email: String, token: String, type: EmailOTPType) async throws -> AuthResponse {
        if !shouldSucceed {
            throw mockError ?? NSError(domain: "MockAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock OTP verification failed"])
        }
        return try createMockAuthResponse()
    }

    func update(user: UserAttributes) async throws -> Supabase.User {
        if !shouldSucceed {
            throw mockError ?? NSError(domain: "MockAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock user update failed"])
        }

        let userJSON: [String: Any] = [
            "id": "test-user-id",
            "email": "test@example.com",
            "app_metadata": [:],
            "user_metadata": [:],
            "aud": "authenticated",
            "created_at": "2024-01-01T00:00:00Z"
        ]

        let data = try JSONSerialization.data(withJSONObject: userJSON)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Supabase.User.self, from: data)
    }
}
