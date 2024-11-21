import SwiftUI

@Observable
@MainActor
class TestPresenter {
    
    private let interactor: TestInteractor
    private let router: TestRouter
    
    init(interactor: TestInteractor, router: TestRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear(delegate: TestDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: TestDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }
}

extension TestPresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: TestDelegate)
        case onDisappear(delegate: TestDelegate)

        var eventName: String {
            switch self {
            case .onAppear:             return "TestView_Appear"
            case .onDisappear:          return "TestView_Disappear"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .onAppear(delegate: let delegate), .onDisappear(delegate: let delegate):
                return delegate.eventParameters
//            default:
//                return nil
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
