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

- **Purpose**: Business logic, state management, and coordination
- **Location**: `/Controller`
- **Examples**: `AuthController.swift`, `PasswordResetController.swift`
- **Characteristics**:
  - Conforms to `ObservableObject`
  - Marked with `@MainActor` for UI updates
  - Depends on service protocols (not concrete implementations)
  - Publishes state via `@Published` properties
  - Handles validation and error handling

## SOLID Principles

### Single Responsibility Principle (SRP)

Each class/struct has one reason to change:

- `AuthController`: Manages only authentication state
- `SupabaseAuthService`: Handles only Supabase auth operations
- Views: Handle only UI presentation

### Open/Closed Principle (OCP)

Components are open for extension, closed for modification:

- `AuthServiceProtocol` allows new implementations without changing existing code
- Views can be extended via ViewModifiers
- Constants can be extended without modifying existing definitions

### Liskov Substitution Principle (LSP)

Protocol-based design ensures substitutability:

```swift
let authService: AuthServiceProtocol = SupabaseAuthService.createFromEnvironment()
let authService: AuthServiceProtocol = MockAuthService() // For testing
```

Both implementations can be used interchangeably.

### Interface Segregation Principle (ISP)

Focused, minimal protocols:

- `AuthServiceProtocol`: Contains only authentication-related methods
- No "god protocols" with unrelated methods

### Dependency Inversion Principle (DIP)

High-level modules depend on abstractions:

```swift
// AuthController depends on protocol, not concrete implementation
class AuthController {
    private let authService: AuthServiceProtocol  // Abstraction

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
}
```

## Project Structure

```
Unfold/
├── Models/                      # Data models and entities
│   └── User.swift              # User domain model
│
├── Views/                       # SwiftUI views (UI layer)
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
├── Controller/                  # Business logic layer
│   ├── AuthController.swift    # Authentication state manager
│   └── PasswordResetController.swift
│
├── Services/                    # External service abstractions
│   ├── AuthServiceProtocol.swift      # Auth service contract
│   └── SupabaseAuthService.swift      # Supabase implementation
│
├── Utils/                       # Utilities and helpers
│   └── Constants.swift         # App-wide constants
│
└── UnfoldApp.swift             # App entry point
```

## Dependency Injection

### Service Layer

All external dependencies are abstracted through protocols:

1. **Protocol Definition** (`AuthServiceProtocol`)
   - Defines contract for authentication operations
   - Used by controllers

2. **Concrete Implementation** (`SupabaseAuthService`)
   - Implements the protocol
   - Handles Supabase-specific logic
   - Can be swapped with mock for testing

3. **Factory Pattern**
   - `SupabaseAuthService.createFromEnvironment()`: Creates service from env config
   - `AuthController.createDefault()`: Creates controller with default service

### Injection Flow

```swift
// UnfoldApp.swift - Root dependency injection
@StateObject private var authController = AuthController.createDefault()

// Factory creates dependencies
static func createDefault() -> AuthController {
    let authService = SupabaseAuthService.createFromEnvironment()
    return AuthController(authService: authService)
}
```

## Data Flow

### Authentication Flow

```
User Action (View)
    ↓
Controller Method (e.g., login())
    ↓
Service Protocol Method
    ↓
Concrete Service (Supabase)
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
5. Controller calls `authService.signIn()`
6. Service authenticates with Supabase
7. Supabase triggers auth state change
8. Service notifies listeners
9. Controller updates `isAuthenticated`
10. SwiftUI updates UI automatically

## Testing Strategy

### Unit Testing

- **Controllers**: Test with mock services
- **Services**: Test protocol compliance
- **Models**: Test data transformations

Example:

```swift
func testLoginSuccess() async {
    let mockService = MockAuthService()
    let controller = AuthController(authService: mockService)

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
- **Protocols**: Descriptive with "Protocol" suffix (`AuthServiceProtocol`)

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

### 2. Create Service Protocol (if needed)

```swift
// Services/NewFeatureServiceProtocol.swift
protocol NewFeatureServiceProtocol {
    func fetchData() async throws -> [NewFeature]
}
```

### 3. Implement Service

```swift
// Services/SupabaseNewFeatureService.swift
final class SupabaseNewFeatureService: NewFeatureServiceProtocol {
    // ... implementation
}
```

### 4. Create Controller

```swift
// Controller/NewFeatureController.swift
@MainActor
final class NewFeatureController: ObservableObject {
    @Published var items: [NewFeature] = []
    private let service: NewFeatureServiceProtocol

    init(service: NewFeatureServiceProtocol) {
        self.service = service
    }
}
```

### 5. Build View

```swift
// View/NewFeature/NewFeatureView.swift
struct NewFeatureView: View {
    @StateObject private var controller: NewFeatureController

    var body: some View {
        // ... UI
    }
}
```

### 6. Add Constants

Update `Constants.swift` with any new strings, colors, or dimensions.

### 7. Write Tests

Create unit tests for controller and integration tests for the feature.

## Conclusion

This architecture provides:

- ✅ **Testability**: Protocol-based design enables easy mocking
- ✅ **Maintainability**: Clear separation of concerns
- ✅ **Scalability**: Easy to add new features
- ✅ **Flexibility**: Implementations can be swapped
- ✅ **Readability**: Consistent patterns throughout

For questions or suggestions, please refer to the project README or contact the development team.
