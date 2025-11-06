import SwiftUI

struct ErrorMessageView: View {

    let message: String


    var body: some View {
        Label(message, systemImage: AppIcons.error)
            .font(.subheadline)
            .foregroundColor(AppColors.error)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}


#Preview {
    VStack(spacing: AppSpacing.md) {
        ErrorMessageView(message: "Invalid email address")
        ErrorMessageView(message: "Password must be at least 8 characters")
        ErrorMessageView(message: "Network connection failed")
    }
    .padding()
}
