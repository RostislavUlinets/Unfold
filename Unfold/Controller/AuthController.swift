import SwiftUI

@MainActor
final class AuthController: ObservableObject {

    /// Indicates whether a user is currently authenticated
    @Published var isAuthenticated = false

    /// Indicates whether an authentication operation is in progress
    @Published var isLoading = false

    /// Contains error message from last failed authentication operation
    @Published var errorMessage: String?

    /// Current authenticated user (nil if not authenticated)
    @Published var currentUser: User?


    /// Authentication service (exposed for dependency injection to related controllers)
    let authService: AuthServiceProtocol


    private var authListenerToken: AuthStateListenerToken?


    /// Initialize AuthController with an authentication service
    /// - Parameter authService: Service conforming to AuthServiceProtocol
    init(authService: AuthServiceProtocol) {
        self.authService = authService
        setupAuthStateListener()
    }

    deinit {
        if let token = authListenerToken {
            authService.removeAuthStateListener(token)
        }
    }


    /// Authenticate user with email and password
    /// - Parameters:
    ///   - email: User's email address
    ///   - password: User's password
    func login(email: String, password: String) async {
        // Validate inputs
        guard validateLoginInputs(email: email, password: password) else {
            return
        }

        await performAuthOperation {
            try await self.authService.signIn(email: email, password: password)
        }
    }

    /// Register a new user with email and password
    /// - Parameters:
    ///   - email: User's email address
    ///   - password: User's password
    ///   - verifyPassword: Password confirmation
    func signup(email: String, password: String, verifyPassword: String) async {
        // Validate inputs
        guard validateSignupInputs(email: email, password: password, verifyPassword: verifyPassword) else {
            return
        }

        await performAuthOperation {
            try await self.authService.signUp(email: email, password: password)
        }
    }

    /// Sign out the current user
    func logout() async {
        await performAuthOperation {
            try await self.authService.signOut()
        }
    }

    /// Request a password reset email
    /// - Parameter email: User's email address
    func resetPassword(email: String) async {
        guard !email.isEmpty else {
            errorMessage = Strings.Auth.fillAllFields
            return
        }

        await performAuthOperation {
            try await self.authService.resetPassword(email: email)
        }
    }


    /// Set up authentication state listener
    private func setupAuthStateListener() {
        authListenerToken = authService.addAuthStateListener { [weak self] isAuthenticated in
            guard let self = self else { return }

            Task { @MainActor in
                self.isAuthenticated = isAuthenticated
                self.isLoading = false

                // Fetch user info if authenticated
                if isAuthenticated {
                    await self.fetchCurrentUser()
                } else {
                    self.currentUser = nil
                }
            }
        }
    }

    /// Fetch current authenticated user information
    private func fetchCurrentUser() async {
        guard let email = await authService.getCurrentUserEmail() else {
            return
        }

        // Create user model from available data
        // In a real app, you might fetch additional user data from a database
        currentUser = User(
            id: email, // Use email as temporary ID
            email: email,
            displayName: nil,
            profilePictureURL: nil,
            createdAt: Date()
        )
    }

    /// Perform an authentication operation with error handling
    /// - Parameter operation: Async throwing operation to perform
    private func performAuthOperation(_ operation: @escaping () async throws -> Void) async {
        isLoading = true
        errorMessage = nil

        do {
            try await operation()
        } catch {
            errorMessage = error.localizedDescription
            #if DEBUG
            print("❌ [Auth] Operation failed: \(error.localizedDescription)")
            #endif
        }

        isLoading = false
    }

    /// Validate login inputs
    private func validateLoginInputs(email: String, password: String) -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = Strings.Auth.fillAllFields
            return false
        }
        return true
    }

    /// Validate signup inputs
    private func validateSignupInputs(email: String, password: String, verifyPassword: String) -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = Strings.Auth.fillAllFields
            return false
        }

        guard password == verifyPassword else {
            errorMessage = Strings.Auth.passwordsDoNotMatch
            return false
        }

        return true
    }
}


extension AuthController {
    /// Create an AuthController with default Supabase service
    /// - Returns: Configured AuthController instance
    static func createDefault() -> AuthController {
        let authService = SupabaseAuthService.createFromEnvironment()
        return AuthController(authService: authService)
    }
}

