//
//  Dependencies.swift
//  SwiftfulStarterProject
//
//  
//
import SwiftUI
import SwiftfulRouting
import SwiftfulDataManagers
import SwiftfulDataManagersFirebase

@MainActor
struct Dependencies {
    let container: DependencyContainer

    // swiftlint:disable:next function_body_length
    init(config: BuildConfiguration) {
        let authManager: AuthManager
        let userManager: UserManager
        let abTestManager: ABTestManager
        let purchaseManager: PurchaseManager
        let appState: AppState
        let logManager: LogManager
        let pushManager: PushManager
        let hapticManager: HapticManager
        let soundEffectManager: SoundEffectManager
        let streakManager: StreakManager
        let xpManager: ExperiencePointsManager
        let progressManager: ProgressManager
        
        switch config {
        case .mock(isSignedIn: let isSignedIn, addLogging: let addLogging):
            logManager = LogManager(services: addLogging ? [
                ConsoleService(printParameters: true, system: .stdout)
            ] : [])
            authManager = AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil), logger: logManager, markerStore: InMemoryRealAccountMarkerStore())
            userManager = UserManager(userSyncEngine: DocumentSyncEngine<UserModel>(
                remote: MockRemoteDocumentService(document: isSignedIn ? UserModel.mock : nil),
                managerKey: "UserMan",
                enableLocalPersistence: false,
                logger: logManager
            ))
            
            // Note: configure AB tests for UI tests here
            //
            // let isInTest = ProcessInfo.processInfo.arguments.contains("SOMETEST")
            let abTestService = MockABTestService(
                boolTest: nil,
                enumTest: nil
            )
            abTestManager = ABTestManager(service: abTestService, logManager: logManager)
            purchaseManager = PurchaseManager(service: MockPurchaseService(activeEntitlements: [], availableProducts: AnyProduct.mocks), logger: logManager)
            appState = AppState(startingModuleId: isSignedIn ? Constants.tabbarModuleId : Constants.onboardingModuleId)
            hapticManager = HapticManager(logger: logManager)
            streakManager = StreakManager(services: MockStreakServices(), configuration: Dependencies.streakConfiguration, logger: logManager)
            xpManager = ExperiencePointsManager(services: MockExperiencePointsServices(), configuration: Dependencies.xpConfiguration, logger: logManager)
            progressManager = ProgressManager(services: MockProgressServices(), configuration: Dependencies.progressConfiguration, logger: logManager)
        case .dev, .prod:
            if case .dev = config {
                logManager = LogManager(services: [
                    ConsoleService(printParameters: true),
                    FirebaseAnalyticsService(),
                    MixpanelService(token: Keys.mixpanelToken),
                    FirebaseCrashlyticsService()
                ])
            } else {
                logManager = LogManager(services: [
                    FirebaseAnalyticsService(),
                    MixpanelService(token: Keys.mixpanelToken),
                    FirebaseCrashlyticsService()
                ])
            }
            authManager = AuthManager(service: FirebaseAuthService(), logger: logManager)
            userManager = UserManager(userSyncEngine: DocumentSyncEngine<UserModel>(
                remote: FirebaseRemoteDocumentService(collectionPath: { "users" }),
                managerKey: "UserMan",
                enableLocalPersistence: true,
                logger: logManager
            ))
            if case .dev = config {
                abTestManager = ABTestManager(service: LocalABTestService(), logManager: logManager)
            } else {
                abTestManager = ABTestManager(service: FirebaseABTestService(), logManager: logManager)
            }
            purchaseManager = PurchaseManager(
                service: RevenueCatPurchaseService(apiKey: Keys.revenueCatAPIKey),
                logger: logManager
            )
            hapticManager = HapticManager(logger: logManager)
            appState = AppState(startingModuleId: Dependencies.startingModuleId(authManager: authManager))
            streakManager = StreakManager(services: ProdStreakServices(), configuration: Dependencies.streakConfiguration, logger: logManager)
            xpManager = ExperiencePointsManager(services: ProdExperiencePointsServices(), configuration: Dependencies.xpConfiguration, logger: logManager)
            progressManager = ProgressManager(services: ProdProgressServices(), configuration: Dependencies.progressConfiguration, logger: logManager)
        }
        pushManager = PushManager(logManager: logManager)
        soundEffectManager = SoundEffectManager(logger: logManager)
        
        let container = DependencyContainer()
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(LogManager.self, service: logManager)
        container.register(ABTestManager.self, service: abTestManager)
        container.register(PurchaseManager.self, service: purchaseManager)
        container.register(AppState.self, service: appState)
        container.register(PushManager.self, service: pushManager)
        container.register(HapticManager.self, service: hapticManager)
        container.register(SoundEffectManager.self, service: soundEffectManager)
        container.register(StreakManager.self, key: Dependencies.streakConfiguration.streakKey, service: streakManager)
        container.register(ExperiencePointsManager.self, key: Dependencies.xpConfiguration.experienceKey, service: xpManager)
        container.register(ProgressManager.self, key: Dependencies.progressConfiguration.progressKey, service: progressManager)

        self.container = container
        
        SwiftfulRoutingLogger.enableLogging(logger: logManager)
    }
    
    /// REINSTALL FIX: a reinstall wipes UserDefaults (so `lastModuleId` is unset and the app would re-run
    /// onboarding) but the keychain survives, so Firebase restores the previous session. A restored REAL account
    /// already onboarded — start it in the core module. Restored anonymous sessions, fresh installs, and every
    /// launch with a saved module id behave as before.
    static func startingModuleId(authManager: AuthManager) -> String {
        let savedModuleId = UserDefaults.lastModuleId
        let hasSavedModuleId = savedModuleId == Constants.tabbarModuleId || savedModuleId == Constants.onboardingModuleId
        if !hasSavedModuleId, let auth = authManager.auth, !auth.isAnonymous {
            return Constants.tabbarModuleId
        }
        return savedModuleId
    }

    static let streakConfiguration = StreakConfiguration(
        streakKey: Constants.streakKey,
        eventsRequiredPerDay: 1,
        useServerCalculation: false,
        leewayHours: 0,
        freezeBehavior: .autoConsumeFreezes
    )
    
    static let xpConfiguration = ExperiencePointsConfiguration(
        experienceKey: Constants.xpKey,
        useServerCalculation: false
    )
    
    static let progressConfiguration = ProgressConfiguration(
        progressKey: Constants.progressKey
    )
    
}

@MainActor
class DevPreview {
    static let shared = DevPreview()
    private let dependencies: Dependencies

    func container() -> DependencyContainer {
        dependencies.container
    }

    init(isSignedIn: Bool = true) {
        self.dependencies = Dependencies(config: .mock(isSignedIn: isSignedIn, addLogging: false))
    }
}
