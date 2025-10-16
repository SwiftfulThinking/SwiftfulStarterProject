//
//  OnboardingCompletedRouter.swift
//  
//
//  
//

@MainActor
protocol OnboardingCompletedRouter: GlobalRouter {
    func switchToCoreModule()
}

extension CoreRouter: OnboardingCompletedRouter { }
