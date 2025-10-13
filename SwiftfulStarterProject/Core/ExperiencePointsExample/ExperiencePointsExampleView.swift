import SwiftUI

struct ExperiencePointsExampleDelegate {
    var eventParameters: [String: Any]? {
        nil
    }
}

struct ExperiencePointsExampleView: View {
    
    @State var presenter: ExperiencePointsExamplePresenter
    let delegate: ExperiencePointsExampleDelegate
    
    var body: some View {
        Text("Hello, World!")
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
    let delegate = ExperiencePointsExampleDelegate()
    
    return RouterView { router in
        builder.experiencePointsExampleView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {
    
    func experiencePointsExampleView(router: AnyRouter, delegate: ExperiencePointsExampleDelegate) -> some View {
        ExperiencePointsExampleView(
            presenter: ExperiencePointsExamplePresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showExperiencePointsExampleView(delegate: ExperiencePointsExampleDelegate) {
        router.showScreen(.push) { router in
            builder.experiencePointsExampleView(router: router, delegate: delegate)
        }
    }
    
}
