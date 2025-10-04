//
//  SwiftfulGamificiation+Alias.swift
//  SwiftfulStarterProject
//
//  Created by Nick Sarno on 10/4/25.
//
import SwiftfulGamification
import SwiftfulGamificationFirebase

typealias StreakManager = SwiftfulGamification.StreakManager
typealias MockStreakServices = SwiftfulGamification.MockStreakServices
typealias StreakConfiguration = SwiftfulGamification.StreakConfiguration
typealias StreakEvent = SwiftfulGamification.StreakEvent
typealias CurrentStreakData = SwiftfulGamification.CurrentStreakData
typealias StreakFreeze = SwiftfulGamification.StreakFreeze

@MainActor
public struct ProdStreakServices: StreakServices {
    public let remote: RemoteStreakService
    public let local: LocalStreakPersistence

    public init() {
        self.remote = FirebaseRemoteStreakService()
        self.local = MockLocalStreakPersistence(streak: nil) // fixme
    }
}

extension GamificationLogType {
    
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
extension LogManager: @retroactive GamificationLogger {
    
    public func trackEvent(event: any GamificationLogEvent) {
        trackEvent(eventName: event.eventName, parameters: event.parameters, type: event.type.type)
    }
    
}
