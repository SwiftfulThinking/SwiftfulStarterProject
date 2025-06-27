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
        .onNotificationRecieved(name: .fcmToken, action: { notification in
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
    container.register(UserManager.self, service: UserManager(services: MockUserServices(user: nil)))
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
                    RouterView(id: Constants.tabbarModuleId, addNavigationStack: false, addModuleSupport: true) { _ in
                        coreModuleEntryView()
                    }
                default:
                    RouterView(id: Constants.onboardingModuleId, addNavigationStack: false, addModuleSupport: true) { _ in
                        onboardingModuleEntryView()
                    }
                }
            }
        )
    }

    func onboardingModuleEntryView() -> some View {
        onboardingFlow()
    }
    
    func coreModuleEntryView() -> some View {
        tabbarView()
    }
    
}

extension CoreRouter {
    
    func switchToCoreModule() {
        router.showModule(.trailing, id: Constants.tabbarModuleId, onDismiss: nil) { _ in
            self.builder.coreModuleEntryView()
        }
    }
    
}

extension CoreRouter {
    
    func switchToOnboardingModule() {
        router.showModule(.trailing, id: Constants.onboardingModuleId, onDismiss: nil) { _ in
            self.builder.onboardingModuleEntryView()
        }
    }
}
