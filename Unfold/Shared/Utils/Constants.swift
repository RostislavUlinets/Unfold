import SwiftUI


enum AppConstants {
    /// App display name
    static let appName = "Unfold"

    /// App tagline
    static let tagline = "Turn your travels into an adventure"

    /// Minimum splash screen duration (seconds)
    static let splashDuration: TimeInterval = 2.0
}


enum AppColors {

    /// Primary brand color (teal/green for exploration badge, etc.)
    static let primary = Color.teal

    /// Secondary brand color
    static let secondary = Color.green

    /// Authentication background color
    static let authBackground = Color("AuthBackground")


    /// Background for bottom sheets and cards
    static let bottomSheet = Color("BottomSheet")

    /// Map background placeholder
    static let mapBackground = Color.black.opacity(0.9)

    /// Overlay dimming color
    static let overlayDim = Color.black.opacity(0.4)

    /// Success color (for confirmations, success states)
    static let success = Color.green

    /// Error color (for errors, destructive actions)
    static let error = Color.red

    /// Warning color
    static let warning = Color.orange


    /// Primary text color
    static let textPrimary = Color.primary

    /// Secondary text color
    static let textSecondary = Color.secondary

    /// Tertiary text color
    static let textTertiary = Color.gray

    /// Border color
    static let border = Color.gray.opacity(0.2)

    /// Divider color
    static let divider = Color.gray.opacity(0.2)
}


enum AppTypography {

    static let largeTitle: CGFloat = 36
    static let title: CGFloat = 32
    static let title2: CGFloat = 28
    static let title3: CGFloat = 24
    static let headline: CGFloat = 18
    static let body: CGFloat = 16
    static let callout: CGFloat = 15
    static let subheadline: CGFloat = 14
    static let footnote: CGFloat = 13
    static let caption: CGFloat = 12
    static let caption2: CGFloat = 11
}


enum AppSpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 40
}


enum AppCornerRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let xlarge: CGFloat = 20
    static let pill: CGFloat = 24
    static let xxlarge: CGFloat = 32
}


enum AppAnimation {
    static let quick: TimeInterval = 0.15
    static let fast: TimeInterval = 0.2
    static let normal: TimeInterval = 0.3
    static let slow: TimeInterval = 0.4
    static let verySlow: TimeInterval = 0.6
}


enum AppDimensions {

    static let buttonHeight: CGFloat = 55
    static let smallButtonHeight: CGFloat = 44
    static let iconButtonSize: CGFloat = 50


    static let inputFieldHeight: CGFloat = 50
    static let inputFieldPadding: CGFloat = 14


    static let tabBarHeight: CGFloat = 70
    static let sideMenuWidth: CGFloat = 280


    static let smallIconSize: CGFloat = 20
    static let mediumIconSize: CGFloat = 24
    static let largeIconSize: CGFloat = 32
    static let xlargeIconSize: CGFloat = 48
}


enum Strings {

    enum Auth {
        static let login = "Login"
        static let signup = "Sign Up"
        static let email = "Email"
        static let password = "Password"
        static let confirmPassword = "Confirm Password"
        static let forgotPassword = "Forgot Password?"
        static let resetPassword = "Reset Password"
        static let sendResetLink = "Send Reset Link"
        static let logout = "Logout"
        static let termsAndConditions = "Terms & Conditions"

        // Messages
        static let welcomeTitle = "Hello & Welcome!"
        static let resetEmailSent = "Check Your Email"
        static let resetInstructions = "We've sent password reset instructions to"
        static let resetHint = "Didn't receive the email? Check your spam folder or try again."
        static let resetDescription = "Enter your email address and we'll send you instructions to reset your password."

        // Errors
        static let fillAllFields = "Please fill in all fields"
        static let passwordsDoNotMatch = "Passwords do not match"
        static let invalidEmail = "Please enter a valid email address"
    }


    enum Navigation {
        static let home = "Home"
        static let explore = "Explore"
        static let chats = "Chats"
        static let profile = "Profile"
    }


    enum Menu {
        static let profileSettings = "Profile Settings"
        static let notifications = "Notifications"
        static let settings = "Settings"
        static let helpAndSupport = "Help & Support"
    }


    enum Map {
        static let exploredFormat = "%d%% Explored"
        static let mapView = "Map View"
    }


    enum Common {
        static let done = "Done"
        static let cancel = "Cancel"
        static let close = "Close"
        static let ok = "OK"
        static let yes = "Yes"
        static let no = "No"
        static let save = "Save"
        static let delete = "Delete"
        static let edit = "Edit"
    }
}


enum AppIcons {

    static let home = "house.fill"
    static let explore = "map.fill"
    static let chats = "message.fill"
    static let profile = "person.fill"


    static let menu = "line.3.horizontal"
    static let close = "xmark.circle.fill"
    static let settings = "gearshape.fill"
    static let notifications = "bell.fill"
    static let help = "questionmark.circle.fill"


    static let search = "magnifyingglass"
    static let location = "location.fill"
    static let zoomIn = "plus"
    static let zoomOut = "minus"
    static let eye = "eye.fill"


    static let logout = "rectangle.portrait.and.arrow.right"
    static let email = "envelope.fill"
    static let lock = "lock.fill"


    static let success = "checkmark.circle.fill"
    static let error = "exclamationmark.triangle.fill"
    static let warning = "exclamationmark.circle.fill"
}


enum AppEnvironment {
    /// Check if running in debug mode
    static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    /// Check if running in simulator
    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
}
