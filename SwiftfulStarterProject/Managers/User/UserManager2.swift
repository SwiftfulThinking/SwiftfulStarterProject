//
//  UserManager2.swift
//  SwiftfulStarterProject
//
//  Created by Nick Sarno on 1/17/25.
//

import SwiftUI
import SwiftfulDataManagers

@MainActor
@Observable
class UserManager2: DocumentManagerSync<UserModel> {

    private let remoteUserService: RemoteUserService

    var currentUser: UserModel? {
        currentDocument
    }

    init(
        remoteUserService: RemoteUserService,
        remote: any RemoteDocumentService<UserModel>,
        local: any LocalDocumentPersistence<UserModel>,
        configuration: DataManagerConfiguration,
        logger: (any DataLogger)? = nil
    ) {
        self.remoteUserService = remoteUserService

        // Initialize parent DocumentManagerSync
        super.init(
            remote: remote,
            local: local,
            configuration: configuration,
            logger: logger
        )

        // Add user properties to analytics if user is cached
        if let user = currentUser, let logger {
            logger.trackEvent(event: Event.userPropertiesAdded(user: user))
        }
    }

    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
        let creationVersion = isNewUser ? Utilities.appVersion : nil
        let user = UserModel(auth: auth, creationVersion: creationVersion)
        logger?.trackEvent(event: Event.logInStart(user: user))

        // Save user document
        try await saveDocument(user)
        logger?.trackEvent(event: Event.logInSuccess(user: user))

        // Start listening to this user document
        try await super.logIn(auth.uid)

        // Add user properties to analytics
        if let currentUser, let logManager = logger as? LogManager {
            logManager.addUserProperties(dict: currentUser.eventParameters, isHighPriority: true)
        }
    }

    func getUser(userId: String) async throws -> UserModel {
        // If requesting current user, return from cache
        if currentUser?.userId == userId {
            if let user = currentUser {
                return user
            }
        }
        // Otherwise fetch from remote
        return try await remoteUserService.getUser(userId: userId)
    }

    func saveOnboardingCompleteForCurrentUser() async throws {
        let uid = try currentUserId()
        try await remoteUserService.markOnboardingCompleted(userId: uid)
    }

    func saveUserName(name: String) async throws {
        let uid = try currentUserId()
        try await remoteUserService.saveUserName(userId: uid, name: name)
    }

    func saveUserEmail(email: String) async throws {
        let uid = try currentUserId()
        try await remoteUserService.saveUserEmail(userId: uid, email: email)
    }

    func saveUserProfileImage(image: UIImage) async throws {
        let uid = try currentUserId()
        try await remoteUserService.saveUserProfileImage(userId: uid, image: image)
    }

    func saveUserFCMToken(token: String) async throws {
        let uid = try currentUserId()
        try await remoteUserService.saveUserFCMToken(userId: uid, token: token)
    }

    func signOut() {
        logOut()
        logger?.trackEvent(event: Event.signOut)
    }

    func deleteCurrentUser() async throws {
        logger?.trackEvent(event: Event.deleteAccountStart)

        let uid = try currentUserId()
        guard let documentId = try? getDocumentId(), uid == documentId else {
            throw UserManagerError.userIdChanged
        }
        
        try await deleteDocument()
        logger?.trackEvent(event: Event.deleteAccountSuccess)

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
        case userIdChanged
    }

    enum Event: DataLogEvent {
        case userPropertiesAdded(user: UserModel)
        case logInStart(user: UserModel?)
        case logInSuccess(user: UserModel?)
        case signOut
        case deleteAccountStart
        case deleteAccountSuccess

        var eventName: String {
            switch self {
            case .userPropertiesAdded:      return "UserMan2_UserPropertiesAdded"
            case .logInStart:               return "UserMan2_LogIn_Start"
            case .logInSuccess:             return "UserMan2_LogIn_Success"
            case .signOut:                  return "UserMan2_SignOut"
            case .deleteAccountStart:       return "UserMan2_DeleteAccount_Start"
            case .deleteAccountSuccess:     return "UserMan2_DeleteAccount_Success"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .userPropertiesAdded(user: let user):
                return user.eventParameters
            case .logInStart(user: let user), .logInSuccess(user: let user):
                return user?.eventParameters
            default:
                return nil
            }
        }

        var type: DataLogType {
            switch self {
            default:
                return .analytic
            }
        }
    }
}
