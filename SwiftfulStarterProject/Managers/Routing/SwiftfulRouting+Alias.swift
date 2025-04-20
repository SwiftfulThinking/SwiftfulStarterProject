//
//  SwiftfulRouting+Alias.swift
//  SwiftfulStarterProject
//
//  
//
import SwiftUI
import SwiftfulRouting

typealias RouterView = SwiftfulRouting.RouterView
typealias AnyDestination = SwiftfulRouting.AnyDestination
typealias AnyRouter = SwiftfulRouting.AnyRouter
typealias AlertStyle = SwiftfulRouting.AlertStyle

extension RoutingLogType {
    
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
extension LogManager: @retroactive RoutingLogger {
    public func trackEvent(event: any RoutingLogEvent) {
        trackEvent(eventName: event.eventName, parameters: event.parameters, type: event.type.type)
    }
}
