//
//  GlobalInteractor.swift
//  SwiftfulStarterProject
//
//  Created by Nick Sarno on 11/21/24.
//
@MainActor
protocol GlobalInteractor {
    func trackEvent(eventName: String, parameters: [String: Any]?, type: LogType)
    func trackEvent(event: AnyLoggableEvent)
    func trackEvent(event: LoggableEvent)
    func trackScreenEvent(event: LoggableEvent)
}
