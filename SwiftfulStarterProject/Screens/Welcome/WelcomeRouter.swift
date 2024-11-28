//
//  WelcomeRouter.swift
//  
//
//  
//

@MainActor
protocol WelcomeRouter {
    func showCreateAccountView(delegate: CreateAccountDelegate, onDismiss: (() -> Void)?)
    func showOnboardingCompletedView(delegate: OnboardingCompletedDelegate)
}

extension CoreRouter: WelcomeRouter { }
