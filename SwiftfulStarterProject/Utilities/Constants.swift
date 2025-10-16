//
//  Constants.swift
//  SwiftfulStarterProject
//
//  
//
struct Constants {
    static let randomImage = "https://picsum.photos/600/600"
    static let privacyPolicyUrlString = "https://www.google.com"
    static let termsOfServiceUrlString = "https://www.google.com"
    
    static let onboardingModuleId = "onboarding"
    static let tabbarModuleId = "tabbar"
    
    static let streakKey = "daily" // daily streaks
    static let xpKey = "general" // general XP
    static let progressKey = "general" // general progress

    static var mixpanelDistinctId: String? {
        #if MOCK
        return nil
        #else
        return MixpanelService.distinctId
        #endif
    }
    
    static var firebaseAnalyticsAppInstanceID: String? {
        #if MOCK
        return nil
        #else
        return FirebaseAnalyticsService.appInstanceID
        #endif
    }

    @MainActor
    static var firebaseAppClientId: String? {
        #if MOCK
        return nil
        #else
        return FirebaseAuthService.clientId
        #endif
    }

}
