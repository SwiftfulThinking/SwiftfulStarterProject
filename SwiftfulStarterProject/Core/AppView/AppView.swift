//
//  AppView.swift
//  
//
//  
//
import SwiftUI
import SwiftfulUI

struct AppView<Content: View>: View {

    @State var presenter: AppPresenter
    @ViewBuilder var content: () -> Content

    var body: some View {
        RootView(
            delegate: RootDelegate(
                onApplicationDidAppear: nil,
                onApplicationWillEnterForeground: { _ in
                    Task {
                        await presenter.checkUserStatus()
                    }
                },
                onApplicationDidBecomeActive: nil,
                onApplicationWillResignActive: nil,
                onApplicationDidEnterBackground: nil,
                onApplicationWillTerminate: nil
            ),
            content: {
                content()
                    .task {
                        await presenter.checkUserStatus()
                    }
                    .task {
                        try? await Task.sleep(for: .seconds(2))
                        await presenter.showATTPromptIfNeeded()
                    }
                    .onChange(of: presenter.auth?.uid) { _, newValue in
                        if newValue == nil || newValue?.isEmpty == true {
                            Task {
                                await presenter.checkUserStatus()
                            }
                        }
                    }
            }
        )
        .onNotificationReceived(name: .fcmToken, action: { notification in
            presenter.onFCMTokenRecieved(notification: notification)
        })
        .onAppear {
            presenter.onViewAppear()
        }
        .onDisappear {
            presenter.onViewDisappear()
        }
    }
}

#Preview("AppView - Tabbar") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return builder.appView()
}
#Preview("AppView - Onboarding") {
    let container = DevPreview.shared.container()
    container.register(UserManager.self, service: UserManager.mock())
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: nil)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    return builder.appView()
}

extension CoreBuilder {
    
    func appView() -> some View {
        AppView(
            presenter: AppPresenter(
                interactor: interactor
            ),
            content: {
                switch interactor.startingModuleId {
                case Constants.tabbarModuleId:
                    let delegate = ModuleWrapperDelegate(moduleId: Constants.tabbarModuleId)
                    RouterView(id: delegate.moduleId, addNavigationStack: false, addModuleSupport: true) { router in
                        coreModuleEntryView(router: router, delegate: delegate)
                    }
                default:
                    let delegate = ModuleWrapperDelegate(moduleId: Constants.onboardingModuleId)
                    RouterView(id: delegate.moduleId, addNavigationStack: false, addModuleSupport: true) { router in
                        onboardingModuleEntryView(router: router, delegate: delegate)
                    }
                }
            }
        )
    }

    func onboardingModuleEntryView(router: AnyRouter, delegate: ModuleWrapperDelegate) -> some View {
        moduleWrapperView(router: router, delegate: delegate) {
            onboardingFlow()
        }
    }

    func coreModuleEntryView(router: AnyRouter, delegate: ModuleWrapperDelegate) -> some View {
        moduleWrapperView(router: router, delegate: delegate) {
            coreModuleTabBarView()
        }
    }

    private func coreModuleTabBarView() -> some View {
        let tabs: [TabBarTab] = [
            TabBarTab(title: "Home", systemImage: "house.fill", destination: { router in
                homeView(router: router, delegate: HomeDelegate())
            }),
            // #feature-start: gamification
            TabBarTab(title: "Beta", systemImage: "heart.fill", destination: { router in
                sampleGamificationViewForMock(router: router)
            }),
            // #feature-end: gamification
            TabBarTab(title: "Profile", systemImage: "person.fill", destination: { router in
                profileView(router: router, delegate: ProfileDelegate())
            })
        ]
        
        return tabBarView(
            delegate: TabBarDelegate(
                tabs: tabs,
                startingTabId: tabs.first?.id
            )
        )
    }

    // #feature-start: gamification
    private func sampleGamificationViewForMock(router: AnyRouter) -> some View {
        List {
            Button("Streaks") {
                router.showScreen { router in
                    streakExampleView(router: router, delegate: StreakExampleDelegate())
                }
            }
            Button("Experience Points") {
                router.showScreen { router in
                    experiencePointsExampleView(router: router, delegate: ExperiencePointsExampleDelegate())
                }
            }
            Button("Progress") {
                router.showScreen { router in
                    progressExampleView(router: router, delegate: ProgressExampleDelegate())
                }
            }
        }
        .navigationTitle("Gamification Examples")
    }
    // #feature-end: gamification
}

extension CoreRouter {
    
    func switchToCoreModule() {
        let delegate = ModuleWrapperDelegate(moduleId: Constants.tabbarModuleId)
        router.showModule(.top(animation: .snappy), id: delegate.moduleId, onDismiss: nil) { router in
            self.builder.coreModuleEntryView(router: router, delegate: delegate)
        }
    }
    
}

extension CoreRouter {
    
    func switchToOnboardingModule() {
        let delegate = ModuleWrapperDelegate(moduleId: Constants.onboardingModuleId)
        router.showModule(.bottom(animation: .snappy), id: delegate.moduleId, onDismiss: nil) { router in
            self.builder.onboardingModuleEntryView(router: router, delegate: delegate)
        }
    }
}
