//
//  WelcomeView.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 10/5/24.
//
import SwiftUI

struct WelcomeView: View {
    
    @State var presenter: WelcomePresenter

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
        .screenAppearAnalytics(name: "WelcomeView")
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
    
    return builder.welcomeView()
        .previewEnvironment()
}

extension CoreBuilder {
    
    func welcomeView() -> some View {
        RouterView { router in
            WelcomeView(
                presenter: WelcomePresenter(
                    interactor: interactor,
                    router: CoreRouter(router: router, builder: self)
                )
            )
        }
    }

}

extension CoreRouter {
    
}
