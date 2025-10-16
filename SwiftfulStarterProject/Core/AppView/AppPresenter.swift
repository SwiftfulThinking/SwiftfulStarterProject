//
//  AppPresenter.swift
//
//
//
//
import SwiftUI
import SwiftfulUtilities
#if !MOCK
import FirebaseMessaging
#endif

@Observable
@MainActor
class AppPresenter {
    
    private let interactor: AppViewInteractor
    
    var auth: UserAuthInfo? {
        interactor.auth
    }
    
    init(interactor: AppViewInteractor) {
        self.interactor = interactor
    }
    
    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }
    
    func onViewDisappear() {
        interactor.trackEvent(event: Event.onDisappear)
    }

    func showATTPromptIfNeeded() async {
        #if !DEBUG
        let status = await AppTrackingTransparencyHelper.requestTrackingAuthorization()
        interactor.trackEvent(event: Event.attStatus(dict: status.eventParameters))
        #endif
    }
    
    func checkUserStatus() async {
        if let user = interactor.auth {
            // User is authenticated
            interactor.trackEvent(event: Event.existingAuthStart)
            
            do {
                try await interactor.logIn(user: user, isNewUser: false)
            } catch {
                interactor.trackEvent(event: Event.existingAuthFail(error: error))
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        } else {
            // User is not authenticated
            interactor.trackEvent(event: Event.anonAuthStart)

            do {
                let result = try await interactor.signInAnonymously()
                
                // log in to app
                interactor.trackEvent(event: Event.anonAuthSuccess)
                
                // Log in
                try await interactor.logIn(user: result.user, isNewUser: result.isNewUser)

                // Save push token
                #if !MOCK
                if let token = try? await Messaging.messaging().token() {
                    savePushToken(token: token)
                }
                #endif
            } catch {
                interactor.trackEvent(event: Event.anonAuthFail(error: error))
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        }
    }
    
    func onFCMTokenRecieved(notification: Notification) {
        guard let token = NotificationCenter.default.getFCMToken(notification: notification) else {
            // Token not found in notification
            interactor.trackEvent(event: Event.fcmFail(error: AppPresenterError.fcmTokenNotFound))
            return
        }
        savePushToken(token: token)
    }
    
    private func savePushToken(token: String) {
        interactor.trackEvent(event: Event.fcmStart)
        
        Task {
            do {
                try await interactor.saveUserFCMToken(token: token)
                interactor.trackEvent(event: Event.fcmSuccess)
            } catch {
                interactor.trackEvent(event: Event.fcmFail(error: error))
            }
        }
    }
    
    enum AppPresenterError: LocalizedError {
        case fcmTokenNotFound
    }
}

extension AppPresenter {

    enum Event: LoggableEvent {
        case onAppear
        case onDisappear
        case existingAuthStart
        case existingAuthFail(error: Error)
        case anonAuthStart
        case anonAuthSuccess
        case anonAuthFail(error: Error)
        case attStatus(dict: [String: Any])
        case fcmStart
        case fcmSuccess
        case fcmFail(error: Error)

        var eventName: String {
            switch self {
            case .onAppear:             return "AppView_Appear"
            case .onDisappear:          return "AppView_Disappear"
            case .existingAuthStart:    return "AppView_ExistingAuth_Start"
            case .existingAuthFail:     return "AppView_ExistingAuth_Fail"
            case .anonAuthStart:        return "AppView_AnonAuth_Start"
            case .anonAuthSuccess:      return "AppView_AnonAuth_Success"
            case .anonAuthFail:         return "AppView_AnonAuth_Fail"
            case .attStatus:            return "AppView_ATTStatus"
            case .fcmStart:             return "AppView_FCM_Start"
            case .fcmSuccess:           return "AppView_FCM_Success"
            case .fcmFail:              return "AppView_FCM_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .existingAuthFail(error: let error), .anonAuthFail(error: let error), .fcmFail(error: let error):
                return error.eventParameters
            case .attStatus(dict: let dict):
                return dict
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .existingAuthFail, .anonAuthFail, .fcmFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
    
}
