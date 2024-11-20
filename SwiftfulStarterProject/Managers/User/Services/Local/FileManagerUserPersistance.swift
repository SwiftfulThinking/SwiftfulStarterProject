//
//  FileManagerUserPersistence.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 10/15/24.
//
import SwiftUI

struct FileManagerUserPersistence: LocalUserPersistence {
    private let userDocumentKey = "current_user"
    
    func getCurrentUser() -> UserModel? {
        try? FileManager.getDocument(key: userDocumentKey)
    }
    
    func saveCurrentUser(user: UserModel?) throws {
        try FileManager.saveDocument(key: userDocumentKey, value: user)
    }
}
