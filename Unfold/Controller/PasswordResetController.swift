import Foundation

@MainActor
final class PasswordResetController: ObservableObject {

    // MARK: - Published Properties

    @Published var isSending = false
    @Published var success = false
    @Published var errorMessage: String?

    // MARK: - Dependencies

    private let authController: AuthController

    // MARK: - Initialization

    init(authController: AuthController) {
        self.authController = authController
    }

    // MARK: - Public Methods

    func resetPassword(email: String) async {
        guard !email.isEmpty else {
            errorMessage = Strings.Auth.fillAllFields
            return
        }

        isSending = true
        errorMessage = nil
        success = false

        await authController.resetPassword(email: email)

        if let error = authController.errorMessage {
            errorMessage = error
        } else {
            success = true
        }

        isSending = false
    }
}
