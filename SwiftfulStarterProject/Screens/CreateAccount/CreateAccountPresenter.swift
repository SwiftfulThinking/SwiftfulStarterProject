//
//  CreateAccountPresenter.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 11/9/24.
//
import SwiftUI

@Observable
@MainActor
class CreateAccountPresenter {
    
    private let interactor: CreateAccountInteractor
    private let router: CreateAccountRouter

    init(interactor: CreateAccountInteractor, router: CreateAccountRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear(delegate: CreateAccountDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: CreateAccountDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }
    
    func onSignInApplePressed(delegate: CreateAccountDelegate) {
        interactor.trackEvent(event: Event.appleAuthStart)
        
        Task {
            do {
                let result = try await interactor.signInApple()
                interactor.trackEvent(event: Event.appleAuthSuccess(user: result.user, isNewUser: result.isNewUser))

                try await interactor.logIn(user: result.user, isNewUser: result.isNewUser)
                interactor.trackEvent(event: Event.appleAuthLoginSuccess(user: result.user, isNewUser: result.isNewUser))

                delegate.onDidSignIn?(result.isNewUser)
                router.dismissScreen()
            } catch {
                interactor.trackEvent(event: Event.appleAuthFail(error: error))
            }
        }
    }

}

extension CreateAccountPresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: CreateAccountDelegate)
        case onDisappear(delegate: CreateAccountDelegate)
        case appleAuthStart
        case appleAuthSuccess(user: UserAuthInfo, isNewUser: Bool)
        case appleAuthLoginSuccess(user: UserAuthInfo, isNewUser: Bool)
        case appleAuthFail(error: Error)

        var eventName: String {
            switch self {
            case .onAppear:                return "CreateAccountView_Appear"
            case .onDisappear:             return "CreateAccountView_Disappear"
            case .appleAuthStart:          return "CreateAccountView_AppleAuth_Start"
            case .appleAuthSuccess:        return "CreateAccountView_AppleAuth_Success"
            case .appleAuthLoginSuccess:   return "CreateAccountView_AppleAuth_LoginSuccess"
            case .appleAuthFail:           return "CreateAccountView_AppleAuth_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .appleAuthSuccess(user: let user, isNewUser: let isNewUser),
                    .appleAuthLoginSuccess(user: let user, isNewUser: let isNewUser):
                var dict = user.eventParameters
                dict["is_new_user"] = isNewUser
                return dict
            case .appleAuthFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .appleAuthFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
    
}
