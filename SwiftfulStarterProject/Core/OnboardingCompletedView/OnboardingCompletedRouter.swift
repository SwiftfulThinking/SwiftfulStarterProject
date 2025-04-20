//
//  OnboardingCompletedRouter.swift
//  
//
//  
//

@MainActor
protocol OnboardingCompletedRouter: GlobalRouter {
    func switchToTabbarModule()
}

extension CoreRouter: OnboardingCompletedRouter { }
