//
//  CreateAccountInteractor.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 11/15/24.
//
@MainActor
protocol CreateAccountInteractor: GlobalInteractor {
    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func logIn(user: UserAuthInfo, isNewUser: Bool) async throws
}

extension CoreInteractor: CreateAccountInteractor { }
