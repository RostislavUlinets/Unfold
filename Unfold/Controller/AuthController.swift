import Foundation
import Supabase

@MainActor
final class AuthController: ObservableObject {

    // MARK: - Published Properties

    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentUser: User?

    // MARK: - Private Properties

    private let client: SupabaseClient
    private var supabaseListener: AuthStateChangeListenerRegistration?

    // MARK: - Public Properties

    var supabaseClient: SupabaseClient {
        client
    }

    // MARK: - Initialization

    init(client: SupabaseClient) {
        self.client = client
        setupAuthStateListener()
    }

    deinit {
        supabaseListener?.remove()
    }

    // MARK: - Public Methods

    func login(email: String, password: String) async {
        guard validateLoginInputs(email: email, password: password) else {
            return
        }

        await performAuthOperation {
            try await self.client.auth.signIn(email: email, password: password)
        }
    }

    func signup(email: String, password: String, verifyPassword: String) async {
        guard validateSignupInputs(email: email, password: password, verifyPassword: verifyPassword) else {
            return
        }

        await performAuthOperation {
            try await self.client.auth.signUp(email: email, password: password)
        }
    }

    func logout() async {
        await performAuthOperation {
            try await self.client.auth.signOut()
        }
    }

    func resetPassword(email: String) async {
        guard !email.isEmpty else {
            errorMessage = Strings.Auth.fillAllFields
            return
        }

        await performAuthOperation {
            guard let redirectURL = URL(string: "unfold://reset-password") else {
                throw NSError(
                    domain: "AuthController",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid redirect URL configuration"]
                )
            }

            try await self.client.auth.resetPasswordForEmail(
                email,
                redirectTo: redirectURL
            )

            #if DEBUG
            print("📧 [Auth] Password reset email sent to: \(email)")
            print("   - Redirect URL: \(redirectURL.absoluteString)")
            #endif
        }
    }

    func verifyTokenAndUpdatePassword(token: String, newPassword: String) async throws {
        #if DEBUG
        print("🔐 [Auth] Verifying token and updating password")
        print("   Token: \(token.prefix(10))...")
        #endif

        var tokenVerified = false
        var userEmail: String?
        var lastVerificationError: Error?

        // Method 1: Try as tokenHash
        do {
            #if DEBUG
            print("   Trying method 1: tokenHash verification")
            #endif

            let response = try await client.auth.verifyOTP(
                tokenHash: token,
                type: .recovery
            )

            tokenVerified = true
            userEmail = response.user.email
            #if DEBUG
            print("✅ [Auth] Token verified (method 1)")
            print("   User: \(userEmail ?? "unknown")")
            #endif
        } catch {
            lastVerificationError = error
            #if DEBUG
            print("   Method 1 failed: \(error.localizedDescription)")
            #endif
        }

        // Method 2: Try using token directly if method 1 failed
        if !tokenVerified {
            do {
                #if DEBUG
                print("   Trying method 2: email OTP verification")
                #endif

                let response = try await client.auth.verifyOTP(
                    email: "",
                    token: token,
                    type: .recovery
                )

                tokenVerified = true
                userEmail = response.user.email
                #if DEBUG
                print("✅ [Auth] Token verified (method 2)")
                print("   User: \(userEmail ?? "unknown")")
                #endif
            } catch {
                lastVerificationError = error
                #if DEBUG
                print("   Method 2 failed: \(error.localizedDescription)")
                #endif
            }
        }

        // If token verification failed, throw the error
        guard tokenVerified else {
            #if DEBUG
            print("❌ [Auth] Token verification failed")
            #endif
            throw lastVerificationError ?? NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to verify token"])
        }

        // Now update the password (token is already verified)
        #if DEBUG
        print("   Updating password...")
        #endif

        try await client.auth.update(user: UserAttributes(password: newPassword))

        #if DEBUG
        print("✅ [Auth] Password updated successfully")
        #endif
    }

    func getCurrentUserEmail() async -> String? {
        return try? await client.auth.session.user.email
    }

    func signInWithGoogle() async {
        await performAuthOperation {
            #if DEBUG
            print("🔐 [Auth] Initiating Google sign-in")
            #endif

            try await self.client.auth.signInWithOAuth(provider: .google)

            #if DEBUG
            print("✅ [Auth] Google OAuth flow initiated")
            #endif
        }
    }

    func signInWithApple() async {
        await performAuthOperation {
            #if DEBUG
            print("🔐 [Auth] Initiating Apple sign-in")
            #endif

            try await self.client.auth.signInWithOAuth(provider: .apple)

            #if DEBUG
            print("✅ [Auth] Apple OAuth flow initiated")
            #endif
        }
    }

    // MARK: - Private Methods

    private func setupAuthStateListener() {
        Task {
            supabaseListener = await client.auth.onAuthStateChange { [weak self] event, session in
                guard let self = self else { return }

                let isAuthenticated = session != nil

                Task { @MainActor in
                    self.isAuthenticated = isAuthenticated
                    self.isLoading = false

                    if isAuthenticated {
                        await self.fetchCurrentUser()
                    } else {
                        self.currentUser = nil
                    }
                }

                self.logAuthEvent(event, session: session)
            }
        }
    }

    private func fetchCurrentUser() async {
        guard let email = await getCurrentUserEmail() else {
            return
        }

        currentUser = User(
            id: email,
            email: email,
            displayName: nil,
            profilePictureURL: nil,
            createdAt: Date()
        )
    }

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

    private func validateLoginInputs(email: String, password: String) -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = Strings.Auth.fillAllFields
            return false
        }
        return true
    }

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

    nonisolated private func logAuthEvent(_ event: AuthChangeEvent, session: Session?) {
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

// MARK: - Factory

extension AuthController {
    static func createDefault() -> AuthController {
        // Check if running in UI test mode
        let isUITesting = ProcessInfo.processInfo.arguments.contains("UI-TESTING")

        if isUITesting {
            #if DEBUG
            print("🧪 [Auth] Running in UI test mode - using mock Supabase configuration")
            #endif

            // Use mock URLs for UI testing to avoid fatal error
            let mockURL = URL(string: "https://mock.supabase.co")!
            let mockKey = "mock-anon-key-for-ui-testing"
            let client = SupabaseClient(supabaseURL: mockURL, supabaseKey: mockKey)
            return AuthController(client: client)
        }

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
        return AuthController(client: client)
    }
}
