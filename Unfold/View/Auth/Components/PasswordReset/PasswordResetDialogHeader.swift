import SwiftUI

struct PasswordResetDialogHeader: View {

    let onClose: () -> Void


    var body: some View {
        HStack {
            Text("Reset Password")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(AppColors.authBackground)

            Spacer()

            Button(action: onClose) {
                Image(systemName: AppIcons.close)
                    .font(.title3)
                    .foregroundColor(.gray.opacity(0.6))
            }
            .accessibilityLabel(Strings.Common.close)
        }
        .padding(.horizontal, AppSpacing.xl)
        .padding(.vertical, AppSpacing.lg)
    }
}


#Preview {
    PasswordResetDialogHeader(onClose: {})
        .background(Color.white)
}
