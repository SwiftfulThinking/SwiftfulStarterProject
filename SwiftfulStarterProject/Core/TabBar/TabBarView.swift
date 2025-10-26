import SwiftUI

struct TabBarDelegate {
    let tabs: [TabBarTab]
    let startingTabId: String?

    init(tabs: [TabBarTab], startingTabId: String? = nil) {
        self.tabs = tabs
        self.startingTabId = startingTabId
    }
    
    var eventParameters: [String: Any]? {
        var params: [String: Any] = [
            "tabs_count": tabs.count,
            "tabs_titles": tabs.map({ $0.title })
        ]
        if let startingTabId {
            params["tabs_starting_id"] = startingTabId
        }
        return params
    }
}

struct TabBarView: View {

    @State var presenter: TabBarPresenter
    let delegate: TabBarDelegate

    // Custom binding to intercept tab selections
    private var selectionHandler: Binding<String> {
        Binding(
            get: {
                presenter.selectedTab
            },
            set: { newValue in
                let isSameTab = newValue == presenter.selectedTab
                presenter.onTabSelected(tabId: newValue, isSameTabTapped: isSameTab, delegate: delegate)
            }
        )
    }

    var body: some View {
        TabView(selection: selectionHandler) {
            ForEach(delegate.tabs) { tab in
                tab.content
                    .tabItem {
                        Label(tab.title, systemImage: tab.systemImage)
                    }
                    .tag(tab.id)
            }
        }
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
    }
}

#Preview("Real tabs") {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    return builder.coreModuleEntryView()
}

extension CoreBuilder {

    func tabBarView(delegate: TabBarDelegate) -> some View {
        TabBarView(
            presenter: TabBarPresenter(
                interactor: interactor,
                delegate: delegate
            ),
            delegate: delegate
        )
    }

}

/*
 
 
 #Preview("Fake tabs") {
     TabBarView(
         tabs: [
             TabBarScreen(title: "Explore", systemImage: "eyes", screen: {
                 VStack(spacing: 20) {
                     Color.red
                 }
                 .any()
             }),
             TabBarScreen(title: "Chats", systemImage: "bubble.left.and.bubble.right.fill", screen: {
                 VStack(spacing: 20) {
                     Color.blue
                 }
                 .any()
             }),
             TabBarScreen(title: "Profile", systemImage: "person.fill", screen: {
                 VStack(spacing: 20) {
                     Color.green
                 }
                 .any()
             })
         ],
         onTabSelected: { tab, isSameTabTapped in
             print("🧪 Preview: Tab selected - \(tab.title), Same tab: \(isSameTabTapped)")
         }
     )
 }
 */
