import Combine
import Supabase
import SwiftUI

@MainActor
class AuthController: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    
    let client: SupabaseClient

    init() {
        let urlString = ProcessInfo.processInfo.environment["SUPABASE_URL"]
            ?? Bundle.main.infoDictionary?["SUPABASE_URL"] as? String
            ?? ""
        let key = ProcessInfo.processInfo.environment["SUPABASE_KEY"]
            ?? Bundle.main.infoDictionary?["SUPABASE_KEY"] as? String
            ?? ""

        guard let url = URL(string: urlString), !key.isEmpty else {
            fatalError("❌ Missing or invalid Supabase configuration. Check environment variables or Info.plist")
        }

        self.client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: key
        )
    }

    func login(email: String, password: String) async {
        guard checkCredentials(email: email, password: password) else {
            errorMessage = "Please fill in all fields"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let session = try await client.auth.signIn(email: email, password: password)
            print("✅ Logged in as:", session.user.email ?? "unknown user")
            isAuthenticated = true
        } catch {
            print("❌ Login failed:", error)
            errorMessage = error.localizedDescription
            isAuthenticated = false
        }

        isLoading = false
    }

    func signup(email: String, password: String, verifyPassword: String) async {
        guard checkCredentials(email: email, password: password) else {
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
            let user = try await client.auth.signUp(email: email, password: password)
            print("✅ Signed up user:", user.user.email ?? "unknown email")
            isAuthenticated = true
        } catch {
            print("❌ Signup failed:", error)
            errorMessage = error.localizedDescription
            isAuthenticated = false
        }

        isLoading = false
    }

    private func checkCredentials(email: String, password: String) -> Bool {
        !email.isEmpty && !password.isEmpty
    }
}
