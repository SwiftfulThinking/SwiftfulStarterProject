//
//  RemoteUserService.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 10/15/24.
//

@MainActor
protocol RemoteUserService: Sendable {
    func saveUser(user: UserModel) async throws
    func markOnboardingCompleted(userId: String) async throws
    func streamUser(userId: String, onListenerConfigured: @escaping (ListenerRegistration) -> Void) -> AsyncThrowingStream<UserModel, Error>
    func deleteUser(userId: String) async throws
}
