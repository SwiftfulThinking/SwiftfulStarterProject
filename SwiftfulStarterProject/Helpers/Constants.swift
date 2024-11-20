//
//  Constants.swift
//  SwiftfulStarterProject
//
//  Created by Nick Sarno on 11/19/24.
//
struct Constants {
    static let randomImage = "https://picsum.photos/600/600"
    static let privacyPolicyUrlString = "https://www.google.com"
    static let termsOfServiceUrlString = "https://www.google.com"
    
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

    static var firebaseAppClientId: String? {
        #if MOCK
        return nil
        #else
        return FirebaseApp.app()?.options.clientID
        #endif
    }

}
