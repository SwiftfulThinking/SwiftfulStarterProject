import SwiftUI
import SwiftfulOnboarding

@Observable
@MainActor
class OnboardingPresenter {

    private let interactor: OnboardingInteractor
    private let router: OnboardingRouter

    init(interactor: OnboardingInteractor, router: OnboardingRouter) {
        self.interactor = interactor
        self.router = router
    }

    func onViewAppear(delegate: OnboardingDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }

    func onViewDisappear(delegate: OnboardingDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }

    func onSlideComplete(slideData: OnbSlideData, delegate: OnboardingDelegate) {
        interactor.trackEvent(event: Event.onSlideComplete(slideData: slideData, delegate: delegate))
    }

    func onFlowComplete(flowData: OnbFlowData, delegate: OnboardingDelegate) {
        interactor.trackEvent(event: Event.onFlowComplete(flowData: flowData, delegate: delegate))
        router.showOnboardingCompletedView(delegate: OnboardingCompletedDelegate())
    }
}

extension OnboardingPresenter {

    enum Event: LoggableEvent {
        case onAppear(delegate: OnboardingDelegate)
        case onDisappear(delegate: OnboardingDelegate)
        case onSlideComplete(slideData: OnbSlideData, delegate: OnboardingDelegate)
        case onFlowComplete(flowData: OnbFlowData, delegate: OnboardingDelegate)

        var eventName: String {
            switch self {
            case .onAppear:                 return "OnboardingView_Appear"
            case .onDisappear:              return "OnboardingView_Disappear"
            case .onSlideComplete:          return "OnboardingView_SlideComplete"
            case .onFlowComplete:           return "OnboardingView_FlowComplete"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .onAppear(delegate: let delegate), .onDisappear(delegate: let delegate):
                return delegate.eventParameters
            case .onSlideComplete(slideData: let slideData, delegate: let delegate):
                var params = delegate.eventParameters ?? [:]
                params.merge(slideData.eventParameters)
                return params
            case .onFlowComplete(flowData: let flowData, delegate: let delegate):
                var params = delegate.eventParameters ?? [:]
                params.merge(flowData.eventParameters)
                return params
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
