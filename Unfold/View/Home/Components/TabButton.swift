import SwiftUI

struct TabButton: View {

    let tab: TabItem
    let isSelected: Bool
    let action: () -> Void


    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                iconWithBadge

                Text(tab.displayName)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }


    private var iconWithBadge: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: tab.icon)
                .font(.title3)
                .foregroundColor(isSelected ? .blue : .gray)

            // Badge for notifications
            if let count = tab.badgeCount {
                badgeView(count: count)
            }
        }
    }

    private func badgeView(count: Int) -> some View {
        Text("\(count)")
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(width: 20, height: 20)
            .background(Circle().fill(AppColors.error))
            .offset(x: 10, y: -8)
    }
}


#Preview {
    VStack(spacing: AppSpacing.md) {
        // Selected tab
        TabButton(tab: .home, isSelected: true) {}
            .frame(width: 80)

        // Unselected tab
        TabButton(tab: .explore, isSelected: false) {}
            .frame(width: 80)

        // Tab with badge
        TabButton(tab: .chats, isSelected: false) {}
            .frame(width: 80)
    }
    .padding()
    .background(Color.white)
}
