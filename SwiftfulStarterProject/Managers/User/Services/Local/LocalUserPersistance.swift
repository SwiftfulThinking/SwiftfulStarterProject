//
//  LocalUserPersistence.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 10/15/24.
//

@MainActor
protocol LocalUserPersistence {
    func getCurrentUser() -> UserModel?
    func saveCurrentUser(user: UserModel?) throws
}
