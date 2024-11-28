//
//  OnboardingCompletedRouter.swift
//  
//
//  
//

@MainActor
protocol OnboardingCompletedRouter {
    func showAlert(error: Error)
}

extension CoreRouter: OnboardingCompletedRouter { }
