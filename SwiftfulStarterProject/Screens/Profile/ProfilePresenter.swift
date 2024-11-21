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
    
    func onSettingsButtonPressed() {
        interactor.trackEvent(event: Event.settingsPressed)
        router.showSettingsView()
    }
    
    enum Event: LoggableEvent {
        case settingsPressed

        var eventName: String {
            switch self {
            case .settingsPressed:          return "ProfileView_Settings_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
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
