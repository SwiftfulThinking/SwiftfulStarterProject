import SwiftUI
import SwiftfulUI

struct ModuleWrapperDelegate {
    let moduleId: String

    var eventParameters: [String: Any]? {
        nil
    }
}

struct ModuleWrapperView<Content: View>: View {

    @State var presenter: ModuleWrapperPresenter
    let delegate: ModuleWrapperDelegate
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .onOpenURL { url in
                presenter.handleDeepLink(url: url, delegate: delegate)
            }
            .onNotificationReceived(name: .pushNotification) { notification in
                presenter.handlePushNotificationReceived(notification: notification, delegate: delegate)
            }
            #if DEBUG
            .overlay {
                Image(systemName: "wrench.and.screwdriver")
                    .font(.title2)
                    .padding(16)
                    .asButton(.press) {
                        presenter.onDevSettingsButtonPressed()
                    }
                    .padding(.bottom, 24)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .ignoresSafeArea()
            }
            #endif
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)

    return RouterView { router in
        ModuleWrapperView(
            presenter: ModuleWrapperPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: builder)
            ),
            delegate: ModuleWrapperDelegate(moduleId: Constants.tabbarModuleId),
            content: {
                Text("Module Content")
            }
        )
    }
}

extension CoreBuilder {

    func moduleWrapperView(router: AnyRouter, delegate: ModuleWrapperDelegate, @ViewBuilder content: @escaping () -> some View) -> some View {
        ModuleWrapperView(
            presenter: ModuleWrapperPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate,
            content: content
        )
    }
}
