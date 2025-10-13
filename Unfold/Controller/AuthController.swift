import Supabase
import SwiftUI

@MainActor
class AuthController: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    let client: SupabaseClient
    private var authListener: AuthStateChangeListenerRegistration?

    init() {
        let urlString = ProcessInfo.processInfo.environment["SUPABASE_URL"]
            ?? Bundle.main.infoDictionary?["SUPABASE_URL"] as? String
            ?? ""
        let key = ProcessInfo.processInfo.environment["SUPABASE_KEY"]
            ?? Bundle.main.infoDictionary?["SUPABASE_KEY"] as? String
            ?? ""

        guard let url = URL(string: urlString), !key.isEmpty else {
            fatalError("❌ Missing or invalid Supabase configuration.")
        }

        self.client = SupabaseClient(supabaseURL: url, supabaseKey: key)

        Task {
            await listenForAuthChanges()
        }
    }

    // MARK: - Auth Listener
    private func listenForAuthChanges() async {
        print("👂 Listening for auth state changes...")
        authListener = await client.auth.onAuthStateChange { [weak self] event, session in
            guard let self = self else { return }

           Task { @MainActor in
                switch event {
                case .initialSession:
                    print("🔐 Initial session loaded:", session?.user.email ?? "no session")
                    self.isAuthenticated = (session != nil)

                case .signedIn:
                    print("✅ User signed in:", session?.user.email ?? "unknown")
                    self.isAuthenticated = true

                case .signedOut:
                    print("🚪 User signed out")
                    self.isAuthenticated = false

                case .tokenRefreshed:
                    print("🔄 Token refreshed")

                default:
                    break
                }
            }
        }
    }

    // MARK: - Manual Actions
    func login(email: String, password: String) async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await client.auth.signIn(email: email, password: password)
            // No need to set isAuthenticated manually — listener handles it
        } catch {
            print("❌ Login failed:", error.localizedDescription)
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func signup(email: String, password: String, verifyPassword: String) async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }

        guard password == verifyPassword else {
            errorMessage = "Passwords do not match"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await client.auth.signUp(email: email, password: password)
        } catch {
            print("❌ Signup failed:", error.localizedDescription)
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func logout() async {
        do {
            try await client.auth.signOut()
        } catch {
            print("❌ Logout failed:", error.localizedDescription)
            errorMessage = error.localizedDescription
        }
    }

    deinit {
        // Optionally unsubscribe when controller is deallocated
        authListener?.remove()
    }
}
