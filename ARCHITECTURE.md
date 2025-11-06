# Unfold - Architecture Documentation

This document outlines the architectural patterns, principles, and structure of the Unfold iOS application.

## Table of Contents

- [Overview](#overview)
- [Architecture Pattern](#architecture-pattern)
- [SOLID Principles](#solid-principles)
- [Project Structure](#project-structure)
- [Dependency Injection](#dependency-injection)
- [Data Flow](#data-flow)
- [Testing Strategy](#testing-strategy)
- [Best Practices](#best-practices)

## Overview

Unfold is an iOS application built with SwiftUI that integrates with Supabase for authentication and backend services. The project follows a clean, maintainable architecture based on MVC patterns and SOLID principles.

### Key Technologies

- **SwiftUI**: Declarative UI framework
- **Supabase**: Backend-as-a-Service for authentication
- **Swift Concurrency**: async/await for asynchronous operations
- **Combine**: For reactive state management (via `ObservableObject`)

## Architecture Pattern

The application follows the **MVC (Model-View-Controller)** pattern with clear separation of concerns:

### Model

- **Purpose**: Data structures and business entities
- **Location**: `/Models`
- **Examples**: `User.swift`
- **Characteristics**:
  - Pure Swift structs/classes
  - No UI dependencies
  - Conform to `Identifiable`, `Equatable`, `Codable` as needed

### View

- **Purpose**: Declarative UI components
- **Location**: `/View`
- **Characteristics**:
  - Purely declarative SwiftUI views
  - No business logic
  - No direct service calls
  - State management via `@State`, `@Binding`, `@EnvironmentObject`
  - Delegates actions to Controllers

### Controller

- **Purpose**: Business logic, state management, coordination, AND data access
- **Location**: `/Controller`
- **Examples**: `AuthController.swift`, `PasswordResetController.swift`
- **Characteristics**:
  - Conforms to `ObservableObject`
  - Marked with `@MainActor` for UI updates
  - **"Fat controllers" - directly owns external dependencies (SupabaseClient)**
  - Publishes state via `@Published` properties
  - Handles validation, error handling, and API calls
  - NO separate service layer in pure MVC

## SOLID Principles

### Single Responsibility Principle (SRP)

Each class/struct has one reason to change:

- `AuthController`: Manages authentication state AND handles Supabase auth operations
- Views: Handle only UI presentation
- Models: Contain only data structures

### Open/Closed Principle (OCP)

Components are open for extension, closed for modification:

- Controllers can be subclassed or extended without changing existing code
- Views can be extended via ViewModifiers
- Constants can be extended without modifying existing definitions

### Liskov Substitution Principle (LSP)

Controllers can be mocked for testing:

```swift
// Production
let authController = AuthController(client: SupabaseClient(...))

// Testing
let mockController = MockAuthController()
```

Both can be used interchangeably in views via `@EnvironmentObject`.

### Interface Segregation Principle (ISP)

Focused, single-purpose controllers:

- `AuthController`: Handles only authentication
- `PasswordResetController`: Handles only password reset flow
- Controllers may depend on other controllers when needed
- No "god controllers" with unrelated responsibilities

### Dependency Inversion Principle (DIP)

Dependencies are injected via initializers:

```swift
// AuthController receives SupabaseClient via injection
class AuthController {
    private let client: SupabaseClient  // Injected dependency

    init(client: SupabaseClient) {
        self.client = client
    }
}
```

This allows for dependency substitution during testing.

## Project Structure

```
Unfold/
├── Model/                       # Data models and entities
│   └── User.swift              # User domain model
│
├── View/                        # SwiftUI views (UI layer)
│   ├── Root/
│   │   └── RootView.swift      # Root navigation coordinator
│   ├── Auth/
│   │   ├── AuthPageView.swift  # Login/signup page
│   │   └── Components/
│   │       ├── AuthFormView.swift
│   │       ├── AuthHeaderView.swift
│   │       └── PasswordResetDialogView.swift
│   ├── Home/
│   │   ├── HomePageView.swift  # Main map view
│   │   └── SideMenuView.swift  # Navigation drawer
│   └── Splash/
│       └── SplashView.swift    # Launch screen
│
├── Controller/                  # Business logic + data access layer
│   ├── AuthController.swift    # Authentication ("fat controller" owns SupabaseClient)
│   └── PasswordResetController.swift
│
├── Shared/                      # Reusable components & utilities
│   ├── Components/             # Shared UI elements
│   ├── Extensions/             # Swift extensions
│   └── Utils/                  # Validators, parsers, constants
│
└── UnfoldApp.swift             # App entry point
```

## Dependency Injection

### Fat Controller Pattern

Controllers directly own their external dependencies (no service layer):

1. **SupabaseClient Injection**
   - Controllers receive `SupabaseClient` via initializer
   - Controllers call Supabase APIs directly

2. **Factory Pattern**
   - `AuthController.createDefault()`: Creates controller with configured client
   - Configuration loaded from environment/Info.plist

### Injection Flow

```swift
// UnfoldApp.swift - Root dependency injection
@StateObject private var authController = AuthController.createDefault()

// Factory creates controller with SupabaseClient
static func createDefault() -> AuthController {
    let config = loadConfiguration()
    let client = SupabaseClient(supabaseURL: config.url, supabaseKey: config.key)
    return AuthController(client: client)
}
```

## Data Flow

### Authentication Flow

```
User Action (View)
    ↓
Controller Method (e.g., login())
    ↓
Controller calls SupabaseClient directly
    ↓
Supabase API call
    ↓
Auth State Change Event
    ↓
Controller Updates @Published Properties
    ↓
SwiftUI View Updates Automatically
```

### Example: Login Flow

1. User enters email/password in `AuthFormView`
2. User taps "Login" button
3. View calls `authController.login(email:password:)`
4. Controller validates inputs
5. Controller calls `client.auth.signIn()` directly
6. Supabase authenticates user
7. Supabase triggers auth state change event
8. Controller's listener updates `isAuthenticated`
9. SwiftUI updates UI automatically via `@Published`

## Testing Strategy

### Unit Testing

- **Controllers**: Test with mock SupabaseClient or protocol wrappers
- **Models**: Test data transformations and validation
- **Views**: Test with mock controllers

Example:

```swift
func testLoginSuccess() async {
    let mockClient = MockSupabaseClient()
    let controller = AuthController(client: mockClient)

    await controller.login(email: "test@test.com", password: "password")

    XCTAssertTrue(controller.isAuthenticated)
}
```

### Integration Testing

- Test view and controller integration
- Verify state propagation
- Test navigation flows

### UI Testing

- Use Xcode UI Tests
- Test complete user flows
- Verify accessibility

## Best Practices

### Code Organization

- ✅ One file per type (class/struct/enum)
- ✅ Group related files in folders
- ✅ Use MARK: comments for sections
- ✅ Keep files under 300 lines when possible

### Naming Conventions

- **Files**: PascalCase matching type name (`AuthController.swift`)
- **Types**: PascalCase (`AuthController`, `User`)
- **Properties/Methods**: camelCase (`isAuthenticated`, `login()`)
- **Constants**: camelCase in enums (`AppColors.primary`)
- **Protocols**: Descriptive with "Protocol" suffix when needed (e.g., for wrappers)

### Documentation

- ✅ Document all public types and methods
- ✅ Use Swift documentation comments (///)
- ✅ Include parameter descriptions
- ✅ Add usage examples for complex APIs

### Error Handling

- ✅ Use Swift's typed error handling (`throw`, `try`, `catch`)
- ✅ Provide user-friendly error messages
- ✅ Log errors in debug builds
- ✅ Never silence errors

### State Management

- ✅ Use `@Published` for observable state
- ✅ Keep state in controllers, not views
- ✅ Use `@EnvironmentObject` for shared state
- ✅ Minimize state complexity

### Constants

- ✅ No magic numbers or hardcoded strings
- ✅ Use `Constants.swift` for app-wide values
- ✅ Group related constants in enums
- ✅ Use semantic names

### Async/Await

- ✅ Use async/await for asynchronous operations
- ✅ Mark controllers with `@MainActor`
- ✅ Handle cancellation appropriately
- ✅ Avoid blocking main thread

## Adding New Features

When adding a new feature, follow this checklist:

### 1. Define the Model

```swift
// Models/NewFeature.swift
struct NewFeature: Identifiable {
    let id: String
    // ... properties
}
```

### 2. Create Controller

```swift
// Controller/NewFeatureController.swift
@MainActor
final class NewFeatureController: ObservableObject {
    @Published var items: [NewFeature] = []
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func fetchData() async {
        // Call Supabase directly
        do {
            let data = try await client.from("table").select().execute()
            // Process data...
        } catch {
            // Handle error...
        }
    }
}
```

### 3. Build View

```swift
// View/NewFeature/NewFeatureView.swift
struct NewFeatureView: View {
    @EnvironmentObject var authController: AuthController
    @StateObject private var controller: NewFeatureController

    init() {
        // Controller will get SupabaseClient from authController
        _controller = StateObject(wrappedValue: NewFeatureController(
            client: authController.supabaseClient
        ))
    }

    var body: some View {
        // ... UI
    }
}
```

### 4. Add Constants

Update `Shared/Utils/Constants.swift` with any new strings, colors, or dimensions.

### 5. Write Tests

Create unit tests for controller and integration tests for the feature.

## Conclusion

This architecture provides:

- ✅ **Testability**: Protocol-based design enables easy mocking
- ✅ **Maintainability**: Clear separation of concerns
- ✅ **Scalability**: Easy to add new features
- ✅ **Flexibility**: Implementations can be swapped
- ✅ **Readability**: Consistent patterns throughout

For questions or suggestions, please refer to the project README or contact the development team.
