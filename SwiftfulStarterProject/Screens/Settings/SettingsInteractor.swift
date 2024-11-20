//
//  SettingsInteractor.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 11/15/24.
//

@MainActor
protocol SettingsInteractor {
    var auth: UserAuthInfo? { get }
    
    func trackEvent(event: LoggableEvent)
    func signOut() async throws
    func deleteAccount() async throws
    func updateAppState(showTabBarView: Bool)
}

extension CoreInteractor: SettingsInteractor { }
