import Foundation

enum TabItem: String, CaseIterable {
    case home = "Home"
    case explore = "Explore"
    case chats = "Chats"
    case profile = "Profile"

    var icon: String {
        switch self {
        case .home: return AppIcons.home
        case .explore: return AppIcons.explore
        case .chats: return AppIcons.chats
        case .profile: return AppIcons.profile
        }
    }

    var badgeCount: Int? {
        switch self {
        case .chats: return 3  // TODO: Make this dynamic from app state
        default: return nil
        }
    }

    var displayName: String {
        return rawValue
    }
}
