# VIPER Layer Rules & UI Guidelines

These are **CRITICAL** rules for building UI and working with the VIPER architecture. **ALWAYS follow these rules** when adding or modifying screens and components.

---

## 📱 Screen Views (VIPER Pattern)

Screen views follow the VIPER pattern and have different rules than reusable components.

**What Screen Views CAN use:**
- ✅ `@State` to hold the Presenter
- ✅ `@State` for local UI state (sheet presentation, alert state, animation state, etc.)
- ✅ Call Presenter methods for business logic
- ✅ Display data from Presenter's `@Observable` properties
- ✅ Use any layout/UI components
- ✅ **ALWAYS use `.anyButton()` or `.asButton()` modifier** instead of `Button()` wrapper

**What Screen Views CANNOT use:**
- ❌ **NO direct manager access** - always go through Presenter → Interactor → Manager
- ❌ **NO business logic** in the view - all logic goes in Presenter
- ❌ **NO network calls** or data persistence - use Interactor/Manager
- ❌ `@StateObject` or `@ObservedObject` (use `@State` with `@Observable` Presenter instead)

**Example Screen View:**
```swift
struct HomeView: View {
    @State var presenter: HomePresenter
    @State private var showAlert: Bool = false  // Local UI state is OK

    var body: some View {
        VStack {
            // Display data from presenter
            Text(presenter.title)

            Button("Do Something") {
                // Call presenter for business logic
                presenter.onButtonTapped()
            }

            Button("Show Alert") {
                // Local UI state changes are OK
                showAlert = true
            }
        }
        .alert("Message", isPresented: $showAlert) {
            Button("OK") { }
        }
        .onAppear {
            presenter.onViewAppear()
        }
    }
}
```

---

## 🧩 Reusable Components

Components are **DUMB UI** - they only display data and call callbacks. All business logic stays in Presenters.

**CRITICAL Component Rules:**
- ✅ **NO business logic** - UI only
- ✅ **NO @State** for data (only for UI animations/transitions like button press states)
- ✅ **NO @Observable objects** or Presenters
- ✅ **NO @StateObject or @ObservedObject**
- ✅ **ALL data is injected** via init parameters
- ✅ **Make properties OPTIONAL** - then unwrap in the body for maximum flexibility
- ✅ **ALL loading/error states are injected** as parameters (Bool, enum, or other types)
- ✅ **ALL actions are closures** (e.g., `onTap: (() -> Void)?`, `onSubmit: ((String) -> Void)?`)
- ✅ **ALWAYS use `.anyButton()` or `.asButton()` modifier** instead of `Button()` wrapper
- ✅ **ALWAYS use ImageLoaderView** for images (never AsyncImage unless specifically requested)
- ✅ **Create MULTIPLE #Previews** showing different states (full data, partial data, no data, loading, empty)

**Example Component:**
```swift
struct ProfileCardView: View {
    // All data injected - make optional for flexibility
    let imageUrl: String?
    let title: String?
    let subtitle: String?
    let isLoading: Bool

    // All actions as closures
    let onTap: (() -> Void)?

    var body: some View {
        VStack(spacing: 8) {
            // Unwrap optionals in the view
            if isLoading {
                ProgressView()
            } else {
                if let imageUrl {
                    ImageLoaderView(urlString: imageUrl)
                        .aspectRatio(1, contentMode: .fill)
                }

                if let title {
                    Text(title)
                }

                if let subtitle {
                    Text(subtitle)
                }
            }
        }
        .onTapGesture {
            onTap?()
        }
    }
}

#Preview("Full Data") {
    ProfileCardView(
        imageUrl: "https://picsum.photos/100",
        title: "John Doe",
        subtitle: "Developer",
        isLoading: false,
        onTap: { print("Tapped") }
    )
}

#Preview("Loading") {
    ProfileCardView(
        imageUrl: nil,
        title: nil,
        subtitle: nil,
        isLoading: true,
        onTap: nil
    )
}

#Preview("Partial Data") {
    ProfileCardView(
        imageUrl: nil,
        title: "Jane Smith",
        subtitle: nil,
        isLoading: false,
        onTap: nil
    )
}
```

---

## 🎯 Presenter Layer Rules

Presenters contain **ALL business logic** for a screen.

**What Presenters DO:**
- ✅ Hold all screen state as `@Observable` properties
- ✅ Contain ALL business logic
- ✅ Call Interactor for data operations
- ✅ Call Router for navigation
- ✅ Transform data for display (e.g., formatting, filtering)
- ✅ Track analytics events
- ✅ Handle user actions (button taps, form submissions, etc.)
- ✅ Manage loading/error states

**What Presenters DON'T DO:**
- ❌ **NO direct manager access** - use Interactor
- ❌ **NO direct navigation** - use Router
- ❌ **NO UI code** - that stays in View

**CRITICAL Presenter Rules:**
- ✅ **ANY action from the View MUST trigger a method in the Presenter** - Never put business logic directly in button closures
- ✅ **ALL Presenter methods MUST have analytics tracking** - Use `interactor.trackEvent(event: Event.methodName)` in every user-facing method

**Example Presenter:**
```swift
@Observable
@MainActor
class HomePresenter {
    let router: any HomeRouter
    let interactor: any HomeInteractor

    // All screen state lives here
    var title: String = ""
    var isLoading: Bool = false
    var errorMessage: String?

    init(router: any HomeRouter, interactor: any HomeInteractor) {
        self.router = router
        self.interactor = interactor
    }

    // Business logic methods
    func onViewAppear() {
        Task {
            await loadData()
        }
    }

    func onButtonTapped() {
        // Business logic here
        isLoading = true

        Task {
            do {
                try await interactor.performAction()
                router.showNextScreen()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    private func loadData() async {
        // Use interactor for data
        let data = await interactor.fetchData()
        title = data.title
    }
}
```

---

## 🧭 Router Layer Rules

Routers handle **ALL navigation** for a screen.

**What Routers DO:**
- ✅ Define navigation methods as protocol
- ✅ Implemented by CoreRouter
- ✅ Use SwiftfulRouting's `router.showScreen()` methods
- ✅ Manage presentation style (.push, .sheet, .fullScreenCover)

**What Routers DON'T DO:**
- ❌ **NO business logic** - only navigation
- ❌ **NO data access** - only screen transitions

**CRITICAL Router Rules:**
- ✅ **ALL routing MUST use SwiftfulRouting** (https://github.com/SwiftfulThinking/SwiftfulRouting)
- ✅ This includes: segues, modals, alerts, transitions, and switching modules
- ✅ Use `router.showScreen()` for navigation (.push, .sheet, .fullScreenCover)
- ✅ Use `router.showAlert()` for alerts
- ✅ Use `router.dismissScreen()` or `router.dismissEnvironment()` for dismissals
- ✅ Use `router.showModule(moduleId)` for switching between modules (e.g., onboarding ↔ tabbar)
- ✅ **ALWAYS check for existing router methods before creating new ones** - Use grep to search for `func show[ScreenName]` across the codebase
- ✅ **Router protocol must declare ALL methods the screen needs** - Even if implementation exists in CoreRouter extension elsewhere, add method signature to the screen's Router protocol
- ✅ **CoreRouter extensions can exist in ANY file** - Implementation of `showPaywallView()` is in PaywallView.swift, but MUST be declared in HomeRouter protocol for Home to use it
- ✅ **NEVER duplicate CoreRouter extension implementations** - Reuse existing implementations, but DO add method signatures to each Router protocol that needs them
- ✅ **Alert button callbacks MUST use `@MainActor @Sendable`** - When passing presenter methods to alert buttons, closure parameters must be `@escaping @MainActor @Sendable () -> Void` (not just `@Sendable`) to preserve the MainActor context

**Example Router:**
```swift
// Protocol
protocol HomeRouter: GlobalRouter {
    func showDetailScreen(id: String)
    func showSettings()
    func showAlertWithCallback(onConfirm: @escaping @MainActor @Sendable () -> Void)
}

// Implementation in CoreRouter
extension CoreRouter: HomeRouter {
    func showDetailScreen(id: String) {
        router.showScreen(.push) { router in
            builder.detailView(router: router, delegate: DetailDelegate(id: id))
        }
    }

    func showSettings() {
        router.showScreen(.sheet) { router in
            builder.settingsView(router: router)
        }
    }

    // Alert with callback - closure MUST be @MainActor @Sendable
    func showAlertWithCallback(onConfirm: @escaping @MainActor @Sendable () -> Void) {
        showAlert(.alert, title: "Confirm?", subtitle: nil) {
            AnyView(
                Button("Confirm") {
                    onConfirm()  // This calls presenter method which is @MainActor
                }
            )
        }
    }
}

// Usage in Presenter
@Observable
@MainActor
class HomePresenter {
    func onButtonTapped() {
        router.showAlertWithCallback(onConfirm: onAlertConfirmed)
    }

    func onAlertConfirmed() {  // This is @MainActor (inherited from class)
        // Do something
    }
}
```

---

## 📊 Interactor Layer Rules

Interactors handle **ALL data access** for a screen.

**What Interactors DO:**
- ✅ Define data access methods as protocol
- ✅ Implemented by CoreInteractor
- ✅ Access managers via DependencyContainer
- ✅ Perform data operations (fetch, save, delete)
- ✅ Track analytics events

**What Interactors DON'T DO:**
- ❌ **NO UI logic** - only data operations
- ❌ **NO navigation** - only data
- ❌ **NO business logic** - that's in Presenter (Interactor just fetches/saves data)

**Example Interactor:**
```swift
// Protocol
protocol HomeInteractor: GlobalInteractor {
    var currentUser: UserObject? { get }
    func fetchData() async -> [Item]
    func saveItem(_ item: Item) async throws
}

// Implementation in CoreInteractor
extension CoreInteractor: HomeInteractor {
    var currentUser: UserObject? {
        container.resolve(UserManager.self)!.currentUser
    }

    func fetchData() async -> [Item] {
        // Access manager for data
        await container.resolve(DataManager.self)!.fetchItems()
    }

    func saveItem(_ item: Item) async throws {
        try await container.resolve(DataManager.self)!.save(item)
    }
}
```

---

## 📐 Layout Best Practices

**✅ PREFERRED - Use maxWidth/maxHeight with alignment:**
```swift
VStack(spacing: 8) {
    Text("Title")
        .frame(maxWidth: .infinity, alignment: .leading)

    Text("Description")
        .frame(maxWidth: .infinity, alignment: .leading)

    HStack {
        Text("Left")
            .frame(maxWidth: .infinity, alignment: .leading)

        Text("Right")
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
}
```

**❌ AVOID - Using Spacer():**
```swift
// Don't do this
VStack(spacing: 8) {
    HStack {
        Text("Title")
        Spacer()  // ❌ Avoid
    }

    HStack {
        Text("Description")
        Spacer()  // ❌ Avoid
    }
}
```

**Other Layout Rules:**
- ✅ **AVOID fixed frames** when possible - let SwiftUI handle sizing naturally
- ✅ Use `.fixedSize()` sparingly and only when necessary
- ✅ Let SwiftUI's natural sizing work for you
- ✅ Use spacing parameters in stacks instead of padding when possible

---

## 🖼️ Image Handling

**ALWAYS use ImageLoaderView for loading images from URLs:**

```swift
// ✅ Correct
ImageLoaderView(urlString: imageUrl)
    .aspectRatio(1, contentMode: .fill)
    .clipShape(Circle())

// ❌ Wrong - Never use AsyncImage unless specifically requested
AsyncImage(url: URL(string: imageUrl))  // Don't do this
```

---

## 📋 Preview Best Practices

**ALWAYS create multiple previews showing different states:**

```swift
#Preview("Full Data") {
    MyComponentView(
        title: "Sample Title",
        subtitle: "Sample Subtitle",
        isLoading: false
    )
}

#Preview("Loading") {
    MyComponentView(
        title: nil,
        subtitle: nil,
        isLoading: true
    )
}

#Preview("Partial Data") {
    MyComponentView(
        title: "Title Only",
        subtitle: nil,
        isLoading: false
    )
}

#Preview("No Data") {
    MyComponentView(
        title: nil,
        subtitle: nil,
        isLoading: false
    )
}
```

---

## 🔄 Data Flow Summary

**The VIPER data flow is STRICT:**

```
View → Presenter → Interactor → Manager
View ← Presenter ← Interactor ← Manager
```

**Rules:**
1. **View** displays data from **Presenter** and calls **Presenter** methods
2. **Presenter** calls **Interactor** for data and **Router** for navigation
3. **Interactor** accesses **Managers** via DependencyContainer
4. **Router** only handles navigation, nothing else
5. **Components** are dumb UI with injected data and callbacks

**NEVER skip layers:**
- ❌ View → Manager (NO!)
- ❌ View → Interactor (NO!)
- ❌ Presenter → Manager (NO!)
- ✅ View → Presenter → Interactor → Manager (YES!)
