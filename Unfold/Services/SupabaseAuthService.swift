import Foundation
import Supabase

final class SupabaseAuthService: AuthServiceProtocol {
    private let client: SupabaseClient
    private var listeners: [UUID: (Bool) -> Void] = [:]
    private var supabaseListener: AuthStateChangeListenerRegistration?

    init(client: SupabaseClient) {
        self.client = client
        setupAuthStateListener()
    }

    deinit {
        supabaseListener?.remove()
    }

    func signIn(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
    }

    func signUp(email: String, password: String) async throws {
        try await client.auth.signUp(email: email, password: password)
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }

    func resetPassword(email: String) async throws {
        guard let redirectURL = URL(string: "unfold://reset-password") else {
            throw NSError(
                domain: "SupabaseAuthService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid redirect URL configuration"]
            )
        }

        try await client.auth.resetPasswordForEmail(
            email,
            redirectTo: redirectURL
        )

        #if DEBUG
        print("📧 [Auth] Password reset email sent to: \(email)")
        print("   - Redirect URL: \(redirectURL.absoluteString)")
        #endif
    }

    func verifyTokenAndUpdatePassword(token: String, newPassword: String) async throws {
        // Simple approach: try different methods until one works

        #if DEBUG
        print("🔐 [Auth] Verifying token and updating password")
        print("   Token: \(token.prefix(10))...")
        #endif

        var lastError: Error?

        // Method 1: Try as tokenHash
        do {
            #if DEBUG
            print("   Trying method 1: tokenHash verification")
            #endif

            let response = try await client.auth.verifyOTP(
                tokenHash: token,
                type: .recovery
            )

            #if DEBUG
            print("✅ [Auth] Token verified (method 1)")
            print("   User: \(response.user.email ?? "unknown")")
            #endif

            // Update password
            try await client.auth.update(user: UserAttributes(password: newPassword))

            #if DEBUG
            print("✅ [Auth] Password updated successfully")
            #endif
            return
        } catch {
            lastError = error
            #if DEBUG
            print("   Method 1 failed: \(error.localizedDescription)")
            #endif
        }

        // Method 2: Try using token directly with email (empty)
        do {
            #if DEBUG
            print("   Trying method 2: email OTP verification")
            #endif

            let response = try await client.auth.verifyOTP(
                email: "",
                token: token,
                type: .recovery
            )

            #if DEBUG
            print("✅ [Auth] Token verified (method 2)")
            print("   User: \(response.user.email ?? "unknown")")
            #endif

            // Update password
            try await client.auth.update(user: UserAttributes(password: newPassword))

            #if DEBUG
            print("✅ [Auth] Password updated successfully")
            #endif
            return
        } catch {
            lastError = error
            #if DEBUG
            print("   Method 2 failed: \(error.localizedDescription)")
            #endif
        }

        // If all methods failed, throw the last error
        #if DEBUG
        print("❌ [Auth] All verification methods failed")
        #endif
        throw lastError ?? NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to verify token"])
    }

    func getCurrentUserEmail() async -> String? {
        return try? await client.auth.session.user.email
    }

    func isAuthenticated() async -> Bool {
        return (try? await client.auth.session) != nil
    }

    func addAuthStateListener(_ handler: @escaping (Bool) -> Void) -> AuthStateListenerToken {
        let token = AuthStateListenerToken(id: UUID())
        listeners[token.id] = handler
        return token
    }

    func removeAuthStateListener(_ token: AuthStateListenerToken) {
        listeners.removeValue(forKey: token.id)
    }

    private func setupAuthStateListener() {
        Task {
            supabaseListener = await client.auth.onAuthStateChange { [weak self] event, session in
                guard let self = self else { return }

                let isAuthenticated = session != nil

                Task { @MainActor in
                    self.listeners.values.forEach { handler in
                        handler(isAuthenticated)
                    }
                }

                self.logAuthEvent(event, session: session)
            }
        }
    }

    private func logAuthEvent(_ event: AuthChangeEvent, session: Session?) {
        #if DEBUG
        switch event {
        case .initialSession:
            print("🔐 [Auth] Initial session loaded: \(session?.user.email ?? "no session")")
        case .signedIn:
            print("✅ [Auth] User signed in: \(session?.user.email ?? "unknown")")
        case .signedOut:
            print("🚪 [Auth] User signed out")
        case .tokenRefreshed:
            print("🔄 [Auth] Token refreshed")
        default:
            print("📡 [Auth] Event: \(event)")
        }
        #endif
    }
}

extension SupabaseAuthService {
    static func createFromEnvironment() -> SupabaseAuthService {
        let urlString =
            ProcessInfo.processInfo.environment["SUPABASE_URL"]
            ?? Bundle.main.infoDictionary?["SUPABASE_URL"] as? String
            ?? ""
        let key =
            ProcessInfo.processInfo.environment["SUPABASE_KEY"]
            ?? Bundle.main.infoDictionary?["SUPABASE_KEY"] as? String
            ?? ""

        guard let url = URL(string: urlString), !key.isEmpty else {
            fatalError("❌ Missing or invalid Supabase configuration. Check SUPABASE_URL and SUPABASE_KEY.")
        }

        let client = SupabaseClient(supabaseURL: url, supabaseKey: key)
        return SupabaseAuthService(client: client)
    }
}
