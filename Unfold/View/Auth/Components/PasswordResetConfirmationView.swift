import SwiftUI

/// View for confirming password reset and entering new password
struct PasswordResetConfirmationView: View {

    @StateObject private var controller: PasswordResetConfirmationController
    @EnvironmentObject private var authController: AuthController

    let onComplete: () -> Void

    init(authController: AuthController, resetToken: DeepLinkParser.PasswordResetToken, onComplete: @escaping () -> Void = {}) {
        _controller = StateObject(
            wrappedValue: PasswordResetConfirmationController(
                authController: authController,
                resetToken: resetToken
            )
        )
        self.onComplete = onComplete
    }

    var body: some View {
        ZStack {
            // Background
            AppColors.authBackground
                .ignoresSafeArea()

            VStack(spacing: AppSpacing.lg) {
                // Header
                headerSection

                // Form
                if !controller.success {
                    formSection
                } else {
                    successSection
                }

                Spacer()
            }
            .padding(.top, AppSpacing.xxl)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: "lock.rotation")
                .font(.system(size: 60))
                .foregroundColor(.white)

            Text("Reset Your Password")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("Enter your new password below")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
    }

    // MARK: - Form Section

    private var formSection: some View {
        VStack(spacing: AppSpacing.md) {
            // Password field
            SecureInputFieldView(
                label: "New Password",
                text: $controller.password,
                placeholder: "Enter new password"
            )

            // Password strength indicator
            if !controller.password.isEmpty {
                passwordStrengthView
            }

            // Confirm password field
            SecureInputFieldView(
                label: "Confirm Password",
                text: $controller.confirmPassword,
                placeholder: "Re-enter new password"
            )

            // Password match indicator
            if !controller.confirmPassword.isEmpty {
                passwordMatchView
            }

            // Validation error
            if let error = controller.passwordValidationError {
                ErrorMessageView(message: error)
            }

            // General error
            if let error = controller.errorMessage {
                ErrorMessageView(message: error)
            }

            // Password requirements
            requirementsView

            // Submit button
            Button(action: {
                Task {
                    await controller.updatePassword()
                }
            }) {
                HStack {
                    if controller.isUpdating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Reset Password")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(controller.canSubmit ? Color.white : Color.gray)
                .foregroundColor(AppColors.authBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.pill))
            }
            .disabled(!controller.canSubmit)
            .padding(.horizontal)
            .padding(.top, AppSpacing.sm)
        }
    }

    // MARK: - Password Strength View

    private var passwordStrengthView: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack {
                Text("Password Strength:")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))

                Text(controller.passwordStrength.description)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(strengthColor)

                Spacer()
            }

            // Visual strength indicator
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: AppCornerRadius.small)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 6)

                    // Strength progress
                    RoundedRectangle(cornerRadius: AppCornerRadius.small)
                        .fill(strengthColor)
                        .frame(width: geometry.size.width * strengthProgress, height: 6)
                        .animation(.easeInOut(duration: 0.3), value: controller.passwordStrength)
                }
            }
            .frame(height: 6)
        }
        .padding(.horizontal)
    }

    private var strengthColor: Color {
        switch controller.passwordStrength {
        case .weak: return .red
        case .medium: return .orange
        case .strong: return .green
        }
    }

    private var strengthProgress: CGFloat {
        switch controller.passwordStrength {
        case .weak: return 0.33
        case .medium: return 0.66
        case .strong: return 1.0
        }
    }

    // MARK: - Password Match View

    private var passwordMatchView: some View {
        HStack {
            Image(systemName: controller.passwordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(controller.passwordsMatch ? .green : .red)

            Text(controller.passwordsMatch ? "Passwords match" : "Passwords do not match")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))

            Spacer()
        }
        .padding(.horizontal)
    }

    // MARK: - Requirements View

    private var requirementsView: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Password Requirements:")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.9))

            ForEach(PasswordValidator.requirements, id: \.self) { requirement in
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 6))
                        .foregroundColor(.white.opacity(0.6))

                    Text(requirement)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, AppSpacing.xs)
    }

    // MARK: - Success Section

    private var successSection: some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            Text("Password Reset Successful!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("Your password has been updated.\nYou are now logged in.")
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)

            Button(action: {
                // Clear the reset token to allow navigation to HomeView
                onComplete()
            }) {
                Text("Continue")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(AppColors.authBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.pill))
            }
            .padding(.horizontal)
            .padding(.top, AppSpacing.md)
        }
    }
}
