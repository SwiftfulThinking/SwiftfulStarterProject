//
//  AppViewInteractor.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 11/15/24.
//

@MainActor
protocol AppViewInteractor: GlobalInteractor {
    var auth: UserAuthInfo? { get }
    var showTabBar: Bool { get }
    
    func logIn(user: UserAuthInfo, isNewUser: Bool) async throws
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool)
}

extension CoreInteractor: AppViewInteractor { }
