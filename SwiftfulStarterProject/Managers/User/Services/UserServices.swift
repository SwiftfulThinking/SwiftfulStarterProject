//
//  UserServices.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 10/15/24.
//
@MainActor
protocol UserServices {
    var remote: RemoteUserService { get }
    var local: LocalUserPersistence { get }
}

@MainActor
struct MockUserServices: UserServices {
    let remote: RemoteUserService
    let local: LocalUserPersistence

    init(user: UserModel? = nil) {
        self.remote = MockUserService(user: user)
        self.local = MockUserPersistence(user: user)
    }
}

struct ProductionUserServices: UserServices {
    let remote: RemoteUserService = FirebaseUserService()
    let local: LocalUserPersistence = FileManagerUserPersistence()
}
