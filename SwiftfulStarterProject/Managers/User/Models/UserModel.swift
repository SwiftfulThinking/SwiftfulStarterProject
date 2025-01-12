//
//  UserModel.swift
//  
//
//  
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
    let fcmToken: String?
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
        fcmToken: String? = nil,
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
        self.fcmToken = fcmToken
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
        case fcmToken = "fcm_token"
        case didCompleteOnboarding = "did_complete_onboarding"
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "user_\(CodingKeys.userId.rawValue)": userId,
            "user_\(CodingKeys.email.rawValue)": email,
            "user_\(CodingKeys.isAnonymous.rawValue)": isAnonymous,
            "user_\(CodingKeys.authProviders.rawValue)": authProviders?.sorted().joined(separator: ", "),
            "user_\(CodingKeys.displayName.rawValue)": displayNameCalculated,
            "user_\(CodingKeys.firstName.rawValue)": firstNameCalculated,
            "user_\(CodingKeys.lastName.rawValue)": lastNameCalculated,
            "user_common_name_calc": commonNameCalculated,
            "user_full_name_calc": fullNameCalculated,
            "user_\(CodingKeys.phoneNumber.rawValue)": phoneNumber,
            "user_\(CodingKeys.photoURL.rawValue)": photoURL,
            "user_\(CodingKeys.creationDate.rawValue)": creationDate,
            "user_\(CodingKeys.creationVersion.rawValue)": creationVersion,
            "user_\(CodingKeys.lastSignInDate.rawValue)": lastSignInDate,
            "user_has_\(CodingKeys.fcmToken.rawValue)": (fcmToken?.count ?? 0) > 0,
            "user_\(CodingKeys.didCompleteOnboarding.rawValue)": didCompleteOnboarding
        ]
        return dict.compactMapValues({ $0 })
    }
    
    var firstNameCalculated: String? {
        guard let firstName, !firstName.isEmpty else { return nil }
        return firstName
    }
    
    var lastNameCalculated: String? {
        guard let lastName, !lastName.isEmpty else { return nil }
        return lastName
    }
    
    var displayNameCalculated: String? {
        guard let displayName, !displayName.isEmpty else { return nil }
        return displayName
    }
    
    var fullNameCalculated: String? {
        if let firstNameCalculated, let lastNameCalculated {
            return firstNameCalculated + " " + lastNameCalculated
        } else if let firstNameCalculated {
            return firstNameCalculated
        } else if let lastNameCalculated {
            return lastNameCalculated
        }
        return nil
    }
    
    var commonNameCalculated: String? {
        if let displayNameCalculated {
            return displayNameCalculated
        } else if let fullNameCalculated {
            return fullNameCalculated
        }
        return nil
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
