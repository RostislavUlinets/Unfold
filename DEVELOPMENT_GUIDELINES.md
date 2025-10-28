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
6. [Service Layer Best Practices](#service-layer-best-practices)
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
/// - Dependency Inversion: Depends on AuthServiceProtocol
///
/// Usage:
/// ```swift
/// let controller = PasswordResetController(authService: service)
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
│    Controller/ViewModel Layer       │  ← Business logic, state management
├─────────────────────────────────────┤
│         Service Layer               │  ← External API abstractions
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

**Controller/ViewModel:**
- Manages view state (`@Published` properties)
- Coordinates between View and Services
- Handles validation and business rules
- Depends on Service protocols, not concrete implementations

**Service:**
- Abstracts external dependencies (Supabase, APIs)
- Defined by protocols for testability
- Concrete implementations injected via DI

---

## 🎮 Controller/ViewModel Guidelines

### Structure

```swift
/// AuthController manages authentication state and coordinates auth operations.
///
/// Follows SOLID principles with dependency injection and protocol-based design.

import SwiftUI

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

    private let authService: AuthServiceProtocol
    private var authListenerToken: AuthStateListenerToken?

    // MARK: - Initialization

    /// Initialize with injected authentication service
    init(authService: AuthServiceProtocol) {
        self.authService = authService
        setupAuthStateListener()
    }

    deinit {
        cleanup()
    }

    // MARK: - Public Methods

    /// Authenticate user with email and password
    func login(email: String, password: String) async {
        guard validateInputs(email: email, password: password) else {
            return
        }

        await performAuthOperation {
            try await self.authService.signIn(email: email, password: password)
        }
    }

    // MARK: - Private Methods

    private func setupAuthStateListener() {
        authListenerToken = authService.addAuthStateListener { [weak self] isAuthenticated in
            Task { @MainActor in
                self?.isAuthenticated = isAuthenticated
            }
        }
    }

    private func validateInputs(email: String, password: String) -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = Strings.Auth.fillAllFields
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

    private func cleanup() {
        if let token = authListenerToken {
            authService.removeAuthStateListener(token)
        }
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
        let authService = SupabaseAuthService.createFromEnvironment()
        return AuthController(authService: authService)
    }
}
```

### Controller Best Practices

✅ **Use @MainActor for UI updates**
```swift
@MainActor
final class HomeController: ObservableObject {
    @Published var items: [Item] = []
}
```

✅ **Weak self in closures**
```swift
service.addListener { [weak self] data in
    Task { @MainActor in
        self?.updateData(data)
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

## 🔌 Service Layer Best Practices

### Protocol Definition

```swift
/// Protocol defining authentication service operations.
///
/// Abstracts authentication to enable dependency injection and testing.

protocol AuthServiceProtocol {
    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String) async throws
    func signOut() async throws
    func resetPassword(email: String) async throws
    func getCurrentUserEmail() async -> String?
    func isAuthenticated() async -> Bool
}
```

### Concrete Implementation

```swift
/// Concrete implementation using Supabase.

final class SupabaseAuthService: AuthServiceProtocol {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func signIn(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
    }

    // ... other methods
}

// MARK: - Factory

extension SupabaseAuthService {
    static func createFromEnvironment() -> SupabaseAuthService {
        let config = loadConfiguration()
        let client = SupabaseClient(supabaseURL: config.url, supabaseKey: config.key)
        return SupabaseAuthService(client: client)
    }
}
```

### Service Best Practices

✅ **Use protocols for all services**
✅ **Keep services stateless when possible**
✅ **Handle errors at service level**
✅ **Log operations in debug builds**
✅ **Use factory methods for initialization**

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
    var mockService: MockAuthService!

    override func setUp() {
        super.setUp()
        mockService = MockAuthService()
        sut = AuthController(authService: mockService)
    }

    func testLoginSuccess() async {
        // Given
        mockService.shouldSucceed = true

        // When
        await sut.login(email: "test@test.com", password: "password")

        // Then
        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertNil(sut.errorMessage)
    }

    func testLoginFailure() async {
        // Given
        mockService.shouldSucceed = false
        mockService.errorToThrow = AuthError.invalidCredentials

        // When
        await sut.login(email: "test@test.com", password: "wrong")

        // Then
        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertNotNil(sut.errorMessage)
    }
}
```

### Mock Services

```swift
class MockAuthService: AuthServiceProtocol {
    var shouldSucceed = true
    var errorToThrow: Error?

    func signIn(email: String, password: String) async throws {
        if !shouldSucceed {
            throw errorToThrow ?? AuthError.invalidCredentials
        }
    }

    func isAuthenticated() async -> Bool {
        return shouldSucceed
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
├── Models/
│   ├── User.swift
│   ├── TabItem.swift
│   └── MapRegion.swift
│
├── Services/
│   ├── AuthServiceProtocol.swift
│   ├── SupabaseAuthService.swift
│   ├── MapServiceProtocol.swift
│   └── MockServices/
│       └── MockAuthService.swift
│
├── Controller/
│   ├── AuthController.swift
│   ├── HomeController.swift
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
│   │   ├── SideMenuView.swift
│   │   └── Components/
│   │       ├── ControlButton.swift
│   │       └── TabButton.swift
│   └── Shared/
│       ├── ErrorMessageView.swift
│       ├── InputFieldView.swift
│       └── ButtonStyles/
│           ├── PrimaryButtonStyle.swift
│           └── SecondaryButtonStyle.swift
│
├── Utils/
│   ├── Constants.swift
│   ├── Extensions/
│   │   ├── Color+Extensions.swift
│   │   └── View+Extensions.swift
│   └── Helpers/
│
└── UnfoldApp.swift
```

### Naming Conventions

| Type | Convention | Example |
|------|-----------|---------|
| Views | `PascalCaseView` | `HomePageView`, `ControlButton` |
| Controllers | `PascalCaseController` | `AuthController`, `HomeController` |
| Protocols | `PascalCaseProtocol` | `AuthServiceProtocol` |
| Models | `PascalCase` | `User`, `TabItem` |
| Constants | `camelCase` in enums | `AppColors.primary`, `AppSpacing.md` |
| Functions | `camelCase` | `fetchUserData()`, `validateEmail()` |
| Variables | `camelCase` | `isAuthenticated`, `errorMessage` |

---

## 🎯 Checklist for New Features

When adding a new feature, ensure:

- [ ] Model defined in `/Models`
- [ ] Service protocol created if needed
- [ ] Service implementation with dependency injection
- [ ] Controller with `@Published` properties
- [ ] View components separated into individual files
- [ ] Constants added to `Constants.swift`
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
