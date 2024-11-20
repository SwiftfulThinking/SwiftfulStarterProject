//
//  Dependencies.swift
//  SwiftfulStarterProject
//
//  Created by Nick Sarno on 11/19/24.
//
import SwiftUI

@MainActor
struct Dependencies {
    let container: DependencyContainer

    // swiftlint:disable:next function_body_length
    init(config: BuildConfiguration) {
//        let authManager: AuthManager
//        let userManager: UserManager
//        let abTestManager: ABTestManager
//        let purchaseManager: PurchaseManager
//        let appState: AppState
//
//        let aiService: AIService
//        let localAvatarService: LocalAvatarPersistence
//        let remoteAvatarService: RemoteAvatarService
//        let chatService: ChatService
//
//        switch config {
//        case .mock(isSignedIn: let isSignedIn):
//            logManager = LogManager(services: [
//                ConsoleService(printParameters: false)
//            ])
//            authManager = AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil), logger: logManager)
//            userManager = UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil), logManager: logManager)
//            aiService = MockAIService()
//            localAvatarService = MockLocalAvatarPersistence()
//            remoteAvatarService = MockAvatarService()
//            chatService = MockChatService()
//            
//            let isInOnboaringCommunityTest = ProcessInfo.processInfo.arguments.contains("ONBCOMMTEST")
//            let abTestService = MockABTestService(
//                onboardingCommunityTest: isInOnboaringCommunityTest,
//                paywallTest: .custom
//            )
//            abTestManager = ABTestManager(service: abTestService, logManager: logManager)
//            purchaseManager = PurchaseManager(service: MockPurchaseService(), logger: logManager)
//            appState = AppState(showTabBar: isSignedIn)
//        case .dev:
//            logManager = LogManager(services: [
//                ConsoleService(printParameters: true),
//                FirebaseAnalyticsService(),
//                MixpanelService(token: Keys.mixpanelToken),
//                FirebaseCrashlyticsService()
//            ])
//            authManager = AuthManager(service: FirebaseAuthService(), logger: logManager)
//            userManager = UserManager(services: ProductionUserServices(), logManager: logManager)
//            aiService = OpenAIService()
//            localAvatarService = SwiftDataLocalAvatarPersistence()
//            remoteAvatarService = FirebaseAvatarService()
//            chatService = FirebaseChatService()
//
//            abTestManager = ABTestManager(service: LocalABTestService(), logManager: logManager)
//            purchaseManager = PurchaseManager(
//                service: RevenueCatPurchaseService(apiKey: Keys.revenueCatAPIKey), // StoreKitPurchaseService(),
//                logger: logManager
//            )
//            appState = AppState()
//        case .prod:
//            logManager = LogManager(services: [
//                FirebaseAnalyticsService(),
//                MixpanelService(token: Keys.mixpanelToken),
//                FirebaseCrashlyticsService()
//            ])
//            authManager = AuthManager(service: FirebaseAuthService(), logger: logManager)
//            userManager = UserManager(services: ProductionUserServices(), logManager: logManager)
//            aiService = OpenAIService()
//            localAvatarService = SwiftDataLocalAvatarPersistence()
//            remoteAvatarService = FirebaseAvatarService()
//            chatService = FirebaseChatService()
//
//            abTestManager = ABTestManager(service: FirebaseABTestService(), logManager: logManager)
//            purchaseManager = PurchaseManager(service: StoreKitPurchaseService(), logger: logManager)
//            appState = AppState()
//        }
                
        let container = DependencyContainer()
//        container.register(AuthManager.self, service: authManager)
//        container.register(UserManager.self, service: userManager)
//        container.register(LogManager.self, service: logManager)
//        container.register(ABTestManager.self, service: abTestManager)
//        container.register(PurchaseManager.self, service: purchaseManager)
//        container.register(AppState.self, service: appState)
//        
//        container.register(AIService.self, service: aiService)
//        container.register(LocalAvatarPersistence.self, service: localAvatarService)
//        container.register(RemoteAvatarService.self, service: remoteAvatarService)
//        container.register(ChatService.self, service: chatService)

        self.container = container
    }
}
