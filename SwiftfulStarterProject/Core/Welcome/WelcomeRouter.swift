//
//  WelcomeRouter.swift
//  
//
//  
//

@MainActor
protocol WelcomeRouter: GlobalRouter {
    func showCreateAccountView(delegate: CreateAccountDelegate, onDismiss: (() -> Void)?)
    func showOnboardingCompletedView(delegate: OnboardingCompletedDelegate)
    func switchToTabbarModule()
}

extension CoreRouter: WelcomeRouter { }
