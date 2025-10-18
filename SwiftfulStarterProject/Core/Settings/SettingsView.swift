//
//  SettingsView.swift
//  
//
//  
//
import SwiftUI

struct SettingsView: View {
        
    @State var presenter: SettingsPresenter

    var body: some View {
        List {
            accountSection
            purchaseSection
            applicationSection
        }
        .lineLimit(1)
        .minimumScaleFactor(0.4)
        .navigationTitle("Settings")
        .onAppear {
            presenter.onViewAppear()
        }
        .onDisappear {
            presenter.onViewDisappear()
        }
    }
    
    private var accountSection: some View {
        Section {
            if presenter.isAnonymousUser {
                Text("Save & back-up account")
                    .rowFormatting()
                    .anyButton(.highlight) {
                        presenter.onCreateAccountPressed()
                    }
                    .removeListRowFormatting()
            } else {
                Text("Sign out")
                    .rowFormatting()
                    .anyButton(.highlight) {
                        presenter.onSignOutPressed()
                    }
                    .removeListRowFormatting()
            }
            
            Text("Delete account")
                .foregroundStyle(.red)
                .rowFormatting()
                .anyButton(.highlight) {
                    presenter.onDeleteAccountPressed()
                }
                .removeListRowFormatting()
        } header: {
            Text("Account")
        }
    }
    
    private var purchaseSection: some View {
        let isPremium = presenter.isPremium
        
        return Section {
            HStack(spacing: 8) {
                Text("Account status: \(isPremium ? "PREMIUM" : "FREE")")
                Spacer(minLength: 0)
                if isPremium {
                    Text("MANAGE")
                }
            }
            .rowFormatting()
            .anyButton(.highlight) {

            }
            .disabled(!isPremium)
            .removeListRowFormatting()
        } header: {
            Text("Purchases")
        }
    }
    
    private var applicationSection: some View {
        Section {
            HStack(spacing: 8) {
                Text("Version")
                Spacer(minLength: 0)
                Text(Utilities.appVersion ?? "")
                    .foregroundStyle(.secondary)
            }
            .rowFormatting()
            .removeListRowFormatting()
            
            HStack(spacing: 8) {
                Text("Build Number")
                Spacer(minLength: 0)
                Text(Utilities.buildNumber ?? "")
                    .foregroundStyle(.secondary)
            }
            .rowFormatting()
            .removeListRowFormatting()
            
            Text("Contact us")
                .foregroundStyle(.blue)
                .rowFormatting()
                .anyButton(.highlight, action: {
                    presenter.onContactUsPressed()
                })
                .removeListRowFormatting()
        } header: {
            Text("Application")
        } footer: {
            Text("2024 Developer, LLC")
                .baselineOffset(6)
        }
    }
    
}

private struct RowFormattingViewModifier: ViewModifier {
    
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(colorScheme.backgroundPrimary)
    }
}

fileprivate extension View {
    func rowFormatting() -> some View {
        modifier(RowFormattingViewModifier())
    }
}

#Preview("No auth") {
    let container = DevPreview.shared.container()
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: nil)))
    container.register(UserManager.self, service: UserManager(services: MockUserServices(document: nil)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return RouterView { router in
        builder.settingsView(router: router)
    }
}
#Preview("Anonymous") {
    let container = DevPreview.shared.container()
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: true))))
    container.register(UserManager.self, service: UserManager(services: MockUserServices(document: .mock)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return RouterView { router in
        builder.settingsView(router: router)
    }
}
#Preview("Not anonymous") {
    let container = DevPreview.shared.container()
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: false))))
    container.register(UserManager.self, service: UserManager(services: MockUserServices(document: .mock)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return RouterView { router in
        builder.settingsView(router: router)
    }
}

extension CoreBuilder {
    
    func settingsView(router: AnyRouter) -> some View {
        SettingsView(
            presenter: SettingsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
    
}

extension CoreRouter {
    
    func showSettingsView() {
        router.showScreen(.sheet) { router in
            builder.settingsView(router: router)
        }
    }

}
