//
//  GlobalInteractor.swift
//  SwiftfulStarterProject
//
//  
//
@MainActor
protocol GlobalInteractor {
    func trackEvent(eventName: String, parameters: [String: Any]?, type: LogType)
    func trackEvent(event: AnyLoggableEvent)
    func trackEvent(event: LoggableEvent)
    func trackScreenEvent(event: LoggableEvent)
    
    func playHaptic(option: HapticOption)
}
