# SwiftfulThinking Package Integration Analysis
## SwiftfulStarterProject - PROJECT-SPECIFIC USAGE PATTERNS

This document details EXACTLY how each SwiftfulThinking package is implemented in this project, based on actual code analysis (not theoretical capabilities).

---

## 1. SWIFTFULROUTING

### Purpose
Navigation and routing abstraction for the entire app architecture.

### Import & Aliases
**File:** `SwiftfulRouting+Alias.swift`
```swift
typealias RouterView = SwiftfulRouting.RouterView
typealias AnyDestination = SwiftfulRouting.AnyDestination
typealias AnyRouter = SwiftfulRouting.AnyRouter
typealias AlertStyle = SwiftfulRouting.AlertStyle
```

### How It's Used

#### A. Module-Level Navigation (AppView)
Located in `AppView.swift` extension:
```swift
RouterView(id: Constants.tabbarModuleId, addNavigationStack: false, addModuleSupport: true) { _ in
    coreModuleEntryView()
}

RouterView(id: Constants.onboardingModuleId, addNavigationStack: false, addModuleSupport: true) { _ in
    onboardingModuleEntryView()
}
```

**Pattern:** Two modules switch between each other:
- `Constants.tabbarModuleId` ("tabbar") - Main app post-authentication
- `Constants.onboardingModuleId` ("onboarding") - Authentication flows

#### B. Module Switching
```swift
extension CoreRouter {
    func switchToCoreModule() {
        router.showModule(.trailing, id: Constants.tabbarModuleId, onDismiss: nil) { _ in
            self.builder.coreModuleEntryView()
        }
    }
    
    func switchToOnboardingModule() {
        router.showModule(.trailing, id: Constants.onboardingModuleId, onDismiss: nil) { _ in
            self.builder.onboardingModuleEntryView()
        }
    }
}
```

#### C. Screen Navigation (showScreen)
**Patterns used:**
- `.push` - Standard navigation stack
- `.sheet` - Modal presentation
- `.sheetConfig(config:)` - Resizable modal with custom config
- Default (no param) - Default presentation

**Examples:**
```swift
// Push navigation
router.showScreen(.push) { router in
    builder.streakExampleView(router: router, delegate: StreakExampleDelegate())
}

// Sheet modal
router.showScreen(.sheet) { router in
    builder.profileView(router: router, delegate: ProfileDelegate())
}

// Resizable sheet with configuration
router.showScreen(.sheetConfig(config: config)) { _ in
    builder.createAccountView(router: router, delegate: delegate)
}
```

#### D. Screen Dismissal
```swift
// In GlobalRouter extension:
func dismissScreen()  // Generic dismiss
func dismissEnvironment()  // Dismiss entire environment
func dismissPushStack()  // Dismiss navigation stack
func dismissModal()  // Dismiss specific modal
```

#### E. Alert Handling
```swift
// Simple alert
func showSimpleAlert(title: String, subtitle: String?)
func showAlert(error: Error)

// Complex alert with custom buttons
func showAlert(_ option: AlertStyle, title: String, subtitle: String?, buttons: (@Sendable () -> AnyView)?)
```

**Real usage in Settings:**
```swift
router.showAlert(
    title: "Delete Account?",
    subtitle: "This action cannot be undone.",
    buttons: { /* custom buttons */ }
)
```

#### F. Logger Integration
```swift
// In Alias file:
extension LogManager: @retroactive RoutingLogger {
    public func trackEvent(event: any RoutingLogEvent) {
        trackEvent(eventName: event.eventName, parameters: event.parameters, type: event.type.type)
    }
    
    public func trackScreenView(event: any RoutingLogEvent) {
        trackScreenView(event: AnyLoggableEvent(...))
    }
}

// In Dependencies.swift:
SwiftfulRoutingLogger.enableLogging(logger: logManager)
```

### Key Characteristics
- **No navigation code in Views** - All navigation in Presenters via Router
- **Module support via id** - Two main modules with id-based switching
- **AnyRouter type erasure** - Router parameter passed to screen builders
- **Sheet configuration** - Supports ResizableSheetConfig for custom modals
- **Retroactive Logger conformance** - LogManager implements RoutingLogger

---

## 2. SWIFTFULDATAMANAGERS

### Purpose
Real-time data sync, local persistence, offline support for Firestore collections.

### Import & Aliases
**File:** `SwiftfulDataManagers+Alias.swift`
```swift
typealias DataManagerSyncConfiguration = SwiftfulDataManagers.DataManagerSyncConfiguration
typealias DataManagerAsyncConfiguration = SwiftfulDataManagers.DataManagerAsyncConfiguration
typealias MockUserServices = SwiftfulDataManagers.MockDMDocumentServices
```

### Services Architecture

#### Production Services
```swift
@MainActor
public struct ProductionUserServices: DMDocumentServices {
    public let remote: any RemoteDocumentService<UserModel>
    public let local: any LocalDocumentPersistence<UserModel>

    public init() {
        self.remote = FirebaseRemoteDocumentService<UserModel>(collectionPath: {
            "users"  // Static Firestore path
        })
        self.local = FileManagerDocumentPersistence<UserModel>()
    }
}
```

#### Mock Services
```swift
typealias MockUserServices = SwiftfulDataManagers.MockDMDocumentServices
```

### UserManager Implementation
**File:** `UserManager.swift`

```swift
@MainActor
@Observable
class UserManager: DocumentManagerSync<UserModel> {

    var currentUser: UserModel? {
        currentDocument  // Cached user from super class
    }

    override init<S: DMDocumentServices>(
        services: S,
        configuration: DataManagerSyncConfiguration = .mockNoPendingWrites(),
        logger: (any DataLogger)? = nil
    ) where S.T == UserModel {
        super.init(services: services, configuration: configuration, logger: logger)
    }

    // Custom methods
    func signIn(auth: UserAuthInfo, isNewUser: Bool) async throws
    func saveUserName(name: String) async throws
    func saveUserEmail(email: String) async throws
    func deleteCurrentUser() async throws
}
```

### Initialization in Dependencies.swift

**Mock Configuration:**
```swift
case .mock(isSignedIn: let isSignedIn):
    userManager = UserManager(
        services: MockUserServices(document: isSignedIn ? UserModel.mock : nil),
        configuration: Dependencies.userManagerConfiguration,
        logger: logManager
    )
```

**Production Configuration:**
```swift
case .dev, .prod:
    userManager = UserManager(
        services: ProductionUserServices(),
        configuration: Dependencies.userManagerConfiguration,
        logger: logManager
    )
```

**Configuration:**
```swift
static let userManagerConfiguration = DataManagerSyncConfiguration(
    managerKey: "UserMan",
    enablePendingWrites: true
)
```

### Key Characteristics
- **DocumentManagerSync<UserModel>** - Single document (user profile), real-time sync
- **currentDocument property** - Cached in memory, always available
- **FileManagerDocumentPersistence** - Local file caching for offline support
- **FirebaseRemoteDocumentService** - Firestore integration
- **Static collection path** - "users" collection hardcoded (not dynamic)
- **Only one DataManager variant used** - No Async, Collection, or other variants in this project

### Logger Integration
```swift
extension LogManager: @retroactive DataLogger {
    public func trackEvent(event: any DataLogEvent) {
        trackEvent(eventName: event.eventName, parameters: event.parameters, type: event.type.type)
    }
}
```

---

## 3. SWIFTFULAUTHENTICATING

### Purpose
Abstract authentication interface with multiple provider support.

### Import & Aliases
**File:** `SwiftfulAuthenticating+Alias.swift`
```swift
public typealias UserAuthInfo = SwiftfulAuthenticating.UserAuthInfo
typealias AuthManager = SwiftfulAuthenticating.AuthManager
typealias MockAuthService = SwiftfulAuthenticating.MockAuthService
typealias FirebaseAuthService = SwiftfulAuthenticatingFirebase.FirebaseAuthService
typealias SignInOption = SwiftfulAuthenticating.SignInOption
```

### Authentication Providers Available
Not explicitly initialized in code, but inferred from CoreInteractor:
1. **Anonymous** - `signInAnonymously()`
2. **Apple** - `signInApple()`
3. **Google** - `signInGoogle(GIDClientID:)`

### Initialization in Dependencies.swift

**Mock:**
```swift
authManager = AuthManager(
    service: MockAuthService(user: isSignedIn ? .mock() : nil),
    logger: logManager
)
```

**Production (Dev & Prod):**
```swift
authManager = AuthManager(
    service: FirebaseAuthService(),
    logger: logManager
)
```

### Usage in CoreInteractor

```swift
// Sign in methods
func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool)
func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool)
func signInGoogle() async throws -> (user: UserAuthInfo, isNewUser: Bool)

// Sign out
func signOut() async throws

// Current auth state
var auth: UserAuthInfo?
func getAuthId() throws -> String
```

### Key Characteristics
- **AuthManager manages all sign-in providers** - Not split by provider
- **Returns (user, isNewUser) tuple** - Indicates if account is brand new
- **Reauthentication for account deletion** - Supported in deleteAccount flow
- **Firebase backend** - No StoreKit (traditional auth only)

### Logger Integration
```swift
extension LogManager: @retroactive AuthLogger {
    public func trackEvent(event: any AuthLogEvent) {
        trackEvent(eventName: event.eventName, parameters: event.parameters, type: event.type.type)
    }
}
```

---

## 4. SWIFTFULLOGGING

### Purpose
Multi-backend analytics and event tracking abstraction.

### Import & Aliases
**File:** `SwiftfulLogging+Alias.swift`
```swift
typealias LogManager = SwiftfulLogging.LogManager
typealias LoggableEvent = SwiftfulLogging.LoggableEvent
typealias LogType = SwiftfulLogging.LogType
typealias AnyLoggableEvent = SwiftfulLogging.AnyLoggableEvent
typealias ConsoleService = SwiftfulLogging.ConsoleService
typealias MixpanelService = SwiftfulLoggingMixpanel.MixpanelService
typealias FirebaseAnalyticsService = SwiftfulLoggingFirebaseAnalytics.FirebaseAnalyticsService
typealias FirebaseCrashlyticsService = SwiftfulLoggingFirebaseCrashlytics.FirebaseCrashlyticsService
```

### Initialization in Dependencies.swift

**Mock Configuration:**
```swift
logManager = LogManager(services: [
    ConsoleService(printParameters: true, system: .stdout)
])
```

**Dev Configuration:**
```swift
logManager = LogManager(services: [
    ConsoleService(printParameters: true),
    FirebaseAnalyticsService(),
    MixpanelService(token: Keys.mixpanelToken),
    FirebaseCrashlyticsService()
])
```

**Production Configuration:**
```swift
logManager = LogManager(services: [
    FirebaseAnalyticsService(),
    MixpanelService(token: Keys.mixpanelToken),
    FirebaseCrashlyticsService()
])
```

**Note:** Console logging removed from production (for privacy)

### Event Tracking Pattern

**In any Presenter:**
```swift
enum Event: LoggableEvent {
    case onAppear(delegate: HomeDelegate)
    case buttonTapped
    case signInFail(error: Error)

    var eventName: String {
        switch self {
        case .onAppear:     return "HomeView_Appear"
        case .buttonTapped: return "HomeView_ButtonTap"
        case .signInFail:   return "HomeView_SignIn_Fail"
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .signInFail(error: let error):
            return error.eventParameters
        default:
            return nil
        }
    }

    var type: LogType {
        switch self {
        case .signInFail:
            return .severe  // Errors are .severe
        default:
            return .analytic  // Regular events are .analytic
        }
    }
}
```

**In Presenter method:**
```swift
func onViewAppear(delegate: HomeDelegate) {
    interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
}

func handleError(_ error: Error) {
    interactor.trackEvent(event: Event.signInFail(error: error))
}
```

### User Identification & Properties

**In CoreInteractor:**
```swift
func identifyUser(userId: String, name: String?, email: String?) {
    logManager.identifyUser(userId: userId, name: name, email: email)
}

func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
    logManager.addUserProperties(dict: dict, isHighPriority: isHighPriority)
}

func deleteUserProfile() {
    logManager.deleteUserProfile()
}
```

**Called during login:**
```swift
func logIn(user: UserAuthInfo, isNewUser: Bool) async throws {
    // ...
    logManager.addUserProperties(dict: Utilities.eventParameters, isHighPriority: false)
}
```

### Screen View Tracking
```swift
// In GlobalInteractor
func trackScreenEvent(event: LoggableEvent) {
    logManager.trackEvent(event: event)
}
```

### Key Characteristics
- **Multi-service architecture** - Sends events to multiple backends simultaneously
- **Three log types** - `.analytic`, `.info`, `.warning`, `.severe`
- **Console logging in dev only** - Disabled in production
- **Event-driven** - All events follow LoggableEvent protocol
- **User identification** - Mixpanel-style user identification for analytics
- **High-priority flag** - For urgent user property updates

---

## 5. SWIFTFULPURCHASING

### Purpose
In-app purchase abstraction with RevenueCat and StoreKit support.

### Import & Aliases
**File:** `SwiftfulPurchasing+Alias.swift`
```swift
typealias PurchaseManager = SwiftfulPurchasing.PurchaseManager
typealias PurchaseProfileAttributes = SwiftfulPurchasing.PurchaseProfileAttributes
typealias PurchasedEntitlement = SwiftfulPurchasing.PurchasedEntitlement
typealias AnyProduct = SwiftfulPurchasing.AnyProduct
typealias MockPurchaseService = SwiftfulPurchasing.MockPurchaseService
typealias StoreKitPurchaseService = SwiftfulPurchasing.StoreKitPurchaseService
typealias RevenueCatPurchaseService = SwiftfulPurchasingRevenueCat.RevenueCatPurchaseService
```

### Initialization in Dependencies.swift

**Mock:**
```swift
purchaseManager = PurchaseManager(
    service: MockPurchaseService(),
    logger: logManager
)
```

**Production (Dev uses RevenueCat):**
```swift
purchaseManager = PurchaseManager(
    service: RevenueCatPurchaseService(apiKey: Keys.revenueCatAPIKey),
    logger: logManager
)
```

**Note:** StoreKitPurchaseService is available but commented out (not used)

### Usage in CoreInteractor

```swift
var entitlements: [PurchasedEntitlement] {
    purchaseManager.entitlements
}

var isPremium: Bool {
    entitlements.hasActiveEntitlement  // Extension helper
}

func getProducts(productIds: [String]) async throws -> [AnyProduct]
func restorePurchase() async throws -> [PurchasedEntitlement]
func purchaseProduct(productId: String) async throws -> [PurchasedEntitlement]
func updateProfileAttributes(attributes: PurchaseProfileAttributes) async throws
```

### Login Coordination
```swift
// During user login:
async let purchaseLogin: ([PurchasedEntitlement]) = purchaseManager.logIn(
    userId: user.uid,
    userAttributes: PurchaseProfileAttributes(
        email: user.email,
        mixpanelDistinctId: Constants.mixpanelDistinctId,
        firebaseAppInstanceId: Constants.firebaseAnalyticsAppInstanceID
    )
)
```

### Key Characteristics
- **RevenueCat in production** - Single purchase backend
- **Profile attributes tracking** - Email, Mixpanel ID, Firebase ID
- **Entitlements system** - Array of active entitlements
- **Mock service for testing** - Easy to test purchase flows

---

## 6. SWIFTFULGAMIFICATION

### Purpose
Streaks, Experience Points, and Progress tracking with Firebase backend.

### Import & Aliases
**File:** `SwiftfulGamificiation+Alias.swift` (note typo: "Gamificiation")

```swift
// Streaks
typealias StreakManager = SwiftfulGamification.StreakManager
typealias MockStreakServices = SwiftfulGamification.MockStreakServices
typealias StreakConfiguration = SwiftfulGamification.StreakConfiguration
typealias StreakEvent = SwiftfulGamification.StreakEvent
typealias CurrentStreakData = SwiftfulGamification.CurrentStreakData
typealias StreakFreeze = SwiftfulGamification.StreakFreeze

// Experience Points
typealias ExperiencePointsManager = SwiftfulGamification.ExperiencePointsManager
typealias ExperiencePointsConfiguration = SwiftfulGamification.ExperiencePointsConfiguration
typealias CurrentExperiencePointsData = SwiftfulGamification.CurrentExperiencePointsData

// Progress
typealias ProgressManager = SwiftfulGamification.ProgressManager
typealias ProgressConfiguration = SwiftfulGamification.ProgressConfiguration
typealias ProgressItem = SwiftfulGamification.ProgressItem
```

### Service Implementations

**Streak Services:**
```swift
@MainActor
public struct ProdStreakServices: StreakServices {
    public let remote: RemoteStreakService
    public let local: LocalStreakPersistence

    public init() {
        self.remote = FirebaseRemoteStreakService(rootCollectionName: "st_streaks")
        self.local = FileManagerStreakPersistence()
    }
}
```

**Experience Points Services:**
```swift
@MainActor
public struct ProdExperiencePointsServices: ExperiencePointsServices {
    public let remote: RemoteExperiencePointsService
    public let local: LocalExperiencePointsPersistence

    public init() {
        self.remote = FirebaseRemoteExperiencePointsService(rootCollectionName: "st_experience")
        self.local = FileManagerExperiencePointsPersistence()
    }
}
```

**Progress Services:**
```swift
@MainActor
public struct ProdProgressServices: ProgressServices {
    public let remote: RemoteProgressService
    public let local: LocalProgressPersistence

    public init() {
        self.remote = FirebaseRemoteProgressService(rootCollectionName: "st_progress")
        self.local = SwiftDataProgressPersistence()
    }
}
```

### Initialization in Dependencies.swift

**Mock:**
```swift
streakManager = StreakManager(
    services: MockStreakServices(),
    configuration: Dependencies.streakConfiguration,
    logger: logManager
)
xpManager = ExperiencePointsManager(
    services: MockExperiencePointsServices(),
    configuration: Dependencies.xpConfiguration,
    logger: logManager
)
progressManager = ProgressManager(
    services: MockProgressServices(),
    configuration: Dependencies.progressConfiguration,
    logger: logManager
)
```

**Production:**
```swift
streakManager = StreakManager(
    services: ProdStreakServices(),
    configuration: Dependencies.streakConfiguration,
    logger: logManager
)
// ... same for xp and progress
```

### Configurations

```swift
static let streakConfiguration = StreakConfiguration(
    streakKey: Constants.streakKey,
    eventsRequiredPerDay: 1,  // One event/day to maintain streak
    useServerCalculation: false,  // Calculate locally
    leewayHours: 0,  // No grace period
    freezeBehavior: .autoConsumeFreezes  // Auto-use freezes if available
)

static let xpConfiguration = ExperiencePointsConfiguration(
    experienceKey: Constants.xpKey,
    useServerCalculation: false
)

static let progressConfiguration = ProgressConfiguration(
    progressKey: Constants.progressKey
)
```

### Registration in DependencyContainer

```swift
container.register(StreakManager.self, key: Dependencies.streakConfiguration.streakKey, service: streakManager)
container.register(ExperiencePointsManager.self, key: Dependencies.xpConfiguration.experienceKey, service: xpManager)
container.register(ProgressManager.self, key: Dependencies.progressConfiguration.progressKey, service: progressManager)
```

### Usage in CoreInteractor

**Streaks:**
```swift
var currentStreakData: CurrentStreakData {
    streakManager.currentStreakData
}

func addStreakEvent(metadata: [String: GamificationDictionaryValue] = [:]) async throws -> StreakEvent
func getAllStreakEvents() async throws -> [StreakEvent]
func addStreakFreeze(id: String, dateExpires: Date? = nil) async throws -> StreakFreeze
func recalculateStreak()
```

**Experience Points:**
```swift
var currentExperiencePointsData: CurrentExperiencePointsData {
    xpManager.currentExperiencePointsData
}

func addExperiencePoints(points: Int, metadata: [String: GamificationDictionaryValue] = [:]) async throws -> ExperiencePointsEvent
func getAllExperiencePointsEvents() async throws -> [ExperiencePointsEvent]
func recalculateExperiencePoints()
```

**Progress:**
```swift
func getProgress(id: String) -> Double
func getProgressItem(id: String) -> ProgressItem?
func addProgress(id: String, value: Double, metadata: [String: GamificationDictionaryValue]?) async throws -> ProgressItem
func deleteProgress(id: String) async throws
```

### Login Coordination

```swift
func logIn(user: UserAuthInfo, isNewUser: Bool) async throws {
    async let streakLogin: Void = streakManager.logIn(userId: user.uid)
    async let xpLogin: Void = xpManager.logIn(userId: user.uid)
    async let progressLogin: Void = progressManager.logIn(userId: user.uid)

    let (_, _, _) = await (try streakLogin, try xpLogin, try progressLogin)
}

func signOut() async throws {
    streakManager.logOut()
    xpManager.logOut()
    await progressManager.logOut()
}
```

### Key Characteristics
- **Three separate managers** - Streaks, XP, Progress all tracked independently
- **Local persistence with Firebase sync** - FileManager and SwiftData backends
- **Metadata dictionaries** - Events can have custom metadata
- **Configuration-driven** - All behavior configurable
- **Registration by key** - Each manager registered with unique key for multi-instance support

---

## 7. SWIFTFULHAPTICS

### Purpose
Haptic feedback abstraction and preparation.

### Import & Aliases
**File:** `SwiftfulHaptics+Alias.swift`
```swift
typealias HapticManager = SwiftfulHaptics.HapticManager
typealias HapticOption = SwiftfulHaptics.HapticOption
```

### Initialization in Dependencies.swift

**All configurations:**
```swift
hapticManager = HapticManager(logger: logManager)
```

**Note:** No environment-specific initialization - same across Mock, Dev, Prod

### Usage in CoreInteractor

```swift
func prepareHaptic(option: HapticOption) {
    hapticManager.prepare(option: option)
}

func prepareHaptics(options: [HapticOption]) {
    hapticManager.prepare(options: options)
}

func playHaptic(option: HapticOption) {
    hapticManager.play(option: option)
}

func playHaptics(options: [HapticOption]) {
    hapticManager.play(options: options)
}

func tearDownHaptic(option: HapticOption) {
    hapticManager.tearDown(option: option)
}

func tearDownHaptics(options: [HapticOption]) {
    hapticManager.tearDown(options: options)
}

func tearDownAllHaptics() {
    hapticManager.tearDownAll()
}
```

### Also Available in GlobalInteractor

```swift
func playHaptic(option: HapticOption) {
    hapticManager.play(option: option)
}
```

### Key Characteristics
- **Prepare-Play-TearDown pattern** - Pre-load, play, clean up
- **Batch operations** - Can prepare/play multiple haptics at once
- **Simple API** - No configuration needed, always available
- **Logging integrated** - HapticManager extends HapticLogger protocol

---

## 8. SWIFTFULSOUNDEFFECTS

### Purpose
Audio playback abstraction.

### Import & Aliases
**File:** `SwiftfulSoundEffects+Alias.swift`
```swift
typealias SoundEffectManager = SwiftfulSoundEffects.SoundEffectManager
```

### Initialization in Dependencies.swift

**All configurations:**
```swift
soundEffectManager = SoundEffectManager(logger: logManager)
```

### Usage in CoreInteractor

```swift
func prepareSoundEffect(sound: SoundEffectFile, simultaneousPlayers: Int = 1) {
    Task {
        await soundEffectManager.prepare(url: sound.url, simultaneousPlayers: simultaneousPlayers, volume: 1)
    }
}

func tearDownSoundEffect(sound: SoundEffectFile) {
    Task {
        await soundEffectManager.tearDown(url: sound.url)
    }
}

func playSoundEffect(sound: SoundEffectFile) {
    Task {
        await soundEffectManager.play(url: sound.url)
    }
}
```

### Key Characteristics
- **URL-based sounds** - Uses SoundEffectFile which contains URL
- **Async operations** - All sound operations wrapped in Task
- **Simultaneous players** - Can configure polyphony per sound
- **Volume control** - Hard-coded to 1.0 in this project
- **No preview preparation** - Unlike haptics, sounds are played directly

---

## 9. SWIFTFUTUTILITIES

### Purpose
Shared utility functions and helpers.

### Import & Aliases
**File:** `SwiftfulUtilities+Alias.swift`
```swift
typealias Utilities = SwiftfulUtilities.Utilities
```

### Usage Pattern

**Single Utilities struct access:**
```swift
// In AppPresenter:
import SwiftfulUtilities

// Get event parameters (auto-generated device info)
logManager.addUserProperties(dict: Utilities.eventParameters, isHighPriority: false)

// In UserManager:
let creationVersion = isNewUser ? Utilities.appVersion : nil
```

### Key Characteristics
- **Static utility methods** - All accessed as `Utilities.something`
- **Event parameters** - Auto-generates device/app info for analytics
- **App version** - Quick access to current version number
- **Minimal direct usage** - Only used when convenient

---

## 10. SWIFTFULUI PACKAGE

### Purpose
Reusable UI components (referenced but not aliased).

### Imports Found

```swift
import SwiftfulUI

// Used in:
// - AppView.swift
// - HomeView.swift
// - WelcomeView.swift
```

### Known Components Used

```swift
// View modifier extensions
.callToActionButton()  // Styling for CTA buttons
.tappableBackground()  // Interactive background
.anyButton(.press)  // Generic button handling (with .press, .highlight options)
.ifSatisfiesCondition()  // Conditional view modifier
```

### Also Uses
```swift
import SwiftfulAuthUI
// Used for OAuth button views:
SignInAppleButtonView
SignInGoogleButtonView
```

### Key Characteristics
- **Not aliased** - Used directly from package
- **Extensions/Modifiers** - View-level functionality
- **Button handling abstraction** - `.anyButton()` replaces Button()
- **Auth UI for OAuth** - Apple/Google sign-in buttons

---

## ARCHITECTURAL PATTERNS SUMMARY

### 1. Manager Registration Pattern

```swift
// In Dependencies.swift
container.register(ManagerType.self, service: manager)  // Default registration
container.register(ManagerType.self, key: uniqueKey, service: manager)  // Keyed registration
```

### 2. Manager Initialization Pattern

**Service Managers (Most common):**
```swift
manager = ManagerType(
    service: ServiceType(),  // Protocol-based service
    logger: logManager
)
```

**Data Managers (SwiftfulDataManagers):**
```swift
manager = DataManager(
    services: ServicesType(),  // DMDocumentServices or DMCollectionServices
    configuration: DataManagerSyncConfiguration(...),
    logger: logManager
)
```

### 3. Presenter Event Tracking Pattern

```swift
@Observable
@MainActor
class Presenter {
    func onSomeAction() {
        interactor.trackEvent(event: Event.someAction)
    }
}

extension Presenter {
    enum Event: LoggableEvent {
        case someAction
        // ... other cases
    }
}
```

### 4. Router Method Registration Pattern

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
```

### 5. Login Coordination Pattern

```swift
func logIn(user: UserAuthInfo, isNewUser: Bool) async throws {
    // All login operations in parallel
    async let manager1: Void = manager1.logIn(userId: user.uid)
    async let manager2: Void = manager2.logIn(userId: user.uid)
    
    let (_, _) = await (try manager1, try manager2)
    
    // Analytics
    logManager.addUserProperties(dict: properties, isHighPriority: false)
}
```

### 6. Logout Pattern

```swift
func signOut() async throws {
    try authManager.signOut()
    try await purchaseManager.logOut()
    userManager.signOut()
    streakManager.logOut()
    xpManager.logOut()
    await progressManager.logOut()
}
```

---

## DEPENDENCY INJECTION FLOW

```
SwiftfulStarterProjectApp (main entry)
    ↓
Dependencies.swift (creates managers based on BuildConfiguration)
    ↓
DependencyContainer (registers all managers)
    ↓
AppView (gets container)
    ↓
CoreBuilder (has CoreInteractor)
    ↓
CoreInteractor (resolves managers from container)
    ↓
Screen Interactor/Router/Presenter (use CoreInteractor)
```

---

## KEY TAKEAWAYS - PROJECT-SPECIFIC

1. **Only DocumentManagerSync used** from SwiftfulDataManagers - not async or collections
2. **Three gamification managers** work in parallel during login
3. **Two module system** - Onboarding vs Tabbar, switched via `showModule()`
4. **Multi-backend logging** - Console (dev), Firebase Analytics, Mixpanel, Crashlytics
5. **RevenueCat for purchases** - StoreKit available but not used
6. **Event-driven analytics** - Every user action tracked via LoggableEvent protocol
7. **Router does nothing but navigate** - All business logic in Presenter
8. **Screen builders in extensions** - AppView, each screen view extends CoreBuilder
9. **Retroactive protocol conformance** - LogManager implements all *Logger protocols
10. **Key-based manager registration** - Some managers (streaks, xp, progress) use keys

