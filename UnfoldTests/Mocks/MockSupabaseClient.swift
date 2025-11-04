import Foundation
import Supabase
@testable import Unfold

/// Mock SupabaseClient for testing authentication flows
@MainActor
final class MockSupabaseClient {

    // MARK: - Mock Configuration

    var shouldSucceed = true
    var mockError: Error?
    var mockSession: Session?
    var mockUser: Supabase.User?

    // MARK: - Call Tracking

    private(set) var signInCalled = false
    private(set) var signUpCalled = false
    private(set) var signOutCalled = false
    private(set) var resetPasswordCalled = false
    private(set) var verifyOTPCalled = false
    private(set) var updateUserCalled = false
    private(set) var signInWithOAuthCalled = false

    private(set) var lastSignInEmail: String?
    private(set) var lastSignInPassword: String?
    private(set) var lastSignUpEmail: String?
    private(set) var lastSignUpPassword: String?
    private(set) var lastResetEmail: String?
    private(set) var lastOAuthProvider: Provider?
    private(set) var lastVerifyOTPType: EmailOTPType?
    private(set) var lastUpdateAttributes: UserAttributes?

    // MARK: - Auth State Management

    private var authStateCallback: ((AuthChangeEvent, Session?) -> Void)?

    // MARK: - Mock Auth Methods

    func signIn(email: String, password: String) async throws -> Session {
        signInCalled = true
        lastSignInEmail = email
        lastSignInPassword = password

        if let error = mockError, !shouldSucceed {
            throw error
        }

        let session = mockSession ?? createMockSession(email: email)
        triggerAuthStateChange(.signedIn, session: session)
        return session
    }

    func signUp(email: String, password: String) async throws -> AuthResponse {
        signUpCalled = true
        lastSignUpEmail = email
        lastSignUpPassword = password

        if let error = mockError, !shouldSucceed {
            throw error
        }

        let user = mockUser ?? createMockUser(email: email)
        let session = mockSession ?? createMockSession(email: email)
        triggerAuthStateChange(.signedIn, session: session)

        return AuthResponse(user: user, session: session)
    }

    func signOut() async throws {
        signOutCalled = true

        if let error = mockError, !shouldSucceed {
            throw error
        }

        triggerAuthStateChange(.signedOut, session: nil)
    }

    func resetPasswordForEmail(_ email: String, redirectTo: URL) async throws {
        resetPasswordCalled = true
        lastResetEmail = email

        if let error = mockError, !shouldSucceed {
            throw error
        }
    }

    func verifyOTP(tokenHash: String, type: EmailOTPType) async throws -> AuthResponse {
        verifyOTPCalled = true
        lastVerifyOTPType = type

        if let error = mockError, !shouldSucceed {
            throw error
        }

        let user = mockUser ?? createMockUser(email: "verified@example.com")
        let session = mockSession ?? createMockSession(email: "verified@example.com")

        return AuthResponse(user: user, session: session)
    }

    func verifyOTP(email: String, token: String, type: EmailOTPType) async throws -> AuthResponse {
        verifyOTPCalled = true
        lastVerifyOTPType = type

        if let error = mockError, !shouldSucceed {
            throw error
        }

        let user = mockUser ?? createMockUser(email: email.isEmpty ? "verified@example.com" : email)
        let session = mockSession ?? createMockSession(email: email.isEmpty ? "verified@example.com" : email)

        return AuthResponse(user: user, session: session)
    }

    func updateUser(attributes: UserAttributes) async throws -> Supabase.User {
        updateUserCalled = true
        lastUpdateAttributes = attributes

        if let error = mockError, !shouldSucceed {
            throw error
        }

        return mockUser ?? createMockUser(email: "updated@example.com")
    }

    func signInWithOAuth(provider: Provider) async throws {
        signInWithOAuthCalled = true
        lastOAuthProvider = provider

        if let error = mockError, !shouldSucceed {
            throw error
        }

        let session = mockSession ?? createMockSession(email: "\(provider.rawValue)@example.com")
        triggerAuthStateChange(.signedIn, session: session)
    }

    func getSession() async throws -> Session {
        if let session = mockSession {
            return session
        }

        throw NSError(domain: "MockSupabase", code: 401, userInfo: [NSLocalizedDescriptionKey: "No active session"])
    }

    // MARK: - Auth State Listener

    func onAuthStateChange(callback: @escaping (AuthChangeEvent, Session?) -> Void) -> MockAuthStateChangeRegistration {
        authStateCallback = callback

        // Trigger initial session event
        triggerAuthStateChange(.initialSession, session: mockSession)

        return MockAuthStateChangeRegistration()
    }

    func triggerAuthStateChange(_ event: AuthChangeEvent, session: Session?) {
        authStateCallback?(event, session)
    }

    // MARK: - Helper Methods

    private func createMockUser(email: String) -> Supabase.User {
        return Supabase.User(
            id: UUID(),
            appMetadata: [:],
            userMetadata: [:],
            aud: "authenticated",
            createdAt: Date(),
            updatedAt: Date(),
            email: email
        )
    }

    private func createMockSession(email: String) -> Session {
        let user = createMockUser(email: email)
        return Session(
            accessToken: "mock-access-token",
            tokenType: "bearer",
            expiresIn: 3600,
            expiresAt: Date().addingTimeInterval(3600).timeIntervalSince1970,
            refreshToken: "mock-refresh-token",
            user: user
        )
    }

    // MARK: - Reset Methods

    func reset() {
        shouldSucceed = true
        mockError = nil
        mockSession = nil
        mockUser = nil

        signInCalled = false
        signUpCalled = false
        signOutCalled = false
        resetPasswordCalled = false
        verifyOTPCalled = false
        updateUserCalled = false
        signInWithOAuthCalled = false

        lastSignInEmail = nil
        lastSignInPassword = nil
        lastSignUpEmail = nil
        lastSignUpPassword = nil
        lastResetEmail = nil
        lastOAuthProvider = nil
        lastVerifyOTPType = nil
        lastUpdateAttributes = nil
    }
}

// MARK: - Mock Auth State Change Registration

final class MockAuthStateChangeRegistration {
    func remove() {
        // Mock implementation - does nothing
    }
}

// MARK: - Mock Errors

enum MockSupabaseError: Error, LocalizedError {
    case invalidCredentials
    case userAlreadyExists
    case invalidToken
    case networkError
    case passwordTooWeak
    case samePassword
    case custom(String)

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid login credentials"
        case .userAlreadyExists:
            return "User already registered"
        case .invalidToken:
            return "Invalid or expired token"
        case .networkError:
            return "Network connection failed"
        case .passwordTooWeak:
            return "Password is too weak"
        case .samePassword:
            return "New password cannot be the same as the old password"
        case .custom(let message):
            return message
        }
    }
}
