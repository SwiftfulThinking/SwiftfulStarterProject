//
//  PaywallRouter.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 11/15/24.
//

@MainActor
protocol PaywallRouter {
    func dismissScreen()
    func showAlert(error: Error)
}

extension CoreRouter: PaywallRouter { }
