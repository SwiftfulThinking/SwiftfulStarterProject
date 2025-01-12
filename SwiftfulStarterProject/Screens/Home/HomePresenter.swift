import SwiftUI

@Observable
@MainActor
class HomePresenter {
    
    private let interactor: HomeInteractor
    private let router: HomeRouter
    
    init(interactor: HomeInteractor, router: HomeRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear(delegate: HomeDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: HomeDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }
    
    func handleDeepLink(url: URL) {
        interactor.trackEvent(event: Event.deepLinkStart)

        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems,
            !queryItems.isEmpty else {
            interactor.trackEvent(event: Event.deepLinkNoQueryItems)
            return
        }
        
        interactor.trackEvent(event: Event.deepLinkSuccess)
        
        for queryItem in queryItems {
            if let value = queryItem.value, !value.isEmpty {
                // Do something with value
            }
        }
    }
    
    func handlePushNotificationRecieved(notification: Notification) {
        interactor.trackEvent(event: Event.pushNotifStart)
        
        guard
            let userInfo = notification.userInfo,
            !userInfo.isEmpty else {
            interactor.trackEvent(event: Event.pushNotifNoData)
            return
        }
        
        interactor.trackEvent(event: Event.pushNotifSuccess)
        
        for (key, value) in userInfo {
            // Do something with (key, value)
        }
    }
}

extension HomePresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: HomeDelegate)
        case onDisappear(delegate: HomeDelegate)
        case deepLinkStart
        case deepLinkNoQueryItems
        case deepLinkSuccess
        case pushNotifStart
        case pushNotifNoData
        case pushNotifSuccess

        var eventName: String {
            switch self {
            case .onAppear:                 return "HomeView_Appear"
            case .onDisappear:              return "HomeView_Disappear"
            case .deepLinkStart:            return "HomeView_DeepLink_Start"
            case .deepLinkNoQueryItems:     return "HomeView_DeepLink_NoItems"
            case .deepLinkSuccess:          return "HomeView_DeepLink_Success"
            case .pushNotifStart:           return "HomeView_PushNotif_Start"
            case .pushNotifNoData:          return "HomeView_PushNotif_NoItems"
            case .pushNotifSuccess:         return "HomeView_PushNotif_Success"
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
