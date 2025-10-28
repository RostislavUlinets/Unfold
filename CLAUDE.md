# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Unfold is an iOS app that gamifies real-world travel by revealing a fog-covered map as users explore. Built with SwiftUI and Supabase for authentication.

## Development Commands

### Building and Running
```bash
# Build the project
xcodebuild -scheme Unfold -configuration Debug build

# Build for release
xcodebuild -scheme Unfold -configuration Release build

# Clean build artifacts
xcodebuild -scheme Unfold clean
```

### Testing
```bash
# Run all tests
xcodebuild test -scheme Unfold -destination 'platform=iOS Simulator,name=iPhone 15'

# Run unit tests only
xcodebuild test -scheme Unfold -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:UnfoldTests

# Run UI tests only
xcodebuild test -scheme Unfold -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:UnfoldUITests
```

## Architecture

### Authentication Flow

The app uses a centralized authentication system with Supabase:

- **AuthController** (`Unfold/Controller/AuthController.swift`) is the main authentication manager, injected as an `@EnvironmentObject` at the app level in `UnfoldApp.swift`
- Listens to Supabase auth state changes via `onAuthStateChange` and automatically updates `isAuthenticated`
- Provides methods: `login()`, `signup()`, `logout()`, and `resetPassword()`
- Supabase credentials are loaded from environment variables (`SUPABASE_URL`, `SUPABASE_KEY`) or Info.plist

### View Hierarchy

```
UnfoldApp (entry point)
└── RootView (navigation root)
    ├── SplashView (shown for 2s minimum on launch)
    ├── AuthPageView (if not authenticated)
    │   └── AuthFormView (login/signup forms)
    │       └── PasswordResetDialogView (forgot password dialog)
    └── HomeView (if authenticated)
```

**RootView** manages the app's primary navigation state:
- Shows `SplashView` for minimum 2 seconds while auth loads
- Transitions to `AuthPageView` if user is not authenticated
- Transitions to `HomeView` if user is authenticated
- Watches `AuthController.isAuthenticated` to determine which view to show

### Controller Pattern

Controllers are `ObservableObject` classes marked `@MainActor`:
- **AuthController**: Manages authentication state, Supabase client, and auth listener
- **PasswordResetController**: Handles password reset flow (requires SupabaseClient injection)

Both controllers publish state changes (`@Published`) for SwiftUI views to observe.

### Configuration

Supabase configuration is loaded with this priority:
1. Environment variables (`SUPABASE_URL`, `SUPABASE_KEY`)
2. Info.plist dictionary values
3. Fatal error if missing

When adding new environment-specific configuration, follow this same pattern.

## Dependencies

Managed via Swift Package Manager (SPM):
- **supabase-swift** (v2.34.0): Backend authentication and data
- Supporting packages: swift-crypto, swift-http-types, swift-clocks, swift-concurrency-extras

## File Organization

```
Unfold/
├── Controller/          # Business logic and state management
├── View/
│   ├── Auth/           # Authentication screens
│   │   └── Components/ # Reusable auth UI components
│   ├── Home/           # Main app screens (post-auth)
│   ├── Splash/         # Launch screen
│   └── Root/           # Navigation root
└── UnfoldApp.swift     # App entry point
```

## Color Extensions

The app uses custom color extensions (e.g., `Color.authBackground`). These are defined as SwiftUI Color extensions, likely in a separate file not yet visible in the current structure.
