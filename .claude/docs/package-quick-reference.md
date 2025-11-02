# SwiftfulThinking Packages - Quick Reference Guide
## SwiftfulStarterProject Implementation

### File Locations
- **Alias Files** (type definitions & logger conformance)
  - `Managers/Routing/SwiftfulRouting+Alias.swift`
  - `Managers/DataManagers/SwiftfulDataManagers+Alias.swift`
  - `Managers/Auth/SwiftfulAuthenticating+Alias.swift`
  - `Managers/Logs/SwiftfulLogging+Alias.swift`
  - `Managers/Purchases/SwiftfulPurchasing+Alias.swift`
  - `Managers/Gamification/SwiftfulGamificiation+Alias.swift`
  - `Managers/Haptics/SwiftfulHaptics+Alias.swift`
  - `Managers/SoundEffects/SwiftfulSoundEffects+Alias.swift`
  - `Utilities/SwiftfulUtilities+Alias.swift`

- **Manager Initialization**
  - `Root/Dependencies/Dependencies.swift` (all managers created here)
  - `Root/Dependencies/Dependencies+DevPreview.swift` (for previews)

- **Core RIBs**
  - `Root/RIBs/Core/CoreRouter.swift` (navigation)
  - `Root/RIBs/Core/CoreInteractor.swift` (manager access)
  - `Root/RIBs/Core/CoreBuilder.swift` (screen creation)
  - `Root/RIBs/Global/GlobalRouter.swift` (dismissal methods)
  - `Root/RIBs/Global/GlobalInteractor.swift` (tracking methods)

### 1-Minute Overview

**SwiftfulRouting**
- 2 modules: "onboarding" (auth) and "tabbar" (app)
- Screen navigation: `.push`, `.sheet`, `.sheetConfig`
- LogManager implements RoutingLogger

**SwiftfulDataManagers**
- UserManager extends DocumentManagerSync<UserModel>
- Static path: "users" collection
- FileManager persistence for offline

**SwiftfulAuthenticating**
- Anonymous, Apple, Google sign-in
- Returns (user, isNewUser) tuple
- Firebase backend

**SwiftfulLogging**
- 4 backends: Console, Firebase Analytics, Mixpanel, Crashlytics
- LoggableEvent protocol in every Presenter
- 4 types: analytic, info, warning, severe

**SwiftfulPurchasing**
- RevenueCat (StoreKit available but unused)
- Profile attributes: email, Mixpanel ID, Firebase ID
- Entitlements for premium features

**SwiftfulGamification**
- Streaks, ExperiencePoints, Progress
- All use Firebase + local persistence
- Login coordination in parallel

**SwiftfulHaptics**
- Prepare → Play → Teardown pattern
- Batch operations supported

**SwiftfulSoundEffects**
- URL-based playback
- Async operations

**SwiftfulUtilities**
- Auto-generated event parameters
- App version access

**SwiftfulUI**
- View modifiers: `.anyButton()`, `.callToActionButton()`, `.tappableBackground()`

---

## Code Snippets - Copy/Paste Ready

### Create New Manager (Template)
```swift
// 1. Create alias in Managers/[ManagerName]/SwiftfulManagerName+Alias.swift
typealias NewManager = SwiftfulPackage.NewManager
typealias MockNewService = SwiftfulPackage.MockNewService
typealias ProdNewService = SwiftfulPackage.ProdNewService

extension LogManager: @retroactive NewLogger {
    public func trackEvent(event: any NewLogEvent) {
        trackEvent(eventName: event.eventName, parameters: event.parameters, type: event.type.type)
    }
}

// 2. Add to Dependencies.swift init()
let newManager: NewManager
switch config {
case .mock:
    newManager = NewManager(service: MockNewService(), logger: logManager)
case .dev, .prod:
    newManager = NewManager(service: ProdNewService(), logger: logManager)
}

// 3. Register in container
container.register(NewManager.self, service: newManager)

// 4. Add to CoreInteractor
private let newManager: NewManager
self.newManager = container.resolve(NewManager.self)!

// 5. Use in Presenter
func onAction() {
    interactor.trackEvent(event: Event.actionPerformed)
    // Use newManager via interactor
}
```

### Add Event to Presenter
```swift
enum Event: LoggableEvent {
    case buttonTapped
    case failedWithError(error: Error)
    
    var eventName: String {
        switch self {
        case .buttonTapped: return "ScreenName_ButtonTap"
        case .failedWithError: return "ScreenName_Failed"
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .failedWithError(error: let error):
            return error.eventParameters
        default:
            return nil
        }
    }
    
    var type: LogType {
        switch self {
        case .failedWithError:
            return .severe
        default:
            return .analytic
        }
    }
}
```

### Navigate to Screen
```swift
@MainActor
protocol ScreenRouter: GlobalRouter {
    func showNextScreen()
}

extension CoreRouter: ScreenRouter {
    func showNextScreen() {
        router.showScreen(.push) { router in
            builder.nextScreenView(router: router, delegate: NextScreenDelegate())
        }
    }
}

// In Presenter:
func onButtonTapped() {
    router.showNextScreen()
}
```

### Handle User Login
```swift
func logIn(user: UserAuthInfo, isNewUser: Bool) async throws {
    // Parallel login operations
    async let userLogin: Void = userManager.signIn(auth: user, isNewUser: isNewUser)
    async let purchaseLogin: Void = purchaseManager.logIn(userId: user.uid, userAttributes: ...)
    
    let (_, _) = await (try userLogin, try purchaseLogin)
    
    // Analytics
    logManager.addUserProperties(dict: Utilities.eventParameters, isHighPriority: false)
}
```

---

## Common Mistakes to Avoid

1. **Don't create screens without Router protocol**
   - Always define `protocol ScreenRouter: GlobalRouter`
   - Implement in CoreRouter extension

2. **Don't put business logic in Router**
   - Router = navigation only
   - Logic = Presenter only
   - Data = Interactor only

3. **Don't forget event tracking**
   - Every user action should track an event
   - Use LoggableEvent enum pattern

4. **Don't use @State for managers**
   - Use Presenter with @Observable
   - Managers injected via Interactor

5. **Don't skip the Interactor**
   - Never access managers directly from View
   - Always go through Interactor

6. **Don't initialize managers directly**
   - Use DependencyContainer
   - Initialize only in Dependencies.swift

7. **Don't forget logger injection**
   - All managers need logger parameter
   - LogManager implements all *Logger protocols

8. **Don't hardcode Firestore paths**
   - Define in ProductionServices structs
   - Use collection path closures

9. **Don't mix environments**
   - Use BuildConfiguration enum
   - Separate Mock/Dev/Prod services

10. **Don't create keyed managers without care**
    - Streaks/XP/Progress need unique keys
    - Register with key, resolve with key

---

## Testing Checklist

- [ ] Mock service created for new manager
- [ ] Logger conforms to protocol in Alias file
- [ ] Manager initialized in Dependencies.swift
- [ ] Manager registered in DependencyContainer
- [ ] CoreInteractor resolves new manager
- [ ] Event enum created in Presenter
- [ ] Event tracking added to every method
- [ ] Router protocol created for screen
- [ ] Screen builder method in CoreBuilder extension
- [ ] Screen can be dismissed properly
- [ ] Works in both signed-in and signed-out states

---

## File Templates

Use these as templates for new files:

**Manager Alias File** (Managers/[Name]/Swiftful[Package]+Alias.swift)
```swift
import Swiftful[Package]

typealias [Name]Manager = Swiftful[Package].[Name]Manager
typealias Mock[Name]Service = Swiftful[Package].Mock[Name]Service
typealias Prod[Name]Service = Swiftful[Package].Prod[Name]Service

extension [LogType] {
    var type: LogType {
        switch self {
        case .info: return .info
        case .analytic: return .analytic
        case .warning: return .warning
        case .severe: return .severe
        }
    }
}

extension LogManager: @retroactive [Name]Logger {
    public func trackEvent(event: any [Name]LogEvent) {
        trackEvent(eventName: event.eventName, parameters: event.parameters, type: event.type.type)
    }
}
```

**Screen Router Protocol** (Core/[Screen]/[Screen]Router.swift)
```swift
import SwiftUI

@MainActor
protocol [Screen]Router: GlobalRouter {
    func showNextScreen()
}

extension CoreRouter: [Screen]Router { }
```

**Screen Interactor Protocol** (Core/[Screen]/[Screen]Interactor.swift)
```swift
import SwiftUI

@MainActor
protocol [Screen]Interactor: GlobalInteractor {
    var someData: String { get }
    func fetchData() async throws
}

extension CoreInteractor: [Screen]Interactor {
    var someData: String {
        // Return data
    }
    
    func fetchData() async throws {
        // Fetch logic
    }
}
```

**Screen Presenter** (Core/[Screen]/[Screen]Presenter.swift)
```swift
import SwiftUI

@Observable
@MainActor
class [Screen]Presenter {
    private let interactor: [Screen]Interactor
    private let router: [Screen]Router
    
    init(interactor: [Screen]Interactor, router: [Screen]Router) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }
}

extension [Screen]Presenter {
    enum Event: LoggableEvent {
        case onAppear
        
        var eventName: String { "[Screen]View_Appear" }
        var parameters: [String: Any]? { nil }
        var type: LogType { .analytic }
    }
}
```

---

## Most Used SwiftfulThinking Features

**By Frequency:**
1. LoggableEvent tracking (used in EVERY presenter)
2. Router navigation (all screen transitions)
3. DependencyContainer (all manager access)
4. DataManagerSync (user profile)
5. AuthManager (sign in/out)
6. PurchaseManager (premium features)
7. Gamification managers (streaks/xp/progress)
8. HapticManager (user feedback)
9. AlertStyle (error handling)
10. Utilities.eventParameters (analytics)

**By Complexity:**
1. Gamification coordination (3 managers in parallel)
2. Module switching (multiple environments)
3. Login coordination (multiple async operations)
4. Payment attributes tracking (cross-platform ID correlation)
5. Retroactive protocol conformance (logger pattern)

---

Generated from detailed analysis of SwiftfulStarterProject codebase
All patterns documented in: SWIFTFULTHINKING_PACKAGE_ANALYSIS.md
