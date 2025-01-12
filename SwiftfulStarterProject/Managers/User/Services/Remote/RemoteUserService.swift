//
//  RemoteUserService.swift
//  
//
//  
//

@MainActor
protocol RemoteUserService: Sendable {
    func saveUser(user: UserModel) async throws
    func saveUserFCMToken(userId: String, token: String) async throws
    func markOnboardingCompleted(userId: String) async throws
    func streamUser(userId: String, onListenerConfigured: @escaping (ListenerRegistration) -> Void) -> AsyncThrowingStream<UserModel, Error>
    func deleteUser(userId: String) async throws
}
