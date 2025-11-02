# Project Architecture & Structure

## ⚠️ THIS IS A TEMPLATE PROJECT

**This is a starter template designed to be copied and reused for new iOS app projects.**

When working in this codebase:
- **Focus on understanding the PATTERNS, not the specific screens**
- The existing screens (Home, Profile, Settings, etc.) are EXAMPLES showing how to apply the architecture
- When building a new app from this template, you'll DELETE example screens and ADD new screens following the same patterns
- The goal is to maintain the architectural structure while replacing content

---

## Architecture Overview

**Type**: iOS SwiftUI Application
**Architecture**: VIPER + RIBs (Routable, Interactable, Buildable)
**Tech Stack**: SwiftUI, Swift 5.9+, Firebase, RevenueCat, Mixpanel
**Build System**: Xcode project with 3 build configurations (Mock, Dev, Prod)

---

## 🎯 Core Concepts to Understand

### 1. VIPER per Screen (Most Important)
Every screen has 4 components:
- **View** (SwiftUI) - UI only, no logic
- **Presenter** (`@Observable` class) - All business logic and state
- **Router** (Protocol) - Navigation methods
- **Interactor** (Protocol) - Data access methods

**Key Rule**: Views never access data directly. Always go through Presenter → Interactor → Manager.

### 2. RIBs for Module Coordination
- **CoreRouter** implements all router protocols
- **CoreInteractor** implements all interactor protocols
- **CoreBuilder** creates all screens with dependencies

This means adding a new screen requires extending these 3 classes.

### 3. DependencyContainer (Service Locator)
All managers registered once, resolved anywhere:
```swift
container.register(AuthManager.self, service: authManager)
container.resolve(AuthManager.self) // Get the singleton instance
```

### 4. Three Build Configurations
- **Mock** - No Firebase, fast development, mock data
- **Development** - Real Firebase with dev credentials
- **Production** - Real Firebase with prod credentials

Use Mock for 90% of development, switch to Dev/Prod only when testing integrations.

### 5. Module-Based Navigation
App has two main modules:
- **Onboarding Module** - Pre-authentication flows
- **TabBar Module** - Post-authentication main app

Switch between them using `router.showModule(moduleId)`.

---

## Project Structure

```
SwiftfulStarterProject/
├── SwiftfulStarterProject/           # Main app source code
│   ├── Root/                         # App entry point and RIBs root
│   │   ├── SwiftfulStarterProjectApp.swift    # @main app entry point
│   │   ├── AppDelegate.swift         # UIApplicationDelegate with Firebase config
│   │   ├── RIBs/                     # RIBs pattern (Router, Interactor, Builder)
│   │   │   ├── Core/                 # Core RIB containing all screens
│   │   │   │   ├── CoreRouter.swift
│   │   │   │   ├── CoreInteractor.swift
│   │   │   │   └── CoreBuilder.swift
│   │   │   └── Global/               # Base protocols for Router/Interactor
│   │   │       ├── GlobalRouter.swift
│   │   │       ├── GlobalInteractor.swift
│   │   │       └── Builder.swift
│   │   ├── Dependencies/             # Dependency injection
│   │   │   ├── DependencyContainer.swift   # Service locator pattern
│   │   │   └── Dependencies.swift    # Dependency initialization for Mock/Dev/Prod
│   │   └── EntryPoints/              # Alternative app entry points for testing
│   │       ├── AppViewForUnitTesting.swift
│   │       └── AppViewForUITesting.swift
│   │
│   ├── Core/                         # All VIPER screens (THESE ARE EXAMPLES - replace with your own)
│   │   ├── AppView/                  # Root navigation coordinator (KEEP THIS)
│   │   │   ├── AppView.swift         # Root presenter view
│   │   │   ├── AppPresenter.swift    # Root business logic
│   │   │   └── AppViewInteractor.swift
│   │   ├── TabBar/                   # Bottom tab navigation (PATTERN EXAMPLE)
│   │   │   ├── TabBarView.swift
│   │   │   ├── TabBarPresenter.swift
│   │   │   └── TabBarInteractor.swift
│   │   ├── Home/                     # EXAMPLE screen showing VIPER pattern
│   │   │   ├── HomeView.swift
│   │   │   ├── HomePresenter.swift
│   │   │   ├── HomeRouter.swift
│   │   │   └── HomeInteractor.swift
│   │   ├── Profile/                  # EXAMPLE screen
│   │   ├── Settings/                 # EXAMPLE screen
│   │   ├── Welcome/                  # EXAMPLE onboarding screen
│   │   ├── CreateAccount/            # EXAMPLE account creation
│   │   ├── OnboardingCompletedView/  # EXAMPLE onboarding completion
│   │   ├── Onboarding/               # EXAMPLE onboarding flow
│   │   ├── Paywall/                  # EXAMPLE paywall (if using IAP)
│   │   ├── StreakExample/            # EXAMPLE gamification feature
│   │   ├── ExperiencePointsExample/  # EXAMPLE gamification feature
│   │   ├── ProgressExample/          # EXAMPLE gamification feature
│   │   └── DevSettings/              # Dev-only settings (KEEP THIS)
│   │
│   ├── Managers/                     # Business logic and data services (22 files)
│   │   ├── Auth/                     # Authentication management
│   │   ├── User/                     # User profile and data
│   │   │   ├── Models/
│   │   │   ├── UserManager.swift
│   │   │   └── SwiftfulDataManagers+Alias.swift
│   │   ├── AppState/                 # Global app state
│   │   ├── Purchases/                # In-app purchase management
│   │   ├── Logs/                     # Analytics and logging
│   │   ├── Push/                     # Push notification handling
│   │   ├── Haptics/                  # Haptic feedback
│   │   ├── SoundEffects/             # Sound effect playback
│   │   ├── Gamification/             # Streaks, XP, progress
│   │   ├── ABTests/                  # A/B testing
│   │   ├── ImageUpload/              # Image upload service
│   │   └── Routing/                  # Navigation routing
│   │
│   ├── Components/                   # Reusable UI components
│   │   ├── Views/                    # Custom view components
│   │   ├── Modals/                   # Modal UI patterns
│   │   ├── Images/                   # Image utilities
│   │   ├── PropertyWrappers/         # Custom property wrappers
│   │   │   └── UserDefaultPropertyWrapper.swift
│   │   └── ViewModifiers/            # Custom SwiftUI modifiers
│   │       ├── OnFirstAppearViewModifier.swift
│   │       └── ... other modifiers
│   │
│   ├── Extensions/                   # Swift extensions (13 files)
│   │   ├── Array+EXT.swift
│   │   ├── String+EXT.swift
│   │   ├── Color+EXT.swift
│   │   ├── View+EXT.swift
│   │   └── ... other extensions
│   │
│   ├── Utilities/                    # Shared utilities
│   │   ├── Constants.swift           # App constants
│   │   ├── Keys.swift                # API keys
│   │   └── NotificationCenter.swift  # Custom notifications
│   │
│   ├── SupportingFiles/              # App assets and config
│   │   ├── GoogleServicePLists/      # Firebase configs
│   │   └── ... other resources
│   │
│   └── Info.plist
│
├── SwiftfulStarterProject.xcodeproj  # Xcode project
│   └── xcshareddata/xcschemes/       # Build schemes
│       ├── SwiftfulStarterProject - Mock.xcscheme
│       ├── SwiftfulStarterProject - Development.xcscheme
│       └── SwiftfulStarterProject - Production.xcscheme
│
├── SwiftfulStarterProjectUnitTests/  # Unit tests
├── SwiftfulStarterProjectUITests/    # UI tests
├── README.md                         # Project documentation
├── .swiftlint.yml                    # SwiftLint configuration
├── .gitignore
└── rename_project.sh                 # Script to rename project
```

---

## Key Architectural Patterns

### 1. VIPER Architecture (Per Screen)

Each screen follows the VIPER pattern with 4-5 components:

- **View**: SwiftUI view displaying the UI
  - Uses `@State` to hold presenter
  - Handles user interactions
  - Calls presenter methods for business logic

- **Presenter**: Observable business logic class
  - Marked with `@Observable` and `@MainActor`
  - Holds interactor and router references
  - Orchestrates view updates through SwiftUI reactivity
  - Tracks events using LoggableEvent protocol

- **Interactor**: Handles data-related logic
  - Protocol extending `GlobalInteractor`
  - Accesses managers and performs data operations
  - Implemented by `CoreInteractor`

- **Router**: Handles navigation logic
  - Protocol extending `GlobalRouter`
  - Routes to other screens
  - Manages presentation style (push, modal, etc.)
  - Implemented by `CoreRouter`

- **Entity**: Data model for the screen
  - Example: `HomeDelegate` containing event parameters

### 2. RIBs Pattern (Module-Level)

Currently one RIB handles the entire app core (can be split):

- **Router**: Handles module-level routing
  - Switch between major modules (onboarding, tabbar)
  - Manage module transitions

- **Interactor**: Module-level data access
  - Access all managers through dependency container
  - Coordinate multi-manager operations

- **Builder**: Creates all screens in the module
  - Factory methods for building screens with VIPER components
  - Dependency injection point

### 3. Dependency Injection Pattern

**DependencyContainer** (Service Locator):
```swift
container.register(AuthManager.self, service: authManager)
container.resolve(AuthManager.self) // Returns service
```

**BuildConfiguration** enum provides environment-specific setup:
- `.mock(isSignedIn: Bool)` - Testing without Firebase
- `.dev` - Development with Firebase Dev config
- `.prod` - Production with Firebase Prod config

**DevPreview** utility:
- Provides mock dependencies for SwiftUI previews
- Enables rapid UI development without full app initialization

### 4. Managers Architecture

**Protocol-Based Design**: All managers are erased to protocols

Key managers:
- **AuthManager**: Firebase authentication (sign in, sign out, delete account)
- **UserManager**: DocumentManagerSync (real-time Firestore user data)
- **LogManager**: Analytics (Firebase Analytics, Mixpanel, Crashlytics)
- **PurchaseManager**: In-app purchases (RevenueCat/StoreKit)
- **StreakManager**: Gamification streaks tracking
- **ExperiencePointsManager**: Gamification XP tracking
- **ProgressManager**: Gamification progress tracking
- **PushManager**: Push notifications via Firebase
- **HapticManager**: Haptic feedback
- **SoundEffectManager**: Audio playback
- **ABTestManager**: A/B testing (Firebase or local)
- **AppState**: Observable global app state

---

## Build Configurations

### Three Build Schemes

1. **Mock Scheme** (Development/Testing)
   - No Firebase dependency
   - Allows testing signed-in and signed-out states
   - Uses mock services for all managers
   - Fastest build time

2. **Development Scheme**
   - Full Firebase integration with Dev credentials
   - Real analytics, logging, A/B testing
   - Uses production-like services

3. **Production Scheme**
   - Firebase with production credentials
   - All production services enabled
   - Different GoogleService-Info plist

### Build Flags

- `MOCK`: Disables Firebase, uses mock services
- `DEV`: Development Firebase configuration
- Production (default): Production configuration

### Environment-Specific Behavior

```swift
#if MOCK
    // Mock code
#elseif DEV
    // Dev code
#else
    // Prod code
#endif
```

---

## Module Navigation

### Module System

The app uses SwiftfulRouting with module support:

**Two Main Modules**:
- `Constants.onboardingModuleId` ("onboarding") - Authentication flows
- `Constants.tabbarModuleId` ("tabbar") - Main app with tab navigation

**Module Switching**:
- After authentication → Switch from onboarding to tabbar module
- Sign out → Switch from tabbar to onboarding module
- Uses `router.showModule()` for transitions

### Routing Hierarchy

```
AppView (Root)
├── RouterView (onboarding module) → OnboardingView → Welcome, CreateAccount, etc.
└── RouterView (tabbar module) → TabBarView
    ├── Home Screen → (nested navigation)
    ├── Features Screen → Gamification Examples
    └── Profile Screen
```

---

## 💡 Understanding the Manager System

The template includes many pre-built managers for common iOS app features. You can use what you need and remove what you don't.

### Available Managers (Pick and Choose)

**Essential (Usually Keep):**
- `AuthManager` - Firebase authentication
- `UserManager` - User profile and Firestore data sync
- `LogManager` - Analytics and logging
- `AppState` - Global app state

**Optional (Remove if not needed):**
- `PurchaseManager` - In-app purchases (RevenueCat)
- `StreakManager` - Gamification streaks
- `ExperiencePointsManager` - Gamification XP system
- `ProgressManager` - Gamification progress tracking
- `PushManager` - Push notifications
- `HapticManager` - Haptic feedback
- `SoundEffectManager` - Audio playback
- `ABTestManager` - A/B testing
- `ImageUploadManager` - Image uploads

### How Managers Work

All managers are:
1. **Protocol-based** - Easy to mock for testing
2. **Registered in DependencyContainer** - Single source of truth
3. **Accessed via Interactor** - Screens never directly access managers

**Example: Using a Manager in a Screen**
```swift
// In YourScreenInteractor protocol
protocol YourScreenInteractor: GlobalInteractor {
    var currentUser: UserObject? { get }
}

// In CoreInteractor implementation
extension CoreInteractor: YourScreenInteractor {
    var currentUser: UserObject? {
        container.resolve(UserManager.self).currentUser
    }
}

// In YourScreenPresenter
presenter.user = interactor.currentUser
```

---

## 📱 Example Features Included (Optional Reference)

The template includes example implementations to demonstrate patterns. **These are NOT required in your app** - they show you HOW to build features.

### Example: Gamification System
- `StreakManager` - Daily streak tracking with freezes
- `ExperiencePointsManager` - Points accumulation
- `ProgressManager` - Goal-based progress
- Example screens showing UI patterns for each

### Example: Analytics & Logging
- `LoggableEvent` protocol pattern
- Multiple backends (Firebase, Mixpanel, Crashlytics)
- Event tracking in Presenters

### Example: Authentication
- Anonymous, Apple, Google sign-in methods
- Account deletion with reauthentication
- See `CreateAccountView` for implementation example

### Example: In-App Purchases
- RevenueCat integration via `PurchaseManager`
- Paywall screen example
- Entitlement checking pattern

### Example: Push Notifications & Deep Linking
- `PushManager` for FCM
- Deep link handling in Presenters
- See `AppPresenter` for routing logic

---

## Testing Setup

### Unit Tests
- Located in `SwiftfulStarterProjectUnitTests/`
- Basic structure provided, mockable architecture enables easy testing
- Presenters and Interactors can be tested in isolation

### UI Tests
- Located in `SwiftfulStarterProjectUITests/`
- Launch arguments for test configuration
- `SIGNED_IN` argument controls signed-in state for tests
- App uses `Utilities.isUITesting` to detect test environment

### Entry Points for Testing
- `AppViewForUnitTesting.swift` - Minimal app setup for unit tests
- `AppViewForUITesting.swift` - Full app with mock config for UI tests

---

## Code Organization Patterns

### Extensions Pattern
- Standard Swift types extended: Array, String, Color, View, Error, etc.
- Located in `Extensions/` folder
- Naming convention: `TypeName+EXT.swift`

### Property Wrappers
- Custom `@UserDefaultProperty` for UserDefaults integration
- Located in `Components/PropertyWrappers/`

### View Modifiers
- Reusable SwiftUI modifiers
- `OnFirstAppearViewModifier` for first-appear logic
- Located in `Components/ViewModifiers/`

### Custom Views
- Reusable UI components
- Located in `Components/Views/`

---

## Code Quality & Standards

### SwiftLint Configuration
- Line length warning: 300 characters
- Type body length warning: 500 lines
- File length warning: 750 lines
- Disabled rules: trailing_whitespace

### Build Flags
- Use `@MainActor` for thread safety
- Use `@Observable` for reactive state (iOS 17+)
- All async operations use structured concurrency (async/await)

---

## Dependencies

### External Packages (Swiftful Thinking Libraries)

- **SwiftfulRouting**: Navigation and routing with module support
- **SwiftfulAuthenticating**: Abstract auth framework
- **SwiftfulAuthenticatingFirebase**: Firebase auth implementation
- **SwiftfulFirestore**: Firestore data manager wrapper
- **SwiftfulDataManagers**: Reusable data manager patterns
- **SwiftfulUI**: Common UI components
- **SwiftfulUtilities**: Utility functions and extensions
- **SwiftfulHaptics**: Haptic feedback abstraction
- **SwiftfulLogging**: Abstract logging framework
- **SwiftfulLoggingFirebaseCrashlytics**: Crashlytics integration
- **SwiftfulLoggingMixpanel**: Mixpanel integration
- **SwiftfulLoggingFirebaseAnalytics**: Firebase Analytics integration
- **SwiftfulPurchasing**: In-app purchase abstraction
- **SwiftfulPurchasingRevenueCat**: RevenueCat implementation
- **SwiftfulSoundEffects**: Audio playback abstraction

### External Frameworks

- **Firebase**: Cloud Messaging, Authentication, Firestore, Analytics
- **Google Sign-In**: OAuth integration
- **RevenueCat**: Subscription and purchase management
- **Mixpanel**: Analytics and event tracking
- **SDWebImageSwiftUI**: Image loading and caching

---

## 🔧 HOW TO USE THIS TEMPLATE

### Starting a New Project from This Template

**What to KEEP (Core Infrastructure):**
- `/Root/` folder - App entry point, RIBs, Dependencies, AppDelegate
- `/Managers/` folder - All manager protocols and implementations
- `/Components/` folder - Reusable UI components, modifiers, property wrappers
- `/Extensions/` folder - All Swift extensions
- `/Utilities/` folder - Constants, Keys, helpers
- `AppView/` - Root navigation coordinator
- Build configurations (Mock, Dev, Prod)

**What to REPLACE (Example Screens):**
- Delete example screens in `/Core/` (Home, Profile, Settings, Onboarding examples, etc.)
- Keep only `AppView/`, `TabBar/` (if using tabs), and `DevSettings/`
- Add your own screens following the VIPER pattern

**What to MODIFY:**
- `Constants.swift` - Update app-specific constants
- `Keys.swift` - Add your API keys
- GoogleService plists - Replace with your Firebase project configs
- Manager implementations - Enable/disable based on your needs (e.g., remove Gamification if not needed)

---

## Common Development Workflows

### Testing a Feature

1. Run Mock scheme for fastest turnaround
2. Use `DevPreview` for SwiftUI previews
3. Configure test state via `ProcessInfo.processInfo.arguments`

### Configuring Firebase

1. Place `GoogleService-Info-Dev.plist` for development
2. Place `GoogleService-Info-Prod.plist` for production
3. Both files go in `SupportingFiles/GoogleServicePLists/`
4. AppDelegate loads correct config based on build scheme

---

## Quick Reference: Common Patterns

### Log an Event from a Presenter
```swift
func trackEvent(event: Event) {
    interactor.trackEvent(event: event)
}

// Usage
trackEvent(event: .buttonTapped)
```

### Navigate to Another Screen
```swift
// In Router protocol
protocol YourScreenRouter: GlobalRouter {
    func showNextScreen()
}

// In CoreRouter implementation
extension CoreRouter: YourScreenRouter {
    func showNextScreen() {
        router.showScreen(.push) { router in
            builder.nextScreenView(router: router, delegate: NextScreenDelegate())
        }
    }
}

// In Presenter
func onButtonTapped() {
    router.showNextScreen()
}
```

### Access Manager Data
```swift
// In Interactor protocol
protocol YourScreenInteractor: GlobalInteractor {
    var currentUser: UserObject? { get }
}

// In CoreInteractor
extension CoreInteractor: YourScreenInteractor {
    var currentUser: UserObject? {
        container.resolve(UserManager.self).currentUser
    }
}

// In Presenter
let user = interactor.currentUser
```

### Make Async Operation
```swift
// In Interactor protocol
protocol YourScreenInteractor: GlobalInteractor {
    func saveData() async throws
}

// In CoreInteractor
extension CoreInteractor: YourScreenInteractor {
    func saveData() async throws {
        try await container.resolve(SomeManager.self).save()
    }
}

// In Presenter
func onSaveButtonTapped() {
    Task {
        try await interactor.saveData()
    }
}
```

### Switch Build Configuration
- Xcode: Product → Scheme → Select scheme
- Options: Mock (fast, no Firebase), Development (Firebase Dev), Production (Firebase Prod)

### Important Module Constants
```swift
Constants.onboardingModuleId // "onboarding" module
Constants.tabbarModuleId     // "tabbar" module

// Switch modules
router.showModule(Constants.tabbarModuleId)
```

---

## Resources

- Official Documentation: https://www.swiftful-thinking.com/offers/REyNLwwH
- Xcode Templates: https://github.com/SwiftfulThinking/XcodeTemplates
  - Install these for rapid VIPER screen generation
  - Creates all 4 files automatically with proper structure
