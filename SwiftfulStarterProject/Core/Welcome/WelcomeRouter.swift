//
//  WelcomeRouter.swift
//  
//
//  
//

@MainActor
protocol WelcomeRouter: GlobalRouter {
    func showCreateAccountView(delegate: CreateAccountDelegate, onDismiss: (() -> Void)?)
    func showOnboardingView(delegate: OnboardingDelegate)
    func switchToCoreModule()
}

extension CoreRouter: WelcomeRouter { }
