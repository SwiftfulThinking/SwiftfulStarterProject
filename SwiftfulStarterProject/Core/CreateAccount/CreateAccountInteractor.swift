//
//  CreateAccountInteractor.swift
//  
//
//  
//
@MainActor
protocol CreateAccountInteractor: GlobalInteractor {
    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func signInGoogle() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func logIn(user: UserAuthInfo, isNewUser: Bool) async throws
}

extension CoreInteractor: CreateAccountInteractor { }
