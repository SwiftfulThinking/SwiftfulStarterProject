import SwiftUI

@Observable
@MainActor
class ModuleWrapperPresenter {

    private let interactor: ModuleWrapperInteractor
    private let router: ModuleWrapperRouter

    init(interactor: ModuleWrapperInteractor, router: ModuleWrapperRouter) {
        self.interactor = interactor
        self.router = router
    }

    func onDevSettingsButtonPressed() {
        router.showDevSettingsView()
    }

    // WARNING: This view does NOT have a NavigationStack, so router.showScreen(.push) will NOT work here.
    // Supported: .fullScreenCover, .sheet, showModal, showAlert, update interactor, post notification.
    // If you need .push, post a notification and handle it in a child view that has a NavigationStack.
    func handleDeepLink(url: URL, delegate: ModuleWrapperDelegate) {
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

    // WARNING: This view does NOT have a NavigationStack, so router.showScreen(.push) will NOT work here.
    // Supported: .fullScreenCover, .sheet, showModal, showAlert, update interactor, post notification.
    // If you need .push, post a notification and handle it in a child view that has a NavigationStack.
    func handlePushNotificationReceived(notification: Notification, delegate: ModuleWrapperDelegate) {
        interactor.trackEvent(event: Event.pushNotifStart)

        guard
            let userInfo = notification.userInfo,
            !userInfo.isEmpty else {
            interactor.trackEvent(event: Event.pushNotifNoData)
            return
        }

        interactor.trackEvent(event: Event.pushNotifSuccess)

        for (_, _) in userInfo {
            // Do something with (key, value)
        }
    }
}

extension ModuleWrapperPresenter {

    enum Event: LoggableEvent {
        case deepLinkStart
        case deepLinkNoQueryItems
        case deepLinkSuccess
        case pushNotifStart
        case pushNotifNoData
        case pushNotifSuccess

        var eventName: String {
            switch self {
            case .deepLinkStart:            return "ModuleWrapper_DeepLink_Start"
            case .deepLinkNoQueryItems:     return "ModuleWrapper_DeepLink_NoItems"
            case .deepLinkSuccess:          return "ModuleWrapper_DeepLink_Success"
            case .pushNotifStart:           return "ModuleWrapper_PushNotif_Start"
            case .pushNotifNoData:          return "ModuleWrapper_PushNotif_NoItems"
            case .pushNotifSuccess:         return "ModuleWrapper_PushNotif_Success"
            }
        }

        var parameters: [String: Any]? {
            nil
        }

        var type: LogType {
            .analytic
        }
    }
}
