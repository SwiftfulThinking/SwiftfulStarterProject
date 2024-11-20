import SwiftUI

@MainActor
struct CoreBuilder: Builder {
    let interactor: CoreInteractor
    
    func build() -> AnyView {
        appView().any()
    }
    
    func appView() -> some View {
        AppView(
            presenter: AppPresenter(
                interactor: interactor
            ),
            tabbarView: {
                Text("HI")
            },
            onboardingView: {
                Text("Bye")
            }
        )
    }
}
