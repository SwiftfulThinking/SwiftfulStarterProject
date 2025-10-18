//
//  UserModel.swift
//  
//
//  
//
import Foundation
import SwiftUI
import IdentifiableByString
import SwiftfulDataManagers

public struct UserModel: StringIdentifiable, Codable, DMProtocol {
    public var id: String {
        userId
    }
    
    // These values come from user's Auth info
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
    
    // These values can be added by the user
    let submittedEmail: String?
    let submittedName: String?
    let submittedProfileImage: String?
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
        submittedEmail: String? = nil,
        submittedName: String? = nil,
        submittedProfileImage: String? = nil,
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
        self.submittedName = submittedName
        self.submittedEmail = submittedEmail
        self.submittedProfileImage = submittedProfileImage
        self.fcmToken = fcmToken
        self.didCompleteOnboarding = didCompleteOnboarding
    }
    
    public init(auth: UserAuthInfo, creationVersion: String?) {
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
        case submittedName = "submitted_name"
        case submittedEmail = "submitted_email"
        case submittedProfileImage = "submitted_profile_image"
        case fcmToken = "fcm_token"
        case didCompleteOnboarding = "did_complete_onboarding"
    }
    
    public var eventParameters: [String: Any] {
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
            "user_\(CodingKeys.submittedName.rawValue)": submittedName,
            "user_\(CodingKeys.submittedEmail.rawValue)": submittedEmail,
            "user_\(CodingKeys.submittedProfileImage.rawValue)": submittedProfileImage,
            "user_has_\(CodingKeys.fcmToken.rawValue)": (fcmToken?.count ?? 0) > 0,
            "user_\(CodingKeys.didCompleteOnboarding.rawValue)": didCompleteOnboarding
        ]
        return dict.compactMapValues({ $0 })
    }
    
    /// First name, per user's Auth info
    var firstNameCalculated: String? {
        guard let firstName, !firstName.isEmpty else { return nil }
        return firstName
    }
    
    /// Last name, per user's Auth info
    var lastNameCalculated: String? {
        guard let lastName, !lastName.isEmpty else { return nil }
        return lastName
    }
    
    /// Display name, per user's Auth info
    var displayNameCalculated: String? {
        guard let displayName, !displayName.isEmpty else { return nil }
        return displayName
    }
    
    /// Full name, per user's Auth info
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
    
    /// User's name that the user may have added manually
    var submittedNameCalculated: String? {
        guard let submittedName, !submittedName.isEmpty else { return nil }
        return submittedName
    }
    
    /// Try to get the "best" common name for the user (ie. their preferred first name). Use this most of the time.
    var commonNameCalculated: String? {
        if let submittedNameCalculated {
            return submittedNameCalculated
        } else if let displayNameCalculated {
            return displayNameCalculated
        } else if let firstNameCalculated {
            return firstNameCalculated
        }
        return nil
    }
    
    /// Try to get submitted profile image, otherwise user image from user's auth (if available).
    var profileImageNameCalculated: String? {
        if let submittedProfileImage {
            return submittedProfileImage
        } else if let photoURL {
            return photoURL
        }
        return nil
    }
    
    /// Try to get submitted email, otherwise user email from user's auth (if available).
    var emailCalculated: String? {
        if let submittedEmail {
            return submittedEmail
        } else if let email {
            return email
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
