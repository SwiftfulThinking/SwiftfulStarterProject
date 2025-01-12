//
//  DevSettingsInteractor.swift
//  
//
//  
//
@MainActor
protocol DevSettingsInteractor: GlobalInteractor {
    var activeTests: ActiveABTests { get }
    var auth: UserAuthInfo? { get }
    var currentUser: UserModel? { get }
    
    func override(updateTests: ActiveABTests) throws
}

extension CoreInteractor: DevSettingsInteractor { }
