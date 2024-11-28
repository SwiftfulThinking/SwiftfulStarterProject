//
//  WelcomeView.swift
//  
//
//  
//
import SwiftUI

struct WelcomeDelegate {
    var eventParameters: [String: Any]? {
        nil
    }
}

struct WelcomeView: View {
    
    @State var presenter: WelcomePresenter
    let delegate: WelcomeDelegate

    var body: some View {
        VStack(spacing: 8) {
            ImageLoaderView(urlString: presenter.imageName)
                .ignoresSafeArea()
            
            titleSection
                .padding(.top, 24)
            
            ctaButtons
                .padding(16)
            
            policyLinks
        }
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
    }
    
    private var titleSection: some View {
        VStack(spacing: 8) {
            Text("App Name")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
            Text("Add subtitle here")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
    }
    
    private var ctaButtons: some View {
        VStack(spacing: 8) {
            Text("Get Started")
                .callToActionButton()
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .anyButton(.press, action: {
                    presenter.onGetStartedPressed()
                })
                .accessibilityIdentifier("StartButton")
                .frame(maxWidth: 500)
            
            Text("Already have an account? Sign in!")
                .underline()
                .font(.body)
                .padding(8)
                .tappableBackground()
                .onTapGesture {
                    presenter.onSignInPressed()
                }
                .lineLimit(1)
                .minimumScaleFactor(0.3)
        }
    }
        
    private var policyLinks: some View {
        HStack(spacing: 8) {
            Link(destination: URL(string: Constants.termsOfServiceUrlString)!) {
                Text("Terms of Service")
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            Circle()
                .fill(.accent)
                .frame(width: 4, height: 4)
            Link(destination: URL(string: Constants.privacyPolicyUrlString)!) {
                Text("Privacy Policy")
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
        }
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return builder.onboardingFlow()
}

extension CoreBuilder {
    
    func onboardingFlow() -> some View {
        RouterView { router in
            welcomeView(router: router)
        }
    }
    
    private func welcomeView(router: AnyRouter, delegate: WelcomeDelegate = WelcomeDelegate()) -> some View {
        WelcomeView(
            presenter: WelcomePresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }

}

extension CoreRouter {
    
}
