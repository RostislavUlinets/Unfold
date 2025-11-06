# Unfold - Development Guidelines (2025 SwiftUI Best Practices)

> **Modern, Minimalistic SwiftUI Architecture**
>
> This document defines the complete development guidelines for the Unfold project, following the latest 2025 SwiftUI best practices, clean architecture, and Apple Human Interface Guidelines (HIG).

---

## 📋 Table of Contents

1. [Core View Design Principles](#core-view-design-principles)
2. [UI & Apple HIG Compliance](#ui--apple-hig-compliance)
3. [Debugging & Maintainability](#debugging--maintainability)
4. [Architectural Integration](#architectural-integration)
5. [Controller/ViewModel Guidelines](#controllerviewmodel-guidelines)
6. [Controller Data Access Pattern](#controller-data-access-pattern)
7. [Concurrency & Performance](#concurrency--performance)
8. [Error Handling Patterns](#error-handling-patterns)
9. [Testing Strategy](#testing-strategy)
10. [File Organization](#file-organization)

---

## 🧩 Core View Design Principles

### Every SwiftUI View Must Be:

✅ **Focused, declarative, and composable**
- Each View file should serve **one purpose only**
- If it grows beyond that, extract smaller subviews
- Keep each View file ideally **under ~150 lines** (excluding comments and previews)

✅ **Logic-free**
- No business logic inside Views
- All logic must live in Controllers or ViewModels
- Views only handle layout, bindings, and user interactions

✅ **Composable**
- Use SwiftUI composition to break complex layouts into smaller components
- Create reusable UI components in `/View/Shared`
- Prefer composition over inheritance

✅ **Properly typed**
- Prefer **value types (structs)**
- Use `@StateObject` for owned objects
- Use `@ObservedObject` for passed-in objects
- Use `@EnvironmentObject` for shared app-wide state

### Example: Well-Structured View

```swift
/// HomeView - Main screen displaying the interactive fog-of-war map.
///
/// This view composes several child views and delegates all logic to HomeController.
/// Follows the single responsibility principle with clear separation of concerns.

import SwiftUI

struct HomeView: View {
    // MARK: - Properties

    @StateObject private var controller = HomeController()

    // MARK: - Body

    var body: some View {
        ZStack {
            MapContainerView(region: $controller.region)
            BottomNavBarView(selectedTab: $controller.selectedTab)
        }
        .overlay(SideMenuView(isVisible: $controller.isMenuOpen))
        .task {
            await controller.loadUserData()
        }
    }
}

// MARK: - Preview

#Preview {
    HomeView()
        .environmentObject(AuthController.createDefault())
}
```

---

## 🎨 UI & Apple HIG Compliance

### Design Guidelines

✅ **Follow Apple's Human Interface Guidelines (HIG)**
- Use system colors: `.accentColor`, `.secondary`, `.background`
- Respect dynamic text sizes for accessibility
- Maintain proper color contrast ratios (WCAG AA minimum)
- Use SF Symbols for icons

✅ **Accessibility First**
```swift
Button("Submit") { }
    .accessibilityLabel("Submit form")
    .accessibilityHint("Submits your registration information")
```

✅ **Consistent Spacing & Layout**
- Base padding unit: `16pt` (`.padding(.horizontal, 16)`)
- Corner radii: `8pt` (small), `12pt` (medium), `16pt` (large), `24pt` (pill)
- Use semantic spacing from `AppSpacing` enum

✅ **Typography Hierarchy**
```swift
Text("Title").font(.system(size: AppTypography.title, weight: .bold))
Text("Body").font(.system(size: AppTypography.body))
Text("Caption").font(.system(size: AppTypography.caption))
```

✅ **Visual Polish**
- Use whitespace to create hierarchy
- Maintain consistent alignment
- Add subtle shadows for depth
- Use smooth animations (`.smooth()` over `.easeInOut()`)

### Anti-Patterns to Avoid

❌ **Don't use magic numbers**
```swift
// Bad
.padding(16)
.cornerRadius(12)

// Good
.padding(AppSpacing.md)
.cornerRadius(AppCornerRadius.medium)
```

❌ **Don't hardcode colors**
```swift
// Bad
.foregroundColor(.init(red: 0.2, green: 0.5, blue: 0.8))

// Good
.foregroundColor(AppColors.primary)
```

---

## 🧠 Debugging & Maintainability

### Documentation Standards

✅ **File-level documentation**
```swift
/// PasswordResetController - Manages password reset request flow.
///
/// This controller follows MVC and SOLID principles:
/// - Single Responsibility: Handles only password reset operations
/// - Dependency Injection: Receives AuthController via initializer
///
/// Usage:
/// ```swift
/// let controller = PasswordResetController(authController: authController)
/// await controller.resetPassword(email: "user@example.com")
/// ```
```

✅ **MARK annotations**
```swift
// MARK: - Properties
// MARK: - Initialization
// MARK: - Public Methods
// MARK: - Private Methods
// MARK: - Preview
```

✅ **Preview providers**
```swift
#Preview {
    VStack(spacing: AppSpacing.md) {
        ControlButton(icon: AppIcons.search) {}
        ControlButton(icon: AppIcons.location) {}
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}
```

✅ **Descriptive naming**
```swift
// Bad
var d: Date
func proc()
let btn = Button(...)

// Good
var createdAt: Date
func processPayment()
let submitButton = Button(...)
```

### Code Organization

✅ **Avoid inline side effects**
```swift
// Bad
.onAppear {
    Task {
        try? await supabase.auth.signIn(...)
    }
}

// Good
.task {
    await controller.initialize()
}
```

---

## 🧱 Architectural Integration

### Layer Responsibilities

```
┌─────────────────────────────────────┐
│          View Layer (UI)            │  ← SwiftUI Views (declarative only)
├─────────────────────────────────────┤
│       Controller Layer              │  ← Business logic + data access ("fat")
├─────────────────────────────────────┤
│          Model Layer                │  ← Data structures, entities
└─────────────────────────────────────┘
```

### MVC/MVVM Hybrid Pattern

**Model:**
- Pure Swift data structures
- No dependencies on other layers
- Conform to `Codable`, `Identifiable`, `Equatable` as needed

**View:**
- Purely declarative SwiftUI
- No business logic or direct service calls
- Binds to Controller/ViewModel properties
- Delegates actions to Controller

**Controller:**
- "Fat controllers" that own all business logic AND data access
- Manages view state (`@Published` properties)
- Directly owns external dependencies (SupabaseClient)
- Handles validation, business rules, and API calls
- NO separate service layer in pure MVC

---

## 🎮 Controller/ViewModel Guidelines

### Structure

```swift
/// AuthController manages authentication state and handles all auth operations.
///
/// "Fat controller" pattern - owns SupabaseClient directly, no service layer.

import Foundation
import Supabase

@MainActor
final class AuthController: ObservableObject {
    // MARK: - Published Properties

    /// Indicates whether a user is currently authenticated
    @Published var isAuthenticated = false

    /// Indicates whether an operation is in progress
    @Published var isLoading = false

    /// Contains error message from last failed operation
    @Published var errorMessage: String?

    // MARK: - Private Properties

    private let client: SupabaseClient
    private var supabaseListener: AuthStateChangeListenerRegistration?

    // MARK: - Public Properties

    var supabaseClient: SupabaseClient {
        client
    }

    // MARK: - Initialization

    /// Initialize with injected SupabaseClient
    init(client: SupabaseClient) {
        self.client = client
        setupAuthStateListener()
    }

    deinit {
        supabaseListener?.remove()
    }

    // MARK: - Public Methods

    /// Authenticate user with email and password
    func login(email: String, password: String) async {
        guard validateInputs(email: email, password: password) else {
            return
        }

        await performAuthOperation {
            try await self.client.auth.signIn(email: email, password: password)
        }
    }

    // MARK: - Private Methods

    private func setupAuthStateListener() {
        supabaseListener = client.auth.onAuthStateChange { [weak self] _, session in
            Task { @MainActor in
                self?.isAuthenticated = (session != nil)
            }
        }
    }

    private func validateInputs(email: String, password: String) -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            return false
        }
        return true
    }

    private func performAuthOperation(_ operation: @escaping () async throws -> Void) async {
        isLoading = true
        errorMessage = nil

        do {
            try await operation()
        } catch {
            errorMessage = error.localizedDescription
            logError(error)
        }

        isLoading = false
    }

    private func logError(_ error: Error) {
        #if DEBUG
        print("❌ [AuthController] Error: \(error.localizedDescription)")
        #endif
    }
}

// MARK: - Factory

extension AuthController {
    static func createDefault() -> AuthController {
        let config = loadConfiguration()
        let client = SupabaseClient(
            supabaseURL: config.url,
            supabaseKey: config.key
        )
        return AuthController(client: client)
    }

    private static func loadConfiguration() -> (url: URL, key: String) {
        // Load from environment or Info.plist
        // Implementation details...
        fatalError("Configuration loading not shown for brevity")
    }
}
```

### Controller Best Practices

✅ **Use @MainActor for UI updates**
```swift
@MainActor
final class HomeController: ObservableObject {
    @Published var items: [Item] = []
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }
}
```

✅ **Weak self in closures**
```swift
client.auth.onAuthStateChange { [weak self] _, session in
    Task { @MainActor in
        self?.updateAuthState(session)
    }
}
```

✅ **Separate validation logic**
```swift
private func validateEmail(_ email: String) -> Bool {
    let regex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}$"#
    return email.range(of: regex, options: .regularExpression) != nil
}
```

✅ **Extract operation patterns**
```swift
private func performOperation(_ operation: @escaping () async throws -> Void) async {
    isLoading = true
    defer { isLoading = false }

    do {
        try await operation()
    } catch {
        handleError(error)
    }
}
```

---

## 🔌 Controller Data Access Pattern

### Fat Controller Approach

Controllers directly own and interact with external dependencies:

```swift
/// AuthController - Owns SupabaseClient directly.
///
/// "Fat controller" pattern - no service layer abstraction.

import Foundation
import Supabase

@MainActor
final class AuthController: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
        setupAuthStateListener()
    }

    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            try await client.auth.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
            logError(error)
        }

        isLoading = false
    }

    // ... other methods
}
```

### Controller Best Practices

✅ **Controllers own external clients directly** (SupabaseClient, API clients, etc.)
✅ **Keep state management in controllers** (`@Published` properties)
✅ **Handle errors at controller level** with user-friendly messages
✅ **Log operations in debug builds** (`#if DEBUG`)
✅ **Use factory methods for initialization** (`createDefault()`)
✅ **Inject dependencies via initializer** for testability

---

## 🔄 Concurrency & Performance

### Swift Concurrency Patterns

✅ **Use async/await for all async operations**
```swift
func fetchUserData() async throws -> User {
    let data = try await service.fetch()
    return try decoder.decode(User.self, from: data)
}
```

✅ **Mark UI-updating functions as @MainActor**
```swift
@MainActor
func updateUI() {
    isLoading = false
    items = newItems
}
```

✅ **Use Task for fire-and-forget operations**
```swift
.task {
    await controller.initialize()
}
```

✅ **Handle cancellation properly**
```swift
func longRunningTask() async throws {
    for i in 0..<1000 {
        try Task.checkCancellation()
        await process(i)
    }
}
```

✅ **Use TaskGroup for concurrent operations**
```swift
await withTaskGroup(of: Result.self) { group in
    for item in items {
        group.addTask {
            await process(item)
        }
    }
}
```

### Performance Optimization

✅ **Avoid unnecessary state updates**
```swift
// Use computed properties
var isValid: Bool {
    !email.isEmpty && !password.isEmpty
}
```

✅ **Debounce rapid updates**
```swift
.onChange(of: searchText) { _, newValue in
    Task {
        try? await Task.sleep(nanoseconds: 300_000_000)
        await performSearch(newValue)
    }
}
```

✅ **Lazy load expensive views**
```swift
LazyVStack {
    ForEach(items) { item in
        ItemRow(item: item)
    }
}
```

---

## ⚠️ Error Handling Patterns

### Typed Errors

```swift
enum AuthError: LocalizedError {
    case invalidCredentials
    case networkError
    case sessionExpired

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .networkError:
            return "Network connection failed"
        case .sessionExpired:
            return "Your session has expired"
        }
    }
}
```

### Error Handling in Controllers

```swift
@MainActor
final class DataController: ObservableObject {
    @Published var errorMessage: String?

    func fetchData() async {
        do {
            let data = try await service.fetch()
            processData(data)
        } catch let error as AuthError {
            handleAuthError(error)
        } catch {
            handleGenericError(error)
        }
    }

    private func handleAuthError(_ error: AuthError) {
        errorMessage = error.localizedDescription
        logError(error)
    }

    private func handleGenericError(_ error: Error) {
        errorMessage = "An unexpected error occurred"
        logError(error)
    }

    private func logError(_ error: Error) {
        #if DEBUG
        print("❌ Error: \(error)")
        #endif
    }
}
```

### Error Display in Views

```swift
if let error = controller.errorMessage {
    ErrorMessageView(message: error)
        .transition(.move(edge: .top).combined(with: .opacity))
}
```

---

## 🧪 Testing Strategy

### Unit Testing Controllers

```swift
@MainActor
final class AuthControllerTests: XCTestCase {
    var sut: AuthController!
    var mockClient: MockSupabaseClient!

    override func setUp() {
        super.setUp()
        mockClient = MockSupabaseClient()
        sut = AuthController(client: mockClient)
    }

    func testLoginSuccess() async {
        // Given
        mockClient.authShouldSucceed = true

        // When
        await sut.login(email: "test@test.com", password: "password")

        // Then
        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertNil(sut.errorMessage)
    }

    func testLoginFailure() async {
        // Given
        mockClient.authShouldSucceed = false
        mockClient.errorToThrow = AuthError.invalidCredentials

        // When
        await sut.login(email: "test@test.com", password: "wrong")

        // Then
        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertNotNil(sut.errorMessage)
    }
}
```

### Mock SupabaseClient

For testing, create a protocol wrapper or mock the client:

```swift
// Option 1: Protocol wrapper for testability
protocol SupabaseClientProtocol {
    var auth: SupabaseAuth { get }
}

// Option 2: Mock controller directly
class MockAuthController: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    var loginShouldSucceed = true

    func login(email: String, password: String) async {
        isAuthenticated = loginShouldSucceed
    }
}
```

### View Testing with Previews

```swift
#Preview("Default State") {
    LoginView()
        .environmentObject(AuthController.createDefault())
}

#Preview("Loading State") {
    let controller = AuthController.createDefault()
    controller.isLoading = true
    return LoginView()
        .environmentObject(controller)
}

#Preview("Error State") {
    let controller = AuthController.createDefault()
    controller.errorMessage = "Invalid credentials"
    return LoginView()
        .environmentObject(controller)
}
```

---

## 📁 File Organization

```
Unfold/
├── Model/
│   ├── User.swift
│   ├── TabItem.swift
│   └── GridCell.swift
│
├── Controller/                  # Fat controllers (own SupabaseClient)
│   ├── AuthController.swift
│   ├── MapController.swift
│   └── PasswordResetController.swift
│
├── View/
│   ├── Root/
│   │   └── RootView.swift
│   ├── Auth/
│   │   ├── AuthPageView.swift
│   │   └── Components/
│   │       ├── AuthFormView.swift
│   │       └── AuthHeaderView.swift
│   ├── Home/
│   │   ├── HomePageView.swift
│   │   ├── MapView.swift
│   │   └── SideMenuView.swift
│   └── Shared/
│       └── Components/
│           ├── ErrorMessageView.swift
│           ├── InputFieldView.swift
│           ├── ControlButton.swift
│           └── TabButton.swift
│
├── Shared/
│   ├── Components/             # Reusable UI components
│   ├── Extensions/             # Swift extensions
│   │   ├── Color+Extensions.swift
│   │   └── View+Extensions.swift
│   └── Utils/                  # Utilities, validators, constants
│       ├── Constants.swift
│       ├── PasswordValidator.swift
│       └── DeepLinkParser.swift
│
└── UnfoldApp.swift
```

### Naming Conventions

| Type | Convention | Example |
|------|-----------|---------|
| Views | `PascalCaseView` | `HomePageView`, `ControlButton` |
| Controllers | `PascalCaseController` | `AuthController`, `HomeController` |
| Protocols | `PascalCaseProtocol` | `SupabaseClientProtocol` (for testing) |
| Models | `PascalCase` | `User`, `TabItem` |
| Constants | `camelCase` in enums | `AppColors.primary`, `AppSpacing.md` |
| Functions | `camelCase` | `fetchUserData()`, `validateEmail()` |
| Variables | `camelCase` | `isAuthenticated`, `errorMessage` |

---

## 🎯 Checklist for New Features

When adding a new feature, ensure:

- [ ] Model defined in `/Model` (data structures only)
- [ ] Controller created in `/Controller` with:
  - [ ] SupabaseClient injected via initializer
  - [ ] `@Published` properties for state
  - [ ] `@MainActor` annotation
  - [ ] Factory method (`createDefault()`)
- [ ] View components in `/View` (UI only, no logic)
- [ ] Constants added to `Shared/Utils/Constants.swift`
- [ ] Documentation added to all files
- [ ] Unit tests written for controller
- [ ] Preview providers added to all views
- [ ] Accessibility labels added
- [ ] Error handling implemented
- [ ] Build succeeds without warnings

---

## 🚀 Summary

This project follows modern 2025 SwiftUI best practices with:

✅ **Clean Architecture** - Clear separation of concerns
✅ **SOLID Principles** - Maintainable and testable code
✅ **Apple HIG Compliance** - Native iOS look and feel
✅ **Modular Design** - Every component in its own file
✅ **Type Safety** - Protocol-based dependency injection
✅ **Modern Concurrency** - async/await throughout
✅ **Comprehensive Documentation** - Clear code comments
✅ **Testing Ready** - Mock services and unit tests

The result is a **production-grade codebase** that is:
- Easy to understand
- Simple to debug
- Quick to test
- Scalable for growth
- Maintainable by teams

For detailed architecture diagrams and implementation examples, see [ARCHITECTURE.md](ARCHITECTURE.md).
