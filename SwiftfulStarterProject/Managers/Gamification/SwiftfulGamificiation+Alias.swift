//
//  SwiftfulGamificiation+Alias.swift
//  SwiftfulStarterProject
//
//  Created by Nick Sarno on 10/4/25.
//
import SwiftfulGamification
import SwiftfulGamificationFirebase

typealias GamificationDictionaryValue = SwiftfulGamification.GamificationDictionaryValue

// Streaks
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
        self.local = FileManagerStreakPersistence()
    }
}

// Experience Points

typealias ExperiencePointsManager = SwiftfulGamification.ExperiencePointsManager
typealias MockExperiencePointsServices = SwiftfulGamification.MockExperiencePointsServices
typealias ExperiencePointsConfiguration = SwiftfulGamification.ExperiencePointsConfiguration
typealias CurrentExperiencePointsData = SwiftfulGamification.CurrentExperiencePointsData
typealias ExperiencePointsEvent = SwiftfulGamification.ExperiencePointsEvent

@MainActor
public struct ProdExperiencePointsServices: ExperiencePointsServices {
    public let remote: RemoteExperiencePointsService
    public let local: LocalExperiencePointsPersistence

    public init() {
        self.remote = FirebaseRemoteExperiencePointsService()
        self.local = FileManagerExperiencePointsPersistence()
    }
}

// Progress

typealias ProgressManager = SwiftfulGamification.ProgressManager
typealias ProgressConfiguration = SwiftfulGamification.ProgressConfiguration
typealias MockProgressServices = SwiftfulGamification.MockProgressServices
typealias ProgressItem = SwiftfulGamification.ProgressItem

@MainActor
public struct ProdProgressServices: ProgressServices {
    public let remote: RemoteProgressService
    public let local: LocalProgressPersistence

    public init() {
        self.remote = FirebaseRemoteProgressService()
        self.local = SwiftDataProgressPersistence()
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
