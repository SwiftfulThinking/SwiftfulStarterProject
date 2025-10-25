import SwiftUI
import SwiftfulOnboarding

struct OnboardingDelegate {
    var eventParameters: [String: Any]? {
        nil
    }
}

struct OnboardingView: View {

    @State var presenter: OnboardingPresenter
    let delegate: OnboardingDelegate

    var body: some View {
        SwiftfulOnboardingView(
            configuration: OnbConfiguration(
                headerConfiguration: OnboardingConstants.headerConfiguration,
                slides: OnboardingConstants.slides,
                onSlideComplete: { slideData in
                    presenter.onSlideComplete(slideData: slideData, delegate: delegate)
                },
                onFlowComplete: { flowData in
                    presenter.onFlowComplete(flowData: flowData, delegate: delegate)
                }
            )
        )
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = OnboardingDelegate()
    
    return RouterView { router in
        builder.onboardingView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {
    
    func onboardingView(router: AnyRouter, delegate: OnboardingDelegate) -> some View {
        OnboardingView(
            presenter: OnboardingPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showOnboardingView(delegate: OnboardingDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingView(router: router, delegate: delegate)
        }
    }
    
}
