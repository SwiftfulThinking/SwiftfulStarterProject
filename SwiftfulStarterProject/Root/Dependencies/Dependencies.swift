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
        let abTestManager: ABTestManager // #feature: abtesting
        let purchaseManager: PurchaseManager
        let appState: AppState
        let logManager: LogManager
        let pushManager: PushManager
        let hapticManager: HapticManager
        let soundEffectManager: SoundEffectManager
        // #feature-start: gamification
        let streakManager: StreakManager
        let xpManager: ExperiencePointsManager
        let progressManager: ProgressManager
        // #feature-end: gamification
        
        switch config {
        case .mock(isSignedIn: let isSignedIn, addLogging: let addLogging):
            logManager = LogManager(services: addLogging ? [
                ConsoleService(printParameters: true, system: .stdout)
            ] : [])
            authManager = AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil), logger: logManager)
            userManager = UserManager(userSyncEngine: DocumentSyncEngine<UserModel>(
                remote: MockRemoteDocumentService(document: isSignedIn ? UserModel.mock : nil),
                managerKey: "UserMan",
                enableLocalPersistence: false,
                logger: logManager
            ))
            
            // #feature-start: abtesting
            // Note: configure AB tests for UI tests here
            //
            // let isInTest = ProcessInfo.processInfo.arguments.contains("SOMETEST")
            let abTestService = MockABTestService(
                boolTest: nil,
                enumTest: nil
            )
            abTestManager = ABTestManager(service: abTestService, logManager: logManager)
            // #feature-end: abtesting
            purchaseManager = PurchaseManager(service: MockPurchaseService(activeEntitlements: [], availableProducts: AnyProduct.mocks), logger: logManager)
            appState = AppState(startingModuleId: isSignedIn ? Constants.tabbarModuleId : Constants.onboardingModuleId)
            hapticManager = HapticManager(logger: logManager)
            // #feature-start: gamification
            streakManager = StreakManager(services: MockStreakServices(), configuration: Dependencies.streakConfiguration, logger: logManager)
            xpManager = ExperiencePointsManager(services: MockExperiencePointsServices(), configuration: Dependencies.xpConfiguration, logger: logManager)
            progressManager = ProgressManager(services: MockProgressServices(), configuration: Dependencies.progressConfiguration, logger: logManager)
            // #feature-end: gamification
        case .dev, .prod:
            if case .dev = config {
                logManager = LogManager(services: [
                    FirebaseAnalyticsService(), // #feature: analytics
                    MixpanelService(token: Keys.mixpanelToken), // #feature: analytics
                    FirebaseCrashlyticsService(), // #feature: analytics
                    ConsoleService(printParameters: true)
                ])
            } else {
                logManager = LogManager(services: [
                    FirebaseAnalyticsService(), // #feature: analytics
                    MixpanelService(token: Keys.mixpanelToken), // #feature: analytics
                    FirebaseCrashlyticsService() // #feature: analytics
                ])
            }
            authManager = AuthManager(service: FirebaseAuthService(), logger: logManager)
            userManager = UserManager(userSyncEngine: DocumentSyncEngine<UserModel>(
                remote: FirebaseRemoteDocumentService(collectionPath: { "users" }),
                managerKey: "UserMan",
                enableLocalPersistence: true,
                logger: logManager
            ))
            // #feature-start: abtesting
            if case .dev = config {
                abTestManager = ABTestManager(service: LocalABTestService(), logManager: logManager)
            } else {
                abTestManager = ABTestManager(service: FirebaseABTestService(), logManager: logManager)
            }
            // #feature-end: abtesting
            purchaseManager = PurchaseManager(
                service: RevenueCatPurchaseService(apiKey: Keys.revenueCatAPIKey),
                logger: logManager
            )
            hapticManager = HapticManager(logger: logManager)
            appState = AppState()
            // #feature-start: gamification
            streakManager = StreakManager(services: ProdStreakServices(), configuration: Dependencies.streakConfiguration, logger: logManager)
            xpManager = ExperiencePointsManager(services: ProdExperiencePointsServices(), configuration: Dependencies.xpConfiguration, logger: logManager)
            progressManager = ProgressManager(services: ProdProgressServices(), configuration: Dependencies.progressConfiguration, logger: logManager)
            // #feature-end: gamification
        }
        pushManager = PushManager(logManager: logManager)
        soundEffectManager = SoundEffectManager(logger: logManager)
        
        let container = DependencyContainer()
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(LogManager.self, service: logManager)
        container.register(ABTestManager.self, service: abTestManager) // #feature: abtesting
        container.register(PurchaseManager.self, service: purchaseManager)
        container.register(AppState.self, service: appState)
        container.register(PushManager.self, service: pushManager)
        container.register(HapticManager.self, service: hapticManager)
        container.register(SoundEffectManager.self, service: soundEffectManager)
        // #feature-start: gamification
        container.register(StreakManager.self, key: Dependencies.streakConfiguration.streakKey, service: streakManager)
        container.register(ExperiencePointsManager.self, key: Dependencies.xpConfiguration.experienceKey, service: xpManager)
        container.register(ProgressManager.self, key: Dependencies.progressConfiguration.progressKey, service: progressManager)
        // #feature-end: gamification

        self.container = container
        
        SwiftfulRoutingLogger.enableLogging(logger: logManager)
    }
    
    // #feature-start: gamification
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
    // #feature-end: gamification

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
