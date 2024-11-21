//
//  WelcomePresenter.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 11/9/24.
//
import SwiftUI

@Observable
@MainActor
class WelcomePresenter {
    
    private let interactor: WelcomeInteractor
    private let router: WelcomeRouter

    private(set) var imageName: String = Constants.randomImage
    
    init(interactor: WelcomeInteractor, router: WelcomeRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onGetStartedPressed() {
        router.showOnboardingCompletedView(delegate: OnboardingCompletedDelegate())
    }
        
    private func handleDidSignIn(isNewUser: Bool) {
        interactor.trackEvent(event: Event.didSignIn(isNewUser: isNewUser))
        
        if isNewUser {
            // Do nothing, user goes through onboarding
        } else {
            // Push into tabbar view
            interactor.updateAppState(showTabBarView: true)
        }
    }
    
    func onSignInPressed() {
        interactor.trackEvent(event: Event.signInPressed)
        
        let delegate = CreateAccountDelegate(
            title: "Sign in",
            subtitle: "Connect to an existing account.",
            onDidSignIn: { isNewUser in
                self.handleDidSignIn(isNewUser: isNewUser)
            }
        )
        router.showCreateAccountView(delegate: delegate, onDismiss: nil)
    }

    enum Event: LoggableEvent {
        case didSignIn(isNewUser: Bool)
        case signInPressed
        
        var eventName: String {
            switch self {
            case .didSignIn:          return "WelcomeView_DidSignIn"
            case .signInPressed:      return "WelcomeView_SignIn_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .didSignIn(isNewUser: let isNewUser):
                return [
                    "is_new_user": isNewUser
                ]
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }

}