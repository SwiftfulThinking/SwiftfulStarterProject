//
//  UserModel.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 10/9/24.
//
import Foundation
import SwiftUI

struct UserModel: Codable {
    
    let userId: String
    let email: String?
    let isAnonymous: Bool?
    let authProviders: [String]?
    let displayName: String?
    let firstName: String?
    let lastName: String?
    let phoneNumber: String?
    let photoURL: String?
    let creationDate: Date?
    let creationVersion: String?
    let lastSignInDate: Date?
    private(set) var didCompleteOnboarding: Bool?
    
    init(
        userId: String,
        email: String? = nil,
        isAnonymous: Bool? = nil,
        authProviders: [String]? = nil,
        displayName: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        phoneNumber: String? = nil,
        photoURL: String? = nil,
        creationDate: Date? = nil,
        creationVersion: String? = nil,
        lastSignInDate: Date? = nil,
        didCompleteOnboarding: Bool? = nil
    ) {
        self.userId = userId
        self.email = email
        self.isAnonymous = isAnonymous
        self.authProviders = authProviders
        self.displayName = displayName
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.photoURL = photoURL
        self.creationDate = creationDate
        self.creationVersion = creationVersion
        self.lastSignInDate = lastSignInDate
        self.didCompleteOnboarding = didCompleteOnboarding
    }
    
    init(auth: UserAuthInfo, creationVersion: String?) {
        self.init(
            userId: auth.uid,
            email: auth.email,
            isAnonymous: auth.isAnonymous,
            authProviders: auth.authProviders.map({ $0.rawValue }),
            displayName: auth.displayName,
            firstName: auth.firstName,
            lastName: auth.lastName,
            phoneNumber: auth.phoneNumber,
            photoURL: auth.photoURL?.absoluteString,
            creationDate: auth.creationDate,
            creationVersion: creationVersion,
            lastSignInDate: auth.lastSignInDate
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email
        case isAnonymous = "is_anonymous"
        case authProviders = "auth_providers"
        case displayName = "display_name"
        case firstName = "first_name"
        case lastName = "last_name"
        case phoneNumber = "phone_number"
        case photoURL = "photo_url"
        case creationDate = "creation_date"
        case creationVersion = "creation_version"
        case lastSignInDate = "last_sign_in_date"
        case didCompleteOnboarding = "did_complete_onboarding"
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "user_\(CodingKeys.userId.rawValue)": userId,
            "user_\(CodingKeys.email.rawValue)": email,
            "user_\(CodingKeys.isAnonymous.rawValue)": isAnonymous,
            "user_\(CodingKeys.authProviders.rawValue)": authProviders?.sorted().joined(separator: ", "),
            "user_\(CodingKeys.displayName.rawValue)": displayName,
            "user_\(CodingKeys.firstName.rawValue)": firstName,
            "user_\(CodingKeys.lastName.rawValue)": lastName,
            "user_name_calculated": nameCalculated,
            "user_\(CodingKeys.phoneNumber.rawValue)": phoneNumber,
            "user_\(CodingKeys.photoURL.rawValue)": photoURL,
            "user_\(CodingKeys.creationDate.rawValue)": creationDate,
            "user_\(CodingKeys.creationVersion.rawValue)": creationVersion,
            "user_\(CodingKeys.lastSignInDate.rawValue)": lastSignInDate,
            "user_\(CodingKeys.didCompleteOnboarding.rawValue)": didCompleteOnboarding
        ]
        return dict.compactMapValues({ $0 })
    }
    
    var nameCalculated: String? {
        if let displayName {
            return displayName
        }
        
        if let firstName, let lastName {
            return firstName + " " + lastName
        } else if let firstName {
            return firstName
        }
        
        return lastName
    }
    
    mutating func markDidCompleteOnboarding() {
        didCompleteOnboarding = true
    }
    
    static var mock: Self {
        mocks[0]
    }
    
    static var mocks: [Self] {
        let now = Date()
        return [
            UserModel(
                userId: "user1",
                creationDate: now,
                didCompleteOnboarding: true
            ),
            UserModel(
                userId: "user2",
                creationDate: now.addingTimeInterval(days: -1),
                didCompleteOnboarding: false
            ),
            UserModel(
                userId: "user3",
                creationDate: now.addingTimeInterval(days: -3, hours: -2),
                didCompleteOnboarding: true
            ),
            UserModel(
                userId: "user4",
                creationDate: now.addingTimeInterval(days: -5, hours: -4),
                didCompleteOnboarding: nil
            )
        ]
    }
}
