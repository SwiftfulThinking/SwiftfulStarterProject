# ACTION 1: Create New Screen

**Triggers:** "create new screen", "create screen", "new screen", "add new screen", or similar requests

---

## Steps

### 1. Check if Xcode templates are installed

```bash
ls ~/Library/Developer/Xcode/Templates/MyTemplates/VIPERTemplate.xctemplate
```

### 2. If templates NOT found

- Respond: "The Xcode templates are not installed. Please install them first:"
- Provide link: https://github.com/SwiftfulThinking/XcodeTemplates
- Include installation instructions:
  ```bash
  cd ~/Library/Developer/Xcode
  mkdir -p Templates
  # Then drag MyTemplates folder into Templates directory
  ```
- Stop here. Do not proceed without templates.

### 3. If templates ARE installed

- Check if screen name is provided in the request
- If NOT provided: Ask "What is the name of the new screen?" (e.g., "Home", "Settings", "Profile")
- Once you have the screen name, proceed to create the screen

### 4. Create the screen using templates

- Read all 4 template files from `~/Library/Developer/Xcode/Templates/MyTemplates/VIPERTemplate.xctemplate/___FILEBASENAME___/`
- Substitute placeholders:
  - `___VARIABLE_productName:identifier___` → ScreenName (e.g., "Home")
  - `___VARIABLE_camelCasedProductName:identifier___` → screenName (e.g., "home")
  - `___VARIABLE_coreName:identifier___` → "Core"
- Create folder: `/SwiftfulStarterProject/Core/ScreenName/`
- Create 4 files:
  - `ScreenNameView.swift`
  - `ScreenNamePresenter.swift`
  - `ScreenNameRouter.swift`
  - `ScreenNameInteractor.swift`

### 5. Verify creation

- List the created files to confirm
- Inform user: "Created new screen with VIPER pattern. Files created in /Core/ScreenName/"

---

## Important Notes

- ALWAYS use the templates when they're installed
- NEVER manually write VIPER files from scratch if templates are available
- The templates ensure consistency with the project's architecture

---

## Manual VIPER Pattern (if templates unavailable)

Every screen in this template follows VIPER. Here's the complete pattern:

### Step 1: Create Screen Folder Structure

Create folder: `/Core/YourScreenName/`

### Step 2: Create Four Files

**File 1: `YourScreenNameView.swift`** (SwiftUI View)
```swift
struct YourScreenNameView: View {
    @State var presenter: YourScreenNamePresenter

    var body: some View {
        // Your UI here
    }
}
```

**File 2: `YourScreenNamePresenter.swift`** (Business Logic)
```swift
@Observable
@MainActor
class YourScreenNamePresenter {
    // Dependencies
    let router: any YourScreenNameRouter
    let interactor: any YourScreenNameInteractor
    let delegate: YourScreenNameDelegate

    // State properties
    var someState: String = ""

    init(router: any YourScreenNameRouter, interactor: any YourScreenNameInteractor, delegate: YourScreenNameDelegate) {
        self.router = router
        self.interactor = interactor
        self.delegate = delegate
    }

    // Event tracking
    func trackEvent(event: Event) {
        interactor.trackEvent(event: event)
    }
}

// Event enum
extension YourScreenNamePresenter {
    enum Event: LoggableEvent {
        case onAppear(delegate: YourScreenNameDelegate)

        var eventName: String {
            switch self {
            case .onAppear: return "YourScreenName_Appear"
            }
        }

        var parameters: [String: Any]? {
            // Return event parameters
        }

        var type: LogType { .analytic }
    }
}

// Delegate for passing data to this screen
struct YourScreenNameDelegate: Equatable, Hashable {
    // Add parameters needed to initialize this screen
}
```

**File 3: `YourScreenNameRouter.swift`** (Navigation Protocol)
```swift
protocol YourScreenNameRouter: GlobalRouter {
    func showNextScreen()
    // Add other navigation methods
}
```

**File 4: `YourScreenNameInteractor.swift`** (Data Protocol)
```swift
protocol YourScreenNameInteractor: GlobalInteractor {
    // Add data access methods
    func fetchData() async throws
}
```

### Step 3: Implement in CoreRouter

Add navigation method to `CoreRouter.swift`:
```swift
extension CoreRouter: YourScreenNameRouter {
    func showNextScreen() {
        router.showScreen(.push) { router in
            builder.nextScreenView(router: router, delegate: NextScreenDelegate())
        }
    }
}
```

### Step 4: Implement in CoreInteractor

Add data methods to `CoreInteractor.swift`:
```swift
extension CoreInteractor: YourScreenNameInteractor {
    func fetchData() async throws {
        // Access managers via container
        // Example: try await container.resolve(AuthManager.self).signIn()
    }
}
```

### Step 5: Add Builder Method

Add factory method to `CoreBuilder.swift`:
```swift
func yourScreenNameView(router: AnyRouter, delegate: YourScreenNameDelegate) -> some View {
    let router = CoreRouter(router: router, builder: self)
    let interactor = CoreInteractor(container: container)
    let presenter = YourScreenNamePresenter(
        router: router,
        interactor: interactor,
        delegate: delegate
    )
    return YourScreenNameView(presenter: presenter)
}
```

### Step 6: Navigate to Your Screen

From another screen's router:
```swift
router.showYourScreenNameView(delegate: YourScreenNameDelegate())
```
