//
//  MockUserPersistence.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 10/15/24.
//

struct MockUserPersistence: LocalUserPersistence {
    
    let currentUser: UserModel?
    
    init(user: UserModel? = nil) {
        self.currentUser = user
    }
    
    func getCurrentUser() -> UserModel? {
        currentUser
    }
    
    func saveCurrentUser(user: UserModel?) throws {
        
    }
}
