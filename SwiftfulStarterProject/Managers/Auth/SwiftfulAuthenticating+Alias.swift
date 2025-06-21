//
//  SwiftfulAuthenticating+Alias.swift
//  SwiftfulStarterProject
//
//  
//
import SwiftfulAuthenticating
import SwiftfulAuthenticatingFirebase

typealias UserAuthInfo = SwiftfulAuthenticating.UserAuthInfo
typealias AuthManager = SwiftfulAuthenticating.AuthManager
typealias MockAuthService = SwiftfulAuthenticating.MockAuthService
typealias FirebaseAuthService = SwiftfulAuthenticatingFirebase.FirebaseAuthService
typealias SignInOption = SwiftfulAuthenticating.SignInOption

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
