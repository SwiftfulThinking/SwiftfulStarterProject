import SwiftUI

@MainActor
protocol TabBarInteractor: GlobalInteractor {
    var auth: UserAuthInfo? { get }
    var shouldPromptForReauthentication: Bool { get }
    var reauthPromptDeclineCount: Int { get }
    var reauthPromptMarkerSource: RealAccountMarkerSource? { get }
    var reauthPromptPolicy: ReauthPromptPolicy { get }
    var lastSignInProvider: AuthProviderOption? { get }
    func recordReauthPromptDeclined()
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func logIn(user: UserAuthInfo, isNewUser: Bool) async throws
    func signOut() async throws
}

extension CoreInteractor: TabBarInteractor { }
