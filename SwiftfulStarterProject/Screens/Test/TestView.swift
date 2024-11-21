import SwiftUI

struct TestDelegate {
    
    var eventParameters: [String: Any]? {
        nil
    }
}

struct TestView: View {
    
    @State var presenter: TestPresenter
    let delegate: TestDelegate
    
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

extension CoreBuilder {
    
    func testView(router: Router, delegate: TestDelegate) -> some View {
        TestView(
            presenter: TestPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showTestView(delegate: TestDelegate) {
        router.showScreen(.push) { router in
            builder.testView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = TestDelegate()
    
    return RouterView { router in
        builder.testView(router: router, delegate: delegate)
    }
}
