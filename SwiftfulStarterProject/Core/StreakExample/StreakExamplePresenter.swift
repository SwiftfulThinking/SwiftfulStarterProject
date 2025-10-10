import SwiftUI

@Observable
@MainActor
class StreakExamplePresenter {
    
    private let interactor: StreakExampleInteractor
    private let router: StreakExampleRouter
    
    init(interactor: StreakExampleInteractor, router: StreakExampleRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear(delegate: StreakExampleDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: StreakExampleDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }
}

extension StreakExamplePresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: StreakExampleDelegate)
        case onDisappear(delegate: StreakExampleDelegate)

        var eventName: String {
            switch self {
            case .onAppear:                 return "StreakExampleView_Appear"
            case .onDisappear:              return "StreakExampleView_Disappear"
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
