//
//  FirebaseUserService.swift
//  
//
//  
//
import FirebaseFirestore
import SwiftfulFirestore

typealias ListenerRegistration = FirebaseFirestore.ListenerRegistration

struct AnyListener: @unchecked Sendable {
    let listener: ListenerRegistration
}

struct FirebaseUserService: RemoteUserService {
    
    var collection: CollectionReference {
        Firestore.firestore().collection("users")
    }
    
    func getUser(userId: String) async throws -> UserModel {
        try await collection.getDocument(id: userId)
    }
    
    func saveUser(user: UserModel) async throws {
        try collection.document(user.userId).setData(from: user, merge: true)
    }
    
    func saveUserName(userId: String, name: String) async throws {
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.submittedName.rawValue: name
        ])
    }
    
    func saveUserEmail(userId: String, email: String) async throws {
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.submittedEmail.rawValue: email
        ])
    }
    
    func saveUserProfileImage(userId: String, image: UIImage) async throws {
        // Upload the image
        let path = "users/\(userId)/profile"
        let url = try await FirebaseImageUploadService().uploadImage(image: image, path: path)
        
        // Update user document with image url string
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.submittedProfileImage.rawValue: url.absoluteString
        ])
    }
    
    func saveUserFCMToken(userId: String, token: String) async throws {
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.fcmToken.rawValue: token
        ])
    }
    
    func markOnboardingCompleted(userId: String) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.didCompleteOnboarding.rawValue: true
        ])
    }
    
    func streamUser(userId: String, onListenerConfigured: @escaping (ListenerRegistration) -> Void) -> AsyncThrowingStream<UserModel, Error> {
        collection.streamDocument(id: userId, onListenerConfigured: onListenerConfigured)
    }
    
    func deleteUser(userId: String) async throws {
        try await collection.document(userId).delete()
    }
}
