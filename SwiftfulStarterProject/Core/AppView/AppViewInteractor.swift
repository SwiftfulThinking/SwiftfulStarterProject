//
//  AppViewInteractor.swift
//  
//
//  
//

@MainActor
protocol AppViewInteractor: GlobalInteractor {
    var auth: UserAuthInfo? { get }
    var startingModuleId: String { get }
    
    func logIn(user: UserAuthInfo, isNewUser: Bool) async throws
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func saveUserFCMToken(token: String) async throws
}

extension CoreInteractor: AppViewInteractor { }
