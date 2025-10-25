# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## ⚠️ THIS IS A TEMPLATE PROJECT

**This is a starter template designed to be copied and reused for new iOS app projects.**

When working in this codebase:
- **Focus on understanding the PATTERNS, not the specific screens**
- The existing screens (Home, Profile, Settings, etc.) are EXAMPLES showing how to apply the architecture
- When building a new app from this template, you'll DELETE example screens and ADD new screens following the same patterns
- The goal is to maintain the architectural structure while replacing content

---

## ⚡ REQUIRED ACTIONS

These are specific workflows that Claude Code MUST follow when triggered by user requests.

### ACTION 1: Create New Screen

**Triggers:** "create new screen", "create screen", "new screen", "add new screen", or similar requests

**Steps:**

1. **Check if Xcode templates are installed:**
   ```bash
   ls ~/Library/Developer/Xcode/Templates/MyTemplates/VIPERTemplate.xctemplate
   ```

2. **If templates NOT found:**
   - Respond: "The Xcode templates are not installed. Please install them first:"
   - Provide link: https://github.com/SwiftfulThinking/XcodeTemplates
   - Include installation instructions:
     ```bash
     cd ~/Library/Developer/Xcode
     mkdir -p Templates
     # Then drag MyTemplates folder into Templates directory
     ```
   - Stop here. Do not proceed without templates.

3. **If templates ARE installed:**
   - Check if screen name is provided in the request
   - If NOT provided: Ask "What is the name of the new screen?" (e.g., "Home", "Settings", "Profile")
   - Once you have the screen name, proceed to create the screen

4. **Create the screen using templates:**
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

5. **Verify creation:**
   - List the created files to confirm
   - Inform user: "Created new screen with VIPER pattern. Files created in /Core/ScreenName/"

**Important:**
- ALWAYS use the templates when they're installed
- NEVER manually write VIPER files from scratch if templates are available
- The templates ensure consistency with the project's architecture

---

### ACTION 2: Create Reusable Component

**Triggers:** "create component", "new component", "create reusable view", "add component", or similar requests

**Steps:**

1. **Determine component name:**
   - Check if component name is provided in the request
   - If NOT provided: Ask "What is the name of the new component?" (e.g., "CustomButton", "ProfileCard", "LoadingSpinner")
   - Component names should be descriptive and end with appropriate suffix (Button, Card, View, etc.)

2. **Determine component location:**
   - Default location: `/SwiftfulStarterProject/Components/Views/`
   - Ask user if they want it in a different Components subfolder:
     - `/Components/Views/` - General reusable views (DEFAULT)
     - `/Components/Modals/` - Modal/popup components
     - `/Components/Images/` - Image-related components
   - If unsure, use `/Components/Views/`

3. **Create the component file:**
   - Create single file: `ComponentNameView.swift` in chosen location
   - Structure:
     ```swift
     import SwiftUI

     struct ComponentNameView: View {

         // All data is injected - no @State, no @Observable objects
         // Make as much as possible optional for flexibility
         let title: String?
         let isLoading: Bool

         // All actions are injected as closures (optional)
         let onTap: (() -> Void)?

         var body: some View {
             // Unwrap optionals in the view
             if let title {
                 Text(title)
                     .onTapGesture {
                         onTap?()
                     }
             }
         }
     }

     #Preview {
         ComponentNameView(
             title: "Preview Title",
             isLoading: false,
             onTap: { }
         )
     }
     ```

4. **Component Rules (CRITICAL):**
   - **NO business logic** - UI only
   - **NO @State** for data (only for UI state like animations)
   - **NO @Observable objects** or Presenters
   - **NO @StateObject or @ObservedObject**
   - **ALL data is injected** via init parameters
   - **Make as much as possible OPTIONAL** - then unwrap in the view body for maximum flexibility
   - **ALL loading states are injected** as Bool parameters
   - **ALL actions are closures** (e.g., `onTap: (() -> Void)?`, `onSubmit: ((String) -> Void)?`)
   - **ALWAYS use ImageLoaderView** for images (never AsyncImage unless specifically requested)
   - **PREFER maxWidth/maxHeight with alignment** over Spacer() - Use `.frame(maxWidth: .infinity, alignment: .leading)` instead of `Spacer()`
   - **AVOID fixed frames** when possible - let SwiftUI handle sizing naturally
   - **Create MULTIPLE #Previews** showing different data states (all data, partial data, no data, loading, etc.)

5. **Verify creation:**
   - Confirm file location
   - Inform user: "Created reusable component at /Components/Views/ComponentNameView.swift"

**Example Components:**

**Button with loading state:**
```swift
struct CustomButtonView: View {
    let title: String?
    let isLoading: Bool
    let isEnabled: Bool
    let onTap: (() -> Void)?

    var body: some View {
        Button {
            onTap?()
        } label: {
            if isLoading {
                ProgressView()
            } else if let title {
                Text(title)
            }
        }
        .disabled(!isEnabled || isLoading)
    }
}

#Preview("Default") {
    CustomButtonView(
        title: "Submit",
        isLoading: false,
        isEnabled: true,
        onTap: { print("Tapped") }
    )
}

#Preview("Loading") {
    CustomButtonView(
        title: "Submit",
        isLoading: true,
        isEnabled: true,
        onTap: { print("Tapped") }
    )
}

#Preview("Disabled") {
    CustomButtonView(
        title: "Submit",
        isLoading: false,
        isEnabled: false,
        onTap: { print("Tapped") }
    )
}

#Preview("No Title") {
    CustomButtonView(
        title: nil,
        isLoading: false,
        isEnabled: true,
        onTap: { print("Tapped") }
    )
}
```

**Card with image (use ImageLoaderView):**
```swift
struct ProfileCardView: View {
    let imageUrl: String?
    let title: String?
    let subtitle: String?
    let onTap: (() -> Void)?

    var body: some View {
        VStack(spacing: 8) {
            if let imageUrl {
                ImageLoaderView(urlString: imageUrl)
                    .aspectRatio(1, contentMode: .fill)
                    .clipShape(Circle())
            }

            if let title {
                Text(title)
                    .font(.headline)
            }

            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
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
        subtitle: "Software Engineer",
        onTap: { print("Tapped") }
    )
    .frame(width: 150)
}

#Preview("No Image") {
    ProfileCardView(
        imageUrl: nil,
        title: "Jane Smith",
        subtitle: "Designer",
        onTap: { print("Tapped") }
    )
    .frame(width: 150)
}

#Preview("Title Only") {
    ProfileCardView(
        imageUrl: nil,
        title: "Alex Johnson",
        subtitle: nil,
        onTap: nil
    )
    .frame(width: 150)
}

#Preview("Empty") {
    ProfileCardView(
        imageUrl: nil,
        title: nil,
        subtitle: nil,
        onTap: nil
    )
    .frame(width: 150)
}
```

**Layout Best Practices:**

**✅ PREFERRED - Use maxWidth with alignment:**
```swift
VStack(spacing: 8) {
    Text("Title")
        .frame(maxWidth: .infinity, alignment: .leading)

    Text("Description")
        .frame(maxWidth: .infinity, alignment: .leading)
}
```

**❌ AVOID - Using Spacer:**
```swift
VStack(spacing: 8) {
    HStack {
        Text("Title")
        Spacer()
    }

    HStack {
        Text("Description")
        Spacer()
    }
}
```

**Important:**
- Components are DUMB UI - they display what they're told and call callbacks
- All logic stays in Presenters, components just render
- This keeps components reusable across different screens
- Prefer maxWidth/maxHeight with alignment over Spacer for cleaner layouts

---

### ACTION 3: Create New Manager

**Triggers:** "add manager", "new manager", "create manager", "add data manager", "new data source", or similar requests

**Steps:**

1. **Check if Xcode templates are installed:**
   ```bash
   ls ~/Library/Developer/Xcode/Templates/MyTemplates/ManagerTemplate.xctemplate
   ```

2. **If templates NOT found:**
   - Respond: "The Xcode templates are not installed. Please install them first:"
   - Provide link: https://github.com/SwiftfulThinking/XcodeTemplates
   - Include installation instructions:
     ```bash
     cd ~/Library/Developer/Xcode
     mkdir -p Templates
     # Then drag MyTemplates folder into Templates directory
     ```
   - Stop here. Do not proceed without templates.

3. **If templates ARE installed:**
   - Check if manager name is provided in the request
   - If NOT provided: Ask "What is the name of the new manager?" (e.g., "Analytics", "Location", "Notification")
   - Note: Don't include "Manager" suffix in the name - template adds it automatically
   - Ask what data source/dependency this manager will use (e.g., "Firebase", "CoreLocation", "UserNotifications")
   - This is for documentation purposes - helps understand what the Prod service will integrate with

4. **Determine manager type:**
   - Ask: "Should we subclass the SwiftfulDataManagers class? (Yes/No)"
   - **If YES** (using SwiftfulDataManagers for data sync):
     - Ask: "Is this pointing to a single document or an entire collection?"
       - **Document** → Use `DocumentManagerSync` or `DocumentManagerAsync`
       - **Collection** → Use `CollectionManagerSync` or `CollectionManagerAsync`
     - Ask: "Should we sync this in realtime on app launch?"
       - **Yes** → Use Sync variant (real-time updates, local caching, offline support)
       - **No** → Use Async variant (one-off operations, no caching)
     - Proceed to Step 5a (Create Data Sync Manager)
   - **If NO** (standard service manager):
     - Proceed to Step 5b (Create Service Manager using templates)

5a. **Create Data Sync Manager (SwiftfulDataManagers):**
   - Reference `UserManager.swift` as the example pattern
   - Create folder: `/SwiftfulStarterProject/Managers/ManagerName/`
   - Create file: `ManagerNameManager.swift`
   - Extend appropriate base class:
     - `DocumentManagerSync<ModelType>` - Single document with real-time sync
     - `DocumentManagerAsync<ModelType>` - Single document, one-off operations
     - `CollectionManagerSync<ModelType>` - Collection with real-time sync
     - `CollectionManagerAsync<ModelType>` - Collection, one-off operations
   - Structure should include:
     ```swift
     import SwiftUI
     import SwiftfulDataManagers

     @MainActor
     @Observable
     class ManagerNameManager: DocumentManagerSync<YourModel> {

         // Add computed properties for easy access
         var currentData: YourModel? {
             currentDocument
         }

         override init<S: DMDocumentServices>(
             services: S,
             configuration: DataManagerSyncConfiguration = .mockNoPendingWrites(),
             logger: (any DataLogger)? = nil
         ) where S.T == YourModel {
             super.init(services: services, configuration: configuration, logger: logger)
         }

         // Add custom methods as needed
         // func logIn(uid: String) async throws
         // func logOut()
         // func updateData(...) async throws

         // Event tracking enum
         enum Event: DataLogEvent {
             // Define events
         }
     }
     ```
   - Skip to Step 6 for verification
   - Note: Most managers do NOT use SwiftfulDataManagers. Only use for data that needs persistence/sync.

5b. **Create Service Manager using templates:**
   - Read all 4 template files from `~/Library/Developer/Xcode/Templates/MyTemplates/ManagerTemplate.xctemplate/___FILEBASENAME___/`
   - Substitute placeholders:
     - `___VARIABLE_productName:identifier___` → ManagerName (e.g., "Analytics", "Location")
   - Create folder structure: `/SwiftfulStarterProject/Managers/ManagerName/`
   - Create subfolder: `/SwiftfulStarterProject/Managers/ManagerName/Services/`
   - Create 4 files:
     - `ManagerNameManager.swift` (in ManagerName folder)
     - `ManagerNameService.swift` (in Services subfolder)
     - `MockManagerNameService.swift` (in Services subfolder)
     - `ProdManagerNameService.swift` (in Services subfolder)

6. **Verify creation:**
   - List the created files to confirm
   - **If Data Sync Manager (5a):**
     - Inform user: "Created Data Sync Manager extending SwiftfulDataManagers. File created in /Managers/ManagerName/"
     - Remind: "See UserManager.swift for example implementation. Add custom methods as needed."
   - **If Service Manager (5b):**
     - Inform user: "Created Service Manager with protocol and services. Files created in /Managers/ManagerName/"
     - Remind: "The ProdManagerNameService is where you'll integrate with [DataSource]. Add implementation there as needed."

**Manager Structures:**

**Data Sync Manager (SwiftfulDataManagers):**
```
/Managers/ManagerName/
└── ManagerNameManager.swift        # Extends DocumentManagerSync or CollectionManagerSync
```

**Service Manager (Template-based):**
```
/Managers/ManagerName/
├── ManagerNameManager.swift        # @Observable class with service dependency
└── Services/
    ├── ManagerNameService.swift    # Protocol (Sendable)
    ├── MockManagerNameService.swift # Mock implementation (struct)
    └── ProdManagerNameService.swift # Production implementation (struct)
```

**Important:**
- **Most managers use the Service Manager pattern** - Only use SwiftfulDataManagers for data that needs persistence/sync
- ALWAYS use the templates when creating Service Managers
- NEVER manually write Service Manager files from scratch if templates are available
- For Service Managers: DO NOT add any functions to the template files - keep them empty as scaffolding
- For Data Sync Managers: Reference UserManager.swift as the implementation example
- Templates ensure consistency with protocol-based manager pattern

**SwiftfulDataManagers Decision Guide:**
- Use if you need: real-time sync, local caching, offline support, Firestore integration
- Don't use for: Analytics, Haptics, Push Notifications, Sound, or other services without data persistence
- Example use cases: User data, Settings, Posts, Messages, any data stored in Firestore collections

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

## 📐 VIPER Pattern - How to Add New Screens

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
