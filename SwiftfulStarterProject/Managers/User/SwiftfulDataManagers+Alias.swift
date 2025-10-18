//
//  SwiftfulDataManagers+Alias.swift
//  SwiftfulStarterProject
//
//  Created by Nick Sarno on 10/18/25.
//
import SwiftfulDataManagers
import SwiftfulDataManagersFirebase

typealias DataManagerSyncConfiguration = SwiftfulDataManagers.DataManagerSyncConfiguration
typealias DataManagerAsyncConfiguration = SwiftfulDataManagers.DataManagerAsyncConfiguration

typealias MockUserServices = SwiftfulDataManagers.MockDMDocumentServices

@MainActor
public struct ProductionUserServices: DMDocumentServices {
    public typealias T = UserModel

    public let remote: any RemoteDocumentService<UserModel>
    public let local: any LocalDocumentPersistence<UserModel>

    public init() {
        self.remote = FirebaseRemoteDocumentService<UserModel>(collectionPath: "users")
        self.local = FileManagerDocumentPersistence<UserModel>()
    }
}

extension DataLogType {
    
    var type: LogType {
        switch self {
        case .info:
            return .info
        case .analytic:
            return .analytic
        case .severe:
            return .severe
        }
    }
    
}
extension LogManager: @retroactive DataLogger {
    
    public func trackEvent(event: any DataLogEvent) {
        trackEvent(eventName: event.eventName, parameters: event.parameters, type: event.type.type)
    }
    
}
