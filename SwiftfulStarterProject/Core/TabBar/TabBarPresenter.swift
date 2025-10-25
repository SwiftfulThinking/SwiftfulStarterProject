import SwiftUI

struct TabBarTab: Identifiable {
    var id: String {
        title
    }

    let title: String
    let systemImage: String
    let content: AnyView

    @MainActor
    init<T: View>(
        title: String,
        systemImage: String,
        destination: @escaping (AnyRouter) -> T
    ) {
        self.title = title
        self.systemImage = systemImage
        self.content = RouterView { router in
            destination(router)
        }
        .any()
    }
    
    var eventParameters: [String: Any] {
        [
            "tab_title": title,
            "tab_id": id,
            "tab_icon": systemImage
        ]
    }

    static func == (lhs: TabBarTab, rhs: TabBarTab) -> Bool {
        lhs.id == rhs.id
    }
}

@Observable
@MainActor
class TabBarPresenter {

    private let interactor: TabBarInteractor

    var tabs: [TabBarTab]
    var selectedTab: String

    init(interactor: TabBarInteractor, delegate: TabBarDelegate) {
        self.interactor = interactor
        self.tabs = delegate.tabs
        self.selectedTab = delegate.startingTabId ?? ""
    }
    
    func onViewAppear(delegate: TabBarDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }

    func onViewDisappear(delegate: TabBarDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }

    func onTabSelected(tabId: String, isSameTabTapped: Bool, delegate: TabBarDelegate) {
        guard let tab = tabs.first(where: { $0.id == tabId }) else { return }

        // Track analytics
        if isSameTabTapped {
            interactor.trackEvent(event: Event.tabReselected(tab: tab, delegate: delegate))
        } else {
            interactor.trackEvent(event: Event.tabSelected(tab: tab, delegate: delegate))
        }

        // Update selection
        selectedTab = tabId
    }
}

extension TabBarPresenter {

    enum Event: LoggableEvent {
        case onAppear(delegate: TabBarDelegate)
        case onDisappear(delegate: TabBarDelegate)
        case tabSelected(tab: TabBarTab, delegate: TabBarDelegate)
        case tabReselected(tab: TabBarTab, delegate: TabBarDelegate)

        var eventName: String {
            switch self {
            case .onAppear:                 return "TabBarView_Appear"
            case .onDisappear:              return "TabBarView_Disappear"
            case .tabSelected:              return "TabBar_TabSelected"
            case .tabReselected:            return "TabBar_TabReselected"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .onAppear(delegate: let delegate), .onDisappear(delegate: let delegate):
                return delegate.eventParameters
            case .tabSelected(tab: let tab, delegate: let delegate), .tabReselected(tab: let tab, delegate: let delegate):
                var params = tab.eventParameters
                params.merge(delegate.eventParameters)
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
