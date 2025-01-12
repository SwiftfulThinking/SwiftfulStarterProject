//
//  TabBarView.swift
//  
//
//  
//

import SwiftUI

struct TabBarScreen: Identifiable {
    var id: String {
        title
    }
    
    let title: String
    let systemImage: String
    @ViewBuilder var screen: () -> AnyView
}

struct TabBarView: View {
    
    var tabs: [TabBarScreen]

    var body: some View {
        TabView {
            ForEach(tabs) { tab in
                tab.screen()
                    .tabItem {
                        Label(tab.title, systemImage: tab.systemImage)
                    }
            }
        }
    }
}

extension CoreBuilder {
    
    func tabbarView() -> some View {
        TabBarView(
            tabs: [
                TabBarScreen(title: "Home", systemImage: "house.fill", screen: {
                    RouterView { router in
                        homeView(router: router, delegate: HomeDelegate())
                    }
                    .any()
                }),
                TabBarScreen(title: "Beta", systemImage: "heart.fill", screen: {
                    RouterView { _ in
                        Text("Beta")
                    }
                    .any()
                }),
                TabBarScreen(title: "Profile", systemImage: "person.fill", screen: {
                    RouterView { router in
                        profileView(router: router, delegate: ProfileDelegate())
                    }
                    .any()
                })
            ]
        )
    }

}

#Preview("Fake tabs") {
    TabBarView(tabs: [
        TabBarScreen(title: "Explore", systemImage: "eyes", screen: {
            Color.red.any()
        }),
        TabBarScreen(title: "Chats", systemImage: "bubble.left.and.bubble.right.fill", screen: {
            Color.blue.any()
        }),
        TabBarScreen(title: "Profile", systemImage: "person.fill", screen: {
            Color.green.any()
        })
    ])
}

#Preview("Real tabs") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return builder.tabbarView()
}
