//
//  CreateAccountRouter.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 11/15/24.
//
@MainActor
protocol CreateAccountRouter {
    func dismissScreen()
}

extension CoreRouter: CreateAccountRouter { }
