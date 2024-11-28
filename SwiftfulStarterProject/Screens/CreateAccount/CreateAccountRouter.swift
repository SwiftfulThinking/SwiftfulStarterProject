//
//  CreateAccountRouter.swift
//  
//
//  
//
@MainActor
protocol CreateAccountRouter {
    func dismissScreen()
}

extension CoreRouter: CreateAccountRouter { }
