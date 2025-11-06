# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## 🧩 ARCHITECTURE STRUCTURE

Follow the **pure MVC (Model-View-Controller)** pattern strictly:
- **Model** → Lightweight data structures only. No business logic.
- **View** → SwiftUI screens and reusable UI components. UI only.
- **Controller** → "Fat controllers" that handle ALL business logic, data access, API calls, and state management.
- **Shared** → Common UI elements, helpers, extensions, constants, utilities.

### Folder Structure:
```
ProjectRoot/
├── Model/
│   ├── UserModel.swift
│   └── JobModel.swift
├── View/
│   ├── HomeView.swift
│   ├── HomeCardView.swift
│   └── ProfileView.swift
├── Controller/
│   ├── HomeController.swift
│   └── ProfileController.swift
└── Shared/
    ├── Components/
    ├── Extensions/
    └── Utils/
```

---

## 🧠 CODING PRINCIPLES

### Clean Code
- Code must be simple, readable, and self-explanatory.
- Limit each file to **100 lines (max 150)**.
- Each SwiftUI View should handle only **one logical responsibility**.
- Avoid magic numbers — use constants or enums.
- Prefer composition over inheritance.

### SOLID
- **S**ingle Responsibility: Each file/class has one clear purpose.
- **O**pen/Closed: Code should be open for extension, closed for modification.
- **L**iskov Substitution: Use protocols to abstract dependencies.
- **I**nterface Segregation: Keep protocols small and focused.
- **D**ependency Inversion: Controllers depend on abstractions, not concrete types.

### KISS
- Keep It Simple and Short.
- Avoid clever tricks and over-engineering.
- Short functions (< 30 lines preferred).
- Use clear names — no abbreviations or unclear terms.

---

## 🪶 SWIFTUI & CODE STYLE GUIDELINES

### Views
- Views = UI only. No data or navigation logic.
- Use small subviews for sections (`CardView`, `HeaderView`, `ListItemView`, etc.).
- Use computed properties and extensions to simplify body code.
- Use `@State`, `@ObservedObject`, and `@EnvironmentObject` correctly.
- Avoid large `body` declarations — refactor into subviews.

### Controllers
- Controllers handle user actions, data flow, side effects, AND data access.
- "Fat controllers" = Controllers directly call APIs, manage state, handle networking.
- NO separate "Service" layer in true MVC - Controllers own all non-UI logic.
- Should not import SwiftUI (only Foundation + domain frameworks like Supabase).
- Controllers may depend on other controllers when needed.
- Keep logic testable and reusable.

### Models
- Represent data only.
- Keep them lightweight (prefer `struct`).
- Conform to `Codable` if needed.
- Include mock/static data for testing when applicable.

### Shared
- Use for reusable UI components, constants, extensions, and small utilities.
- No business logic here — only helpers or style definitions.

---

## ⚙️ NAMING & ORGANIZATION
- View → `SomethingView`
- Controller → `SomethingController`
- Model → `SomethingModel`
- Shared UI → `SomethingComponent` or `SomethingButton`
- Use `// MARK:` comments to organize code logically.
- Use `private` access modifiers wherever possible.

---

## ✅ OUTPUT EXPECTATIONS

When writing SwiftUI code, always:
1. Respect MVC separation.
2. Keep each file < 150 lines.
3. Split code into separate files if it exceeds complexity.
4. Provide:
   - Model file
   - Controller file
   - View file (+ subviews if needed)
5. Use short, professional, production-ready Swift code.
6. Avoid unnecessary comments — let the code explain itself.
7. Format with consistent indentation and spacing.

---

## 📱 PROJECT OVERVIEW

**Unfold** is an iOS app that gamifies real-world travel by revealing a fog-covered map as users explore. Built with SwiftUI and Supabase for authentication.

---

## 🔧 DEVELOPMENT COMMANDS

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

---

## 🏗️ PROJECT ARCHITECTURE

### Authentication Flow

The app follows **pure MVC** with a "fat controller" for authentication:

- **AuthController** (`Unfold/Controller/AuthController.swift`) is the main authentication manager, injected as an `@EnvironmentObject` at the app level in `UnfoldApp.swift`
- **Directly owns the SupabaseClient** - no separate service layer
- Handles ALL auth logic: sign in, sign up, logout, password reset, token verification
- Listens to Supabase auth state changes via `onAuthStateChange` and automatically updates `isAuthenticated`
- Provides methods: `login()`, `signup()`, `logout()`, `resetPassword()`, and `verifyTokenAndUpdatePassword()`
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
- **AuthController**: "Fat controller" that owns SupabaseClient directly, manages auth state, handles all API calls
- **PasswordResetController**: Depends on AuthController to delegate password reset logic
- **PasswordResetConfirmationController**: Depends on AuthController to delegate token verification

All controllers publish state changes (`@Published`) for SwiftUI views to observe.

**Key principle**: Controllers may depend on other controllers, but never have a separate "Service" layer.

### Password Reset Flow

The password reset system uses **deep linking** to seamlessly bring users back to the app from email:

#### Flow Architecture:
```
1. User taps "Forgot Password?" on login screen
   ↓
2. PasswordResetDialogView appears (popover)
   ↓
3. User enters email → PasswordResetController.resetPassword(email)
   ↓
4. AuthController.resetPassword(email) sends reset email via Supabase
   - Includes redirectTo: "unfold://reset-password"
   ↓
5. Supabase sends email with magic link
   ↓
6. User taps link → iOS opens app via deep link
   ↓
7. UnfoldApp.onOpenURL() captures URL
   ↓
8. DeepLinkParser extracts token from URL parameters
   ↓
9. Token stored in PasswordResetTokenHolder (observable environment object)
   ↓
10. RootView detects token → shows PasswordResetConfirmationView
   ↓
11. User enters new password (with visibility toggle & strength indicator)
   ↓
12. PasswordResetConfirmationController.updatePassword() calls
    AuthController.verifyTokenAndUpdatePassword()
   ↓
13. AuthController verifies token & updates password
   ↓
14. Success → User automatically logged in → Navigate to HomeView
```

#### Key Components:

**Deep Linking** (`Unfold/UnfoldApp.swift`):
- URL Scheme: `unfold://`
- Reset URL: `unfold://reset-password?token=xxx`
- Configured in Info.plist: `CFBundleURLSchemes`

**Token Parser** (`Shared/Utils/DeepLinkParser.swift`):
- Extracts token from URL query parameters
- Looks for: `code`, `token`, `token_hash`, `access_token`
- Returns `PasswordResetToken` struct (Equatable)

**Password Validation** (`Shared/Utils/PasswordValidator.swift`):
- Minimum 8 characters
- At least one special character: `!@#$%^&*()_+-=[]{}|;:,.<>?`
- Password strength analysis: weak/medium/strong
- Real-time validation feedback

**UI Components**:
- `PasswordResetDialogView`: Email input dialog (popover on login)
- `PasswordResetConfirmationView`: New password entry with strength indicator
- `SecureInputFieldView`: Reusable password field with visibility toggle (eye icon)

**Edge Cases Handled**:
- User already logged in when opening reset link → Alert with "Sign Out and Reset" option
- Token verification separated from password update (better error handling)
- "Same password" error → Clear user-friendly message
- Expired/invalid token → Prompt to request new reset

### Configuration

Supabase configuration is loaded with this priority:
1. Environment variables (`SUPABASE_URL`, `SUPABASE_KEY`)
2. Info.plist dictionary values
3. Fatal error if missing

When adding new environment-specific configuration, follow this same pattern.

---

## 📦 DEPENDENCIES

Managed via Swift Package Manager (SPM):
- **supabase-swift** (v2.34.0): Backend authentication and data
- Supporting packages: swift-crypto, swift-http-types, swift-clocks, swift-concurrency-extras

---

## 📂 FILE ORGANIZATION

```
Unfold/
├── Controller/                # Business logic, state management, AND data access
│   ├── AuthController.swift              (owns SupabaseClient)
│   ├── PasswordResetController.swift
│   └── PasswordResetConfirmationController.swift
├── Model/                     # Data structures only (NO services)
│   ├── User.swift
│   └── TabItem.swift
├── View/                      # UI only
│   ├── Auth/                  # Authentication screens
│   │   └── Components/        # Reusable auth UI components
│   ├── Home/                  # Main app screens (post-auth)
│   ├── Splash/                # Launch screen
│   └── Root/                  # Navigation root
├── Shared/                    # Reusable components & utilities
│   ├── Components/            # Shared UI (buttons, inputs, etc.)
│   └── Utils/                 # Validators, parsers, constants
└── UnfoldApp.swift            # App entry point
```

---

## 🎨 COLOR EXTENSIONS

The app uses custom color extensions (e.g., `Color.authBackground`). These are defined as SwiftUI Color extensions, likely in a separate file not yet visible in the current structure.

---

## 🧩 EXAMPLE TASK PROMPT

> Create a `Home` feature in SwiftUI using MVC.
> Include:
> - `HomeModel.swift`
> - `HomeController.swift`
> - `HomeView.swift`
> - `HomeCardView.swift` (subview)
>
> Follow all Clean Code, SOLID, and KISS principles.
> Keep each file under 150 lines.
> View handles UI, Controller handles logic, Model holds data.
