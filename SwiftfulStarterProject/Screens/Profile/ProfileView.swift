import SwiftUI

struct ProfileDelegate {
    
}

struct ProfileView: View {
    
    @State var presenter: ProfilePresenter
    let delegate: ProfileDelegate
    
    var body: some View {
        List {
            Text("Hello, world!")
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                settingsButton
            }
        }
        .screenAppearAnalytics(name: "ProfileView")
    }
    
    private var settingsButton: some View {
        Image(systemName: "gear")
            .font(.headline)
            .foregroundStyle(.accent)
            .anyButton {
                presenter.onSettingsButtonPressed()
            }
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = ProfileDelegate()
    
    return RouterView { router in
        builder.profileView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}

extension CoreBuilder {
    
    func profileView(router: Router, delegate: ProfileDelegate = ProfileDelegate()) -> some View {
        ProfileView(
            presenter: ProfilePresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showProfileView(delegate: ProfileDelegate) {
        router.showScreen(.push) { router in
            builder.profileView(router: router, delegate: delegate)
        }
    }
    
}
