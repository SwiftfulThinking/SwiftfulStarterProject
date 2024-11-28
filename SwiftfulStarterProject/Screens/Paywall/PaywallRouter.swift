//
//  PaywallRouter.swift
//  
//
//  
//

@MainActor
protocol PaywallRouter {
    func dismissScreen()
    func showAlert(error: Error)
}

extension CoreRouter: PaywallRouter { }
