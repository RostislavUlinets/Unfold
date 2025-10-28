import SwiftUI

struct MenuItemView: View {

    let icon: String
    let title: String
    var action: (() -> Void)? = nil


    var body: some View {
        Button(action: handleTap) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.gray)
                    .frame(width: AppDimensions.smallIconSize)

                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding(.horizontal, AppSpacing.xl)
            .padding(.vertical, AppSpacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }


    private func handleTap() {
        action?()
    }
}


#Preview {
    VStack(spacing: 0) {
        MenuItemView(
            icon: AppIcons.profile,
            title: Strings.Menu.profileSettings
        )

        MenuItemView(
            icon: AppIcons.notifications,
            title: Strings.Menu.notifications
        )

        MenuItemView(
            icon: AppIcons.settings,
            title: Strings.Menu.settings
        )

        MenuItemView(
            icon: AppIcons.help,
            title: Strings.Menu.helpAndSupport
        )
    }
    .background(Color.white)
}
