//
//  UserManager.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 10/14/24.
//
import SwiftUI

@MainActor
@Observable
class UserManager {
    
    private let remote: RemoteUserService
    private let local: LocalUserPersistence
    private let logManager: LogManager?
    
    private(set) var currentUser: UserModel?
    private var currentUserListener: ListenerRegistration?

    init(services: UserServices, logManager: LogManager? = nil) {
        self.remote = services.remote
        self.local = services.local
        self.logManager = logManager
        self.currentUser = local.getCurrentUser()
    }
        
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
        let creationVersion = isNewUser ? Utilities.appVersion : nil
        let user = UserModel(auth: auth, creationVersion: creationVersion)
        logManager?.trackEvent(event: Event.logInStart(user: user))
        
        try await remote.saveUser(user: user)
        logManager?.trackEvent(event: Event.logInSuccess(user: user))

        addCurrentUserListener(userId: auth.uid)
    }
    
    private func addCurrentUserListener(userId: String) {
        currentUserListener?.remove()
        logManager?.trackEvent(event: Event.remoteListenerStart)

        Task {
            do {
                for try await value in remote.streamUser(userId: userId, onListenerConfigured: { listener in
                    self.currentUserListener = listener
                }) {
                    self.currentUser = value
                    logManager?.trackEvent(event: Event.remoteListenerSuccess(user: value))
                    logManager?.addUserProperties(dict: value.eventParameters, isHighPriority: true)
                    
                    self.saveCurrentUserLocally()
                }
            } catch {
                logManager?.trackEvent(event: Event.remoteListenerFail(error: error))
            }
        }
    }
    
    private func saveCurrentUserLocally() {
        logManager?.trackEvent(event: Event.saveLocalStart(user: currentUser))

        Task {
            do {
                try local.saveCurrentUser(user: currentUser)
                logManager?.trackEvent(event: Event.saveLocalSuccess(user: currentUser))
            } catch {
                logManager?.trackEvent(event: Event.saveLocalFail(error: error))
            }
        }
    }
    
    func markOnboardingCompleteForCurrentUser() async throws {
        let uid = try currentUserId()
        try await remote.markOnboardingCompleted(userId: uid)
    }
    
    func signOut() {
        currentUserListener?.remove()
        currentUserListener = nil
        currentUser = nil
        logManager?.trackEvent(event: Event.signOut)
    }
    
    func deleteCurrentUser() async throws {
        logManager?.trackEvent(event: Event.deleteAccountStart)

        let uid = try currentUserId()
        try await remote.deleteUser(userId: uid)
        logManager?.trackEvent(event: Event.deleteAccountSuccess)

        signOut()
    }
    
    private func currentUserId() throws -> String {
        guard let uid = currentUser?.userId else {
            throw UserManagerError.noUserId
        }
        return uid
    }
    
    enum UserManagerError: LocalizedError {
        case noUserId
    }
    
    enum Event: LoggableEvent {
        case logInStart(user: UserModel?)
        case logInSuccess(user: UserModel?)
        case remoteListenerStart
        case remoteListenerSuccess(user: UserModel?)
        case remoteListenerFail(error: Error)
        case saveLocalStart(user: UserModel?)
        case saveLocalSuccess(user: UserModel?)
        case saveLocalFail(error: Error)
        case signOut
        case deleteAccountStart
        case deleteAccountSuccess

        var eventName: String {
            switch self {
            case .logInStart:               return "UserMan_LogIn_Start"
            case .logInSuccess:             return "UserMan_LogIn_Success"
            case .remoteListenerStart:      return "UserMan_RemoteListener_Start"
            case .remoteListenerSuccess:    return "UserMan_RemoteListener_Success"
            case .remoteListenerFail:       return "UserMan_RemoteListener_Fail"
            case .saveLocalStart:           return "UserMan_SaveLocal_Start"
            case .saveLocalSuccess:         return "UserMan_SaveLocal_Success"
            case .saveLocalFail:            return "UserMan_SaveLocal_Fail"
            case .signOut:                  return "UserMan_SignOut"
            case .deleteAccountStart:       return "UserMan_DeleteAccount_Start"
            case .deleteAccountSuccess:     return "UserMan_DeleteAccount_Success"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .logInStart(user: let user), .logInSuccess(user: let user), .remoteListenerSuccess(user: let user), .saveLocalStart(user: let user), .saveLocalSuccess(user: let user):
                return user?.eventParameters
            case .remoteListenerFail(error: let error), .saveLocalFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .remoteListenerFail, .saveLocalFail:
                return .severe
            default:
                return .analytic
            }
        }
    }

}
