import Foundation

protocol AuthServiceProtocol {
    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String) async throws
    func signOut() async throws
    func resetPassword(email: String) async throws
    func getCurrentUserEmail() async -> String?
    func isAuthenticated() async -> Bool
    func addAuthStateListener(_ handler: @escaping (Bool) -> Void) -> AuthStateListenerToken
    func removeAuthStateListener(_ token: AuthStateListenerToken)
}

struct AuthStateListenerToken: Equatable {
    let id: UUID
}
