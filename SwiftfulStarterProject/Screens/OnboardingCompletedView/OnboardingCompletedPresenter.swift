//
//  OnboardingCompletedPresenter.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 11/9/24.
//
import SwiftUI

@Observable
@MainActor
class OnboardingCompletedPresenter {
    
    private let interactor: OnboardingCompletedInteractor
    private let router: OnboardingCompletedRouter
    
    private(set) var isCompletingProfileSetup: Bool = false

    init(interactor: OnboardingCompletedInteractor, router: OnboardingCompletedRouter) {
        self.interactor = interactor
        self.router = router
    }
        
    func onFinishButtonPressed() {
        isCompletingProfileSetup = true
        interactor.trackEvent(event: Event.finishStart)
        
        Task {
            do {
                try await interactor.markOnboardingCompleteForCurrentUser()
                interactor.trackEvent(event: Event.finishSuccess)

                // dismiss screen
                isCompletingProfileSetup = false
                
                // Show tabbar view
                interactor.updateAppState(showTabBarView: true)
            } catch {
                router.showAlert(error: error)
                interactor.trackEvent(event: Event.finishFail(error: error))
            }
        }
    }

    enum Event: LoggableEvent {
        case finishStart
        case finishSuccess
        case finishFail(error: Error)

        var eventName: String {
            switch self {
            case .finishStart:         return "OnboardingCompletedView_Finish_Start"
            case .finishSuccess:       return "OnboardingCompletedView_Finish_Success"
            case .finishFail:          return "OnboardingCompletedView_Finish_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .finishFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .finishFail:
                return .severe
            default:
                return .analytic
            }
        }
    }

}
