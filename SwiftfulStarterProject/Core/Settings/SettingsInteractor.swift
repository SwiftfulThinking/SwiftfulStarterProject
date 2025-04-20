//
//  SettingsInteractor.swift
//  
//
//  
//

@MainActor
protocol SettingsInteractor: GlobalInteractor {
    var auth: UserAuthInfo? { get }
    
    func signOut() async throws
    func deleteAccount() async throws
}

extension CoreInteractor: SettingsInteractor { }
