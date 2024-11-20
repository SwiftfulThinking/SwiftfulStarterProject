//
//  SwiftfulAuthenticating+Alias.swift
//  SwiftfulStarterProject
//
//  Created by Nick Sarno on 11/19/24.
//
import SwiftfulAuthenticating
import SwiftfulAuthenticatingFirebase

typealias UserAuthInfo = SwiftfulAuthenticating.UserAuthInfo
typealias AuthManager = SwiftfulAuthenticating.AuthManager
typealias MockAuthService = SwiftfulAuthenticating.MockAuthService

extension AuthLogType {
    
    var type: LogType {
        switch self {
        case .info:
            return .info
        case .analytic:
            return .analytic
        case .warning:
            return .warning
        case .severe:
            return .severe
        }
    }
    
}

extension LogManager: @retroactive AuthLogger {
    
    public func trackEvent(event: any AuthLogEvent) {
        trackEvent(eventName: event.eventName, parameters: event.parameters, type: event.type.type)
    }
    
}
