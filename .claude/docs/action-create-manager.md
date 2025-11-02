# ACTION 3: Create New Manager

**Triggers:** "add manager", "new manager", "create manager", "add data manager", "new data source", or similar requests

---

## Steps

### 1. Check if Xcode templates are installed

```bash
ls ~/Library/Developer/Xcode/Templates/MyTemplates/ManagerTemplate.xctemplate
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

- Check if manager name is provided in the request
- If NOT provided: Ask "What is the name of the new manager?" (e.g., "Analytics", "Location", "Notification")
- Note: Don't include "Manager" suffix in the name - template adds it automatically
- Ask what data source/dependency this manager will use (e.g., "Firebase", "CoreLocation", "UserNotifications")
- This is for documentation purposes - helps understand what the Prod service will integrate with

### 4. Determine manager type

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

---

## 5a. Create Data Sync Manager (SwiftfulDataManagers)

### Gather Information

- Ask: "What is the data model type?" (e.g., "User", "Post", "Message")
- Note: Don't include "Model" suffix - it will be added automatically
- Ask: "What is the Firestore collection path?" (e.g., "users", "chapters_completed", "user_data/progress")
- **NEVER ASSUME** the collection path - always ask the user
- Ask: "What document ID should be used for login?" (e.g., "user.uid", "user.email", "custom ID")
- **NEVER ASSUME** the document ID is user.uid - always ask the user

### Check Model Exists

- Check if model exists at `/Managers/ManagerName/Models/ModelNameModel.swift`
- **If model does NOT exist:**
  - Trigger ACTION 4 to create the model
  - Create it in the same manager folder: `/Managers/ManagerName/Models/`
  - Wait for model creation to complete before proceeding

### Create Manager File

- **If model exists or after creation:**
  - Reference `UserManager.swift` as the example pattern
  - Create folder: `/SwiftfulStarterProject/Managers/ManagerName/`
  - Create file: `ManagerNameManager.swift`
  - Extend appropriate base class with the model type:
    - `DocumentManagerSync<ModelNameModel>` - Single document with real-time sync
    - `DocumentManagerAsync<ModelNameModel>` - Single document, one-off operations
    - `CollectionManagerSync<ModelNameModel>` - Collection with real-time sync
    - `CollectionManagerAsync<ModelNameModel>` - Collection, one-off operations

### Manager Structure

```swift
import SwiftUI
import SwiftfulDataManagers

@MainActor
@Observable
class ManagerNameManager: DocumentManagerSync<ModelNameModel> {

    // Add computed properties for easy access
    var currentData: ModelNameModel? {
        currentDocument
    }

    override init<S: DMDocumentServices>(
        services: S,
        configuration: DataManagerSyncConfiguration = .mockNoPendingWrites(),
        logger: (any DataLogger)? = nil
    ) where S.T == ModelNameModel {
        super.init(services: services, configuration: configuration, logger: logger)
    }

    // REQUIRED for Sync managers: signIn and signOut methods
    func signIn(id: String) async throws {
        logger?.trackEvent(event: Event.signInStart(id: id))
        try await super.logIn(id)
        logger?.trackEvent(event: Event.signInSuccess(id: id))
    }

    func signOut() {
        logger?.trackEvent(event: Event.signOut)
        super.logOut()
    }

    // Add custom methods as needed - ALWAYS track analytics
    // func updateData(...) async throws {
    //     logger?.trackEvent(event: Event.updateStart)
    //     try await updateDocument(...)
    //     logger?.trackEvent(event: Event.updateSuccess)
    // }

    // Event tracking enum
    enum Event: DataLogEvent {
        case signInStart(id: String)
        case signInSuccess(id: String)
        case signOut
        // Add events for all manager methods

        var eventName: String {
            switch self {
            case .signInStart:      return "ManagerNameMan_SignIn_Start"
            case .signInSuccess:    return "ManagerNameMan_SignIn_Success"
            case .signOut:          return "ManagerNameMan_SignOut"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .signInStart(id: let id), .signInSuccess(id: let id):
                return ["id": id]
            case .signOut:
                return nil
            }
        }

        var type: DataLogType {
            switch self {
            default:
                return .analytic
            }
        }
    }
}
```

### Update SwiftfulDataManagers+Alias.swift

**CRITICAL:** Open `/Managers/DataManagers/SwiftfulDataManagers+Alias.swift`

Add typealias for mock services (Document or Collection):
```swift
typealias MockManagerNameServices = SwiftfulDataManagers.MockDMDocumentServices
// OR for collections:
typealias MockManagerNameServices = SwiftfulDataManagers.MockDMCollectionServices
```

Add production services struct using the collection path provided by the user:

#### For STATIC paths (e.g., "users", "chapters_completed"):
```swift
@MainActor
public struct ProductionManagerNameServices: DMDocumentServices {
    public let remote: any RemoteDocumentService<ModelNameModel>
    public let local: any LocalDocumentPersistence<ModelNameModel>

    public init() {
        self.remote = FirebaseRemoteDocumentService<ModelNameModel>(collectionPath: {
            "users"
        })
        self.local = FileManagerDocumentPersistence<ModelNameModel>()
    }
}
```

#### For DYNAMIC paths with SYNC managers (e.g., "user_friends/{uid}/friends"):
```swift
@MainActor
public struct ProductionManagerNameServices: DMCollectionServices {
    public let remote: any RemoteCollectionService<ModelNameModel>
    public let local: any LocalCollectionPersistence<ModelNameModel>

    public init(getUserId: @escaping () -> String?, managerKey: String) {
        self.remote = FirebaseRemoteCollectionService<ModelNameModel>(collectionPath: {
            guard let userId = getUserId() else {
                return nil
            }
            return "user_friends/\(userId)/friends"
        })
        self.local = SwiftDataCollectionPersistence<ModelNameModel>(managerKey: managerKey)
    }
}
```

#### For ASYNC managers (NO local persistence):
```swift
@MainActor
public struct ProductionManagerNameService {
    public let remote: any RemoteCollectionService<ModelNameModel>

    public init(getUserId: @escaping () -> String?) {
        self.remote = FirebaseRemoteCollectionService<ModelNameModel>(collectionPath: {
            guard let userId = getUserId() else {
                return nil
            }
            return "user_friends/\(userId)/friends"
        })
    }
}
```

**Important Notes:**
- **CRITICAL for Async managers:** They do NOT use local persistence - only remote service
- **For Async managers:** Don't conform to `DMCollectionServices` or `DMDocumentServices` - just a plain struct with `remote` property
- **For Async managers:** The manager init uses `service:` (singular) not `services:` (plural)
- **For Async managers:** No `managerKey` parameter needed (since there's no local persistence to configure)
- **For dynamic paths:** The init takes a closure `getUserId: @escaping () -> String?` that fetches the wildcard value at execution time
- **For dynamic paths:** The closure returns `nil` if the wildcard doesn't exist (DON'T return a fallback path)
- **For dynamic paths:** Pass a closure at the callsite that captures authManager: `getUserId: { authManager.auth?.uid }`
- **For dynamic paths:** This allows the path to use the CURRENT authenticated user at query time, not locked at initialization
- **For Sync managers with dynamic paths:** You must also inject the managerKey from the configuration for local persistence
- **For Sync collections:** Use `SwiftDataCollectionPersistence<Model>(managerKey:)` for local persistence
- **For Sync documents:** Use `FileManagerDocumentPersistence<Model>()` for local persistence (no managerKey needed)
- **NEVER ASSUME** the collection path - use exactly what the user specified

### Go to Step 6 for verification

Note: Most managers do NOT use SwiftfulDataManagers. Only use for data that needs persistence/sync.
Note: The model type (ModelNameModel) must match the model you specified/created
**IMPORTANT for Sync managers:** ALWAYS include `signIn(id:)` method that calls `super.logIn(id)` and `signOut()` method that calls `super.logOut()`
**IMPORTANT:** ALWAYS add analytics tracking to every manager method using `logger?.trackEvent(event: Event.methodName)`

---

## 5b. Create Service Manager using templates

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

---

## 6. Verify creation

- List the created files to confirm
- **If Data Sync Manager (5a):**
  - Inform user: "Created Data Sync Manager extending SwiftfulDataManagers. File created in /Managers/ManagerName/"
  - If model was created: "Also created ModelNameModel in /Managers/ManagerName/Models/"
  - Remind: "See UserManager.swift for example implementation. Add custom methods as needed."
  - Remind: "The manager is typed with <ModelNameModel> for type safety."
- **If Service Manager (5b):**
  - Inform user: "Created Service Manager with protocol and services. Files created in /Managers/ManagerName/"
  - Remind: "The ProdManagerNameService is where you'll integrate with [DataSource]. Add implementation there as needed."

---

## 7. Initialize manager in the application

After creating the manager files, you MUST register it in three places for it to work in the app:

### 7a. Update Dependencies.swift

Add manager property declaration at top of `init()` method:
```swift
let managerNameManager: ManagerNameManager
```

#### For Service Managers:

Initialize for each build config (mock/dev/prod) with appropriate services:
```swift
switch config {
case .mock(isSignedIn: let isSignedIn):
    managerNameManager = ManagerNameManager(
        service: MockManagerNameService(),
        logger: logManager
    )
case .dev, .prod:
    managerNameManager = ManagerNameManager(
        service: ProdManagerNameService(),
        logger: logManager
    )
}
```

Register in DependencyContainer (after initialization, before `self.container = container`):
```swift
container.register(ManagerNameManager.self, service: managerNameManager)
```

#### For Data Sync Managers (SwiftfulDataManagers):

Create static configuration property outside the init (with other static configs):
```swift
static let managerNameManagerConfiguration = DataManagerSyncConfiguration(
    managerKey: "ManagerNameMan",
    enablePendingWrites: true  // or false, depending on needs
)
```

Initialize with different services for mock vs prod:

**For STATIC collection paths:**
```swift
switch config {
case .mock(isSignedIn: let isSignedIn):
    managerNameManager = ManagerNameManager(
        services: MockManagerNameServices(document: isSignedIn ? ModelNameModel.mocks.first : nil),
        configuration: Dependencies.managerNameManagerConfiguration,
        logger: logManager
    )
case .dev, .prod:
    managerNameManager = ManagerNameManager(
        services: ProductionManagerNameServices(),
        configuration: Dependencies.managerNameManagerConfiguration,
        logger: logManager
    )
}
```

**For DYNAMIC collection paths with SYNC managers:**
```swift
switch config {
case .mock(isSignedIn: let isSignedIn):
    managerNameManager = ManagerNameManager(
        services: MockManagerNameServices(documents: isSignedIn ? ModelNameModel.mocks : []),
        configuration: Dependencies.managerNameManagerConfiguration,
        logger: logManager
    )
case .dev, .prod:
    // Pass a closure that captures authManager to fetch userId at execution time
    managerNameManager = ManagerNameManager(
        services: ProductionManagerNameServices(
            getUserId: { authManager.auth?.uid },
            managerKey: Dependencies.managerNameManagerConfiguration.managerKey
        ),
        configuration: Dependencies.managerNameManagerConfiguration,
        logger: logManager
    )
}
```

**For DYNAMIC collection paths with ASYNC managers:**
```swift
switch config {
case .mock(isSignedIn: let isSignedIn):
    managerNameManager = ManagerNameManager(
        service: MockRemoteCollectionService(documents: isSignedIn ? ModelNameModel.mocks : []),
        configuration: Dependencies.managerNameManagerConfiguration,
        logger: logManager
    )
case .dev, .prod:
    // Pass a closure that captures authManager to fetch userId at execution time
    managerNameManager = ManagerNameManager(
        service: ProductionManagerNameService(
            getUserId: { authManager.auth?.uid }
        ).remote,
        configuration: Dependencies.managerNameManagerConfiguration,
        logger: logManager
    )
}
```

**Important Notes:**
- **For Async managers:** Use `service:` (singular) not `services:` (plural)
- **For Async managers:** Use `MockRemoteCollectionService` or `MockRemoteDocumentService` for mocks (not the full services wrapper)
- **For Async managers:** Access the `.remote` property from the production service struct
- **For Async managers:** No managerKey needed in the production service init (since there's no local persistence)
- **For dynamic paths:** Pass a closure that captures authManager to get the current userId at execution time
- **For dynamic paths:** The closure `{ authManager.auth?.uid }` is called each time the path is needed, not just at initialization
- **For dynamic paths:** This ensures the manager always uses the CURRENT authenticated user, even if they sign in/out
- **For Sync managers with dynamic paths:** Pass the managerKey from the configuration to the services init
- **For dynamic paths:** DON'T guard or check userId at initialization - let it be nil, the query will handle it

Register in DependencyContainer **with key** from configuration:
```swift
container.register(
    ManagerNameManager.self,
    key: Dependencies.managerNameManagerConfiguration.managerKey,
    service: managerNameManager
)
```

### 7b. Update DevPreview.swift

Add property declaration in class:
```swift
let managerNameManager: ManagerNameManager
```

#### For Service Managers:

Initialize in `init()` with mock service:
```swift
self.managerNameManager = ManagerNameManager(
    service: MockManagerNameService(),
    logger: logManager
)
```

Register in `container()` method:
```swift
container.register(ManagerNameManager.self, service: managerNameManager)
```

#### For Data Sync Managers:

Initialize in `init()` with mock services and mock config:
```swift
self.managerNameManager = ManagerNameManager(
    services: MockManagerNameServices(document: isSignedIn ? ModelNameModel.mocks.first : nil),
    configuration: .mockNoPendingWrites(),
    logger: nil
)
```

Register in `container()` method (no key needed for DevPreview):
```swift
container.register(ManagerNameManager.self, service: managerNameManager)
```

### 7c. Update CoreInteractor.swift

Add private property declaration at top of struct:
```swift
private let managerNameManager: ManagerNameManager
```

Resolve from container in `init()`:

**For Service Managers (no key):**
```swift
self.managerNameManager = container.resolve(ManagerNameManager.self)!
```

**For Data Sync Managers (with key):**
```swift
self.managerNameManager = container.resolve(
    ManagerNameManager.self,
    key: Dependencies.managerNameManagerConfiguration.managerKey
)!
```

Add methods to expose manager functionality (create a new MARK section):
```swift
// MARK: ManagerNameManager

// For Sync Managers ONLY - expose the cached data:
var currentData: ModelNameModel? {
    managerNameManager.currentData
}

// For Async Managers - add methods to fetch as needed (no caching):
// func getData() async throws -> ModelNameModel {
//     try await managerNameManager.getDocument()
// }

// Expose any public methods from the manager:
func doSomething() async throws {
    try await managerNameManager.doSomething()
}
```

**Important:**
- **For Sync managers:** Expose `currentData` or `currentDocuments` (data is cached in memory)
- **For Async managers:** DON'T expose current data - add async fetch methods instead (no caching)

**For Data Sync Managers with Sync support ONLY:**

Update the `logIn()` method to include the new manager using the document ID specified by the user:
```swift
func logIn(user: UserAuthInfo, isNewUser: Bool) async throws {
    // Add to parallel login operations:
    // Use the document ID that was specified when creating the manager
    // Common options: user.uid, user.email, or other custom ID
    async let managerNameLogin: Void = managerNameManager.signIn(id: [USER_SPECIFIED_DOCUMENT_ID])

    // Update the await statement to include it:
    let (_, _, _, _, _, _) = await (try userLogin, try purchaseLogin, try streakLogin, try xpLogin, try progressLogin, try managerNameLogin)
}
```
- **NEVER ASSUME** the document ID is user.uid - use exactly what the user specified earlier

Update the `signOut()` method:
```swift
func signOut() async throws {
    // Add after other sign outs:
    managerNameManager.signOut()
}
```

**Important Notes:**
- Service Managers: Simple initialization with service + logger
- Data Sync Managers: Need DMServices (Mock/Production), configuration, and key for registration
- Only Sync Data Managers need signIn/signOut in CoreInteractor's logIn/signOut methods
- Async Data Managers do NOT need signIn/signOut coordination
- See existing managers (UserManager, StreakManager) as examples

---

## Manager Structures

### Data Sync Manager (SwiftfulDataManagers):
```
/Managers/ManagerName/
├── ManagerNameManager.swift        # Extends DocumentManagerSync<ModelNameModel>
└── Models/
    └── ModelNameModel.swift        # Data model (created via ACTION 4 if needed)
```

### Service Manager (Template-based):
```
/Managers/ManagerName/
├── ManagerNameManager.swift        # @Observable class with service dependency
└── Services/
    ├── ManagerNameService.swift    # Protocol (Sendable)
    ├── MockManagerNameService.swift # Mock implementation (struct)
    └── ProdManagerNameService.swift # Production implementation (struct)
```

---

## Important Notes

- **Most managers use the Service Manager pattern** - Only use SwiftfulDataManagers for data that needs persistence/sync
- ALWAYS use the templates when creating Service Managers
- NEVER manually write Service Manager files from scratch if templates are available
- For Service Managers: DO NOT add any functions to the template files - keep them empty as scaffolding
- For Data Sync Managers: Reference UserManager.swift as the implementation example
- Templates ensure consistency with protocol-based manager pattern

---

## SwiftfulDataManagers Decision Guide

- Use if you need: real-time sync, local caching, offline support, Firestore integration
- Don't use for: Analytics, Haptics, Push Notifications, Sound, or other services without data persistence
- Example use cases: User data, Settings, Posts, Messages, any data stored in Firestore collections
