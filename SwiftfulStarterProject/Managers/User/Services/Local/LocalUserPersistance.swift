//
//  LocalUserPersistence.swift
//  
//
//  
//

@MainActor
protocol LocalUserPersistence {
    func getCurrentUser() -> UserModel?
    func saveCurrentUser(user: UserModel?) throws
}
