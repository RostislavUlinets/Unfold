import SwiftUI

struct PasswordResetDialog: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var controller: PasswordResetController
    @State private var email = ""
    @State private var isEmailValid = true
    @FocusState private var isEmailFieldFocused: Bool

    init(authService: AuthServiceProtocol) {
        _controller = StateObject(wrappedValue: PasswordResetController(authService: authService))
    }

    var body: some View {
        ZStack {
            AppColors.overlayDim
                .ignoresSafeArea()
                .onTapGesture(perform: dismiss.callAsFunction)

            dialogContent
        }
        .animation(.smooth(duration: AppAnimation.normal), value: controller.success)
        .task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            isEmailFieldFocused = true
        }
        .onChange(of: controller.success) { _, success in
            if success {
                Task {
                    try? await Task.sleep(nanoseconds: 3_000_000_000)
                    dismiss()
                }
            }
        }
    }

    private var dialogContent: some View {
        VStack(spacing: 0) {
            PasswordResetDialogHeader(onClose: dismiss.callAsFunction)
            Divider()

            if controller.success {
                PasswordResetSuccessView(email: email, onDone: dismiss.callAsFunction)
            } else {
                PasswordResetFormView(
                    email: $email,
                    isEmailValid: $isEmailValid,
                    isEmailFieldFocused: $isEmailFieldFocused,
                    isSending: controller.isSending,
                    errorMessage: controller.errorMessage,
                    onSubmit: handleSubmit,
                    onCancel: dismiss.callAsFunction
                )
            }
        }
        .frame(maxWidth: 380)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.xlarge))
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
        .transition(.scale(scale: 0.9).combined(with: .opacity))
    }

    private func handleSubmit() {
        isEmailFieldFocused = false

        guard EmailValidator.isValid(email) else {
            isEmailValid = false
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }

        UINotificationFeedbackGenerator().notificationOccurred(.success)
        Task { await controller.resetPassword(email: email) }
    }
}

#Preview {
    PasswordResetDialog(authService: SupabaseAuthService.createFromEnvironment())
}
