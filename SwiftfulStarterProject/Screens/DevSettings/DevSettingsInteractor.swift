//
//  DevSettingsInteractor.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 11/15/24.
//
@MainActor
protocol DevSettingsInteractor {
    var activeTests: ActiveABTests { get }
    var auth: UserAuthInfo? { get }
    var currentUser: UserModel? { get }
    
    func trackEvent(event: LoggableEvent)
    func override(updateTests: ActiveABTests) throws
}

extension CoreInteractor: DevSettingsInteractor { }
