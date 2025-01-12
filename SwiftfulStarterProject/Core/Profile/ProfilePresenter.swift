import SwiftUI

@Observable
@MainActor
class ProfilePresenter {
    
    private let interactor: ProfileInteractor
    private let router: ProfileRouter
    
    init(interactor: ProfileInteractor, router: ProfileRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear(delegate: ProfileDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: ProfileDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }
    
    func onSettingsButtonPressed() {
        interactor.trackEvent(event: Event.settingsPressed)
        router.showSettingsView()
    }
    
}

extension ProfilePresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: ProfileDelegate)
        case onDisappear(delegate: ProfileDelegate)
        case settingsPressed

        var eventName: String {
            switch self {
            case .onAppear:                 return "ProfileView_Appear"
            case .onDisappear:              return "ProfileView_Disappear"
            case .settingsPressed:          return "ProfileView_Settings_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .onAppear(delegate: let delegate), .onDisappear(delegate: let delegate):
                return delegate.eventParameters
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
