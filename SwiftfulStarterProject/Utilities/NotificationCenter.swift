//
//  NotificationCenter.swift
//  SwiftfulStarterProject
//
//  Created by Nick Sarno on 1/11/25.
//
import NotificationCenter

// We can use NotificationCenter to send notifications within the codebase.
// These are usually "anti-pattern" and "anti-architecture"
// But are an easy solution for scenarios where two parts of the codebase are not otherwise connected
//
// 1. Create a custom Notification.Name
// 2. Trigger notification with .post()
// 3. Recieve notification with .onNotificationRecieved() (must be connected before notification triggers)

extension Notification.Name {
    
    /// Notification for updated Firebase Cloud Messaging Token.
    static let fcmToken = Notification.Name("FCMToken")
    
    /// Notification for when app is opened from a Push Notification
    static let pushNotification = Notification.Name("PushNotification")
}

// The below code, postFCMToken + getFCMToken are examples of this.
// We do not need to create these extensions every time and can access NotificationCenter.default.post directly.
// The extension is for convenience.

extension NotificationCenter {
    
    struct FCMKeys {
        static let token = "token"
    }
    
    /// Send notification with new token
    func postFCMToken(token: String) {
        let userInfo: [String: String] = [FCMKeys.token: token]
        self.post(name: .fcmToken, object: nil, userInfo: userInfo)
    }
    
    /// Recieve notification and unwrap data to get new token from payload
    func getFCMToken(notification: Notification) -> String? {
        guard
            let userInfo = notification.userInfo as? [String: String],
            let token = userInfo[FCMKeys.token] else {
            return nil
        }
        
        return token
    }
}
