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
        try await client.auth.resetPasswordForEmail(email)
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
