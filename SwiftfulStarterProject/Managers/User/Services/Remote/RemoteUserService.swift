//
//  RemoteUserService.swift
//  
//
//  
//
import UIKit

@MainActor
protocol RemoteUserService: Sendable {
    func getUser(userId: String) async throws -> UserModel
    func saveUser(user: UserModel) async throws
    func saveUserFCMToken(userId: String, token: String) async throws
    func saveUserName(userId: String, name: String) async throws
    func saveUserEmail(userId: String, email: String) async throws
    func saveUserProfileImage(userId: String, image: UIImage) async throws
    func markOnboardingCompleted(userId: String) async throws
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, Error>
    func deleteUser(userId: String) async throws
}
