//
//  MockUserService.swift
//  
//
//  
//
import SwiftUI

@MainActor
class MockUserService: RemoteUserService {
    
    @Published var currentUser: UserModel?
    
    init(user: UserModel? = nil) {
        self.currentUser = user
    }
    
    func saveUser(user: UserModel) async throws {
        currentUser = user
    }
    
    func saveUserFCMToken(userId: String, token: String) async throws {
        
    }
    
    func markOnboardingCompleted(userId: String) async throws {
        guard var currentUser else {
            throw URLError(.unknown)
        }
        
        currentUser.markDidCompleteOnboarding()
        self.currentUser = currentUser
    }
    
    func streamUser(userId: String, onListenerConfigured: @escaping (any ListenerRegistration) -> Void) -> AsyncThrowingStream<UserModel, any Error> {
        AsyncThrowingStream { continuation in
            if let currentUser {
                continuation.yield(currentUser)
            }
            
            Task {
                for await value in $currentUser.values {
                    if let value {
                        continuation.yield(value)
                    }
                }
            }
        }
    }
    
    func deleteUser(userId: String) async throws {
        currentUser = nil
    }
    
}
