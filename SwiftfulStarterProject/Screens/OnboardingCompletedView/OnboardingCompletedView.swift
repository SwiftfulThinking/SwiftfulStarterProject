//
//  OnboardingCompletedView.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 10/6/24.
//

import SwiftUI

struct OnboardingCompletedDelegate {
    
}

struct OnboardingCompletedView: View {
    
    @State var presenter: OnboardingCompletedPresenter
    var delegate: OnboardingCompletedDelegate = OnboardingCompletedDelegate()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Welcome to our app!")
                .font(.largeTitle)
                .fontWeight(.semibold)

            Text("Click finish to begin.")
                .font(.title)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .frame(maxHeight: .infinity)
        .safeAreaInset(edge: .bottom, content: {
            AsyncCallToActionButton(
                isLoading: presenter.isCompletingProfileSetup,
                title: "Finish",
                action: {
                    presenter.onFinishButtonPressed()
                }
            )
            .accessibilityIdentifier("FinishButton")
        })
        .padding(24)
        .toolbar(.hidden, for: .navigationBar)
        .screenAppearAnalytics(name: "OnboardingCompletedView")
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return RouterView { router in
        builder.onboardingCompletedView(
            router: router,
            delegate: OnboardingCompletedDelegate()
        )
    }
    .previewEnvironment()
}

extension CoreBuilder {
    
    func onboardingCompletedView(router: Router, delegate: OnboardingCompletedDelegate) -> some View {
        OnboardingCompletedView(
            presenter: OnboardingCompletedPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }

}

extension CoreRouter {
    
    func showOnboardingCompletedView(delegate: OnboardingCompletedDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingCompletedView(router: router, delegate: delegate)
        }
    }

}
