//
//  SwiftfulSoundEffects+Alias.swift
//  SwiftfulStarterProject
//
//  Created by Nick Sarno on 1/12/25.
//
import SwiftfulSoundEffects

typealias SoundEffectManager = SwiftfulSoundEffects.SoundEffectManager

extension SoundEffectLogType {
    
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
extension LogManager: @retroactive SoundEffectLogger {
    
    public func trackEvent(event: any SoundEffectLogEvent) {
        trackEvent(eventName: event.eventName, parameters: event.parameters, type: event.type.type)
    }
    
}
