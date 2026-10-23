//
//  CreateAccountView.swift
//  
//
//  
//
import SwiftUI
import SwiftfulUI
import SwiftfulAuthUI
import SwiftfulRouting

struct CreateAccountDelegate {
    var title: String = "Create Account?"
    var subtitle: String = "Don't lose your data! Connect to an SSO provider to save your account."
    /// Shown first (session recovery: the provider the lost account used, from the keychain marker).
    var preferredProvider: AuthProviderOption?
    /// When set, the ONLY provider shown (switch-account: the user must use the owner account's exact method).
    var restrictedProvider: AuthProviderOption?
    var onDidSignIn: ((_ isNewUser: Bool) -> Void)?

    /// Providers to render, in order. Restricted wins; otherwise the preferred one moves to the front.
    var providers: [AuthProviderOption] {
        let all: [AuthProviderOption] = [.apple, .google]
        if let restrictedProvider, all.contains(restrictedProvider) { return [restrictedProvider] }
        guard let preferredProvider, all.contains(preferredProvider) else { return all }
        return [preferredProvider] + all.filter { $0 != preferredProvider }
    }
    
    var eventParameters: [String: Any]? {
        [
            "delegate_title": title,
            "delegate_subtitle": subtitle,
            "delegate_preferred_provider": preferredProvider?.rawValue ?? "none",
            "delegate_restricted_provider": restrictedProvider?.rawValue ?? "none"
        ]
    }
}

struct CreateAccountView: View {
    
    @State var presenter: CreateAccountPresenter
    var delegate: CreateAccountDelegate = CreateAccountDelegate()
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(delegate.title)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text(delegate.subtitle)
                    .font(.body)
                    .lineLimit(4)
                    .minimumScaleFactor(0.5)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                ForEach(delegate.providers, id: \.self) { provider in
                    providerButton(provider)
                        .frame(height: 55)
                        .frame(maxWidth: 400)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            Spacer()
        }
        .padding(16)
        .padding(.top, 40)
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
    }

    @ViewBuilder
    private func providerButton(_ provider: AuthProviderOption) -> some View {
        switch provider {
        case .google:
            SignInGoogleButtonView(
                type: .signIn,
                backgroundColor: .googleRed,
                cornerRadius: 10
            )
            .asButton(.press) {
                presenter.onSignInGooglePressed(delegate: delegate)
            }
        default:
            SignInAppleButtonView(
                type: .signIn,
                style: .black,
                cornerRadius: 10
            )
            .asButton(.press) {
                presenter.onSignInApplePressed(delegate: delegate)
            }
        }
    }
    
}

extension CoreBuilder {
    
    func createAccountView(router: AnyRouter, delegate: CreateAccountDelegate = CreateAccountDelegate()) -> some View {
        CreateAccountView(
            presenter: CreateAccountPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }

}

extension CoreRouter {
    
    func showCreateAccountView(delegate: CreateAccountDelegate, onDismiss: (() -> Void)? = nil) {
        let config = ResizableSheetConfig(
            detents: [.medium],
            selection: nil,
            dragIndicator: .hidden
        )
                
        router.showScreen(.sheetConfig(config: config), onDismiss: onDismiss) { _ in
            builder.createAccountView(router: router, delegate: delegate)
        }
    }

}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
        
    return RouterView { router in
        builder.createAccountView(router: router)
            .frame(maxHeight: 400)
            .frame(maxHeight: .infinity, alignment: .bottom)
    }
}
