//
//  OnboardingCompletedRouter.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 11/15/24.
//

@MainActor
protocol OnboardingCompletedRouter {
    func showAlert(error: Error)
}

extension CoreRouter: OnboardingCompletedRouter { }
