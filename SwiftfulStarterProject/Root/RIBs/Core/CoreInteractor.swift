import SwiftUI

@MainActor
struct CoreInteractor: GlobalInteractor {
    private let authManager: AuthManager
    private let userManager: UserManager
    private let logManager: LogManager
    private let abTestManager: ABTestManager
    private let purchaseManager: PurchaseManager
    private let appState: AppState
    private let pushManager: PushManager
    private let hapticManager: HapticManager
    private let soundEffectManager: SoundEffectManager

    init(container: DependencyContainer) {
        self.authManager = container.resolve(AuthManager.self)!
        self.userManager = container.resolve(UserManager.self)!
        self.logManager = container.resolve(LogManager.self)!
        self.abTestManager = container.resolve(ABTestManager.self)!
        self.purchaseManager = container.resolve(PurchaseManager.self)!
        self.appState = container.resolve(AppState.self)!
        self.pushManager = container.resolve(PushManager.self)!
        self.hapticManager = container.resolve(HapticManager.self)!
        self.soundEffectManager = container.resolve(SoundEffectManager.self)!
    }
    
    // MARK: AppState
        
    func updateAppState(showTabBarView: Bool) {
        appState.updateViewState(showTabBarView: showTabBarView)
    }
    
    var showTabBar: Bool {
        appState.showTabBar
    }

    // MARK: AuthManager
    
    var auth: UserAuthInfo? {
        authManager.auth
    }
    
    func getAuthId() throws -> String {
        try authManager.getAuthId()
    }
    
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await authManager.signInAnonymously()
    }

    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await authManager.signInApple()
    }
    
    func signInGoogle() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        guard let clientId = Constants.firebaseAppClientId else {
            throw AppError("Firebase not configured or clientID missing")
        }
        return try await authManager.signInGoogle(GIDClientID: clientId)
    }
    
    // MARK: UserManager
    
    var currentUser: UserModel? {
        userManager.currentUser
    }
    
    func getUser(userId: String) async throws -> UserModel {
        try await userManager.getUser(userId: userId)
    }
    
    func saveOnboardingComplete() async throws {
        try await userManager.saveOnboardingCompleteForCurrentUser()
    }
    
    func saveUserName(name: String) async throws {
        try await userManager.saveUserName(name: name)
    }
    
    func saveUserEmail(email: String) async throws {
        try await userManager.saveUserEmail(email: email)
    }
    
    func saveUserProfileImage(image: UIImage) async throws {
        try await userManager.saveUserProfileImage(image: image)
    }
    
    func saveUserFCMToken(token: String) async throws {
        try await userManager.saveUserFCMToken(token: token)
    }

    // MARK: LogManager
    
    func identifyUser(userId: String, name: String?, email: String?) {
        logManager.identifyUser(userId: userId, name: name, email: email)
    }
    
    func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
        logManager.addUserProperties(dict: dict, isHighPriority: isHighPriority)
    }
    
    func deleteUserProfile() {
        logManager.deleteUserProfile()
    }
    
    func trackEvent(eventName: String, parameters: [String: Any]? = nil, type: LogType = .analytic) {
        logManager.trackEvent(eventName: eventName, parameters: parameters, type: type)
    }
    
    func trackEvent(event: AnyLoggableEvent) {
        logManager.trackEvent(event: event)
    }

    func trackEvent(event: LoggableEvent) {
        logManager.trackEvent(event: event)
    }
    
    func trackScreenEvent(event: LoggableEvent) {
        logManager.trackEvent(event: event)
    }

    // MARK: PushManager
    
    func requestPushAuthorization() async throws -> Bool {
        try await pushManager.requestAuthorization()
    }
    
    func canRequestPushAuthorization() async -> Bool {
        await pushManager.canRequestAuthorization()
    }

    // MARK: ABTestManager
    
    var activeTests: ActiveABTests {
        abTestManager.activeTests
    }
        
    func override(updateTests: ActiveABTests) throws {
        try abTestManager.override(updateTests: updateTests)
    }
    
    // MARK: PurchaseManager
    
    var entitlements: [PurchasedEntitlement] {
        purchaseManager.entitlements
    }
    
    var isPremium: Bool {
        entitlements.hasActiveEntitlement
    }
    
    func getProducts(productIds: [String]) async throws -> [AnyProduct] {
        try await purchaseManager.getProducts(productIds: productIds)
    }
    
    func restorePurchase() async throws -> [PurchasedEntitlement] {
        try await purchaseManager.restorePurchase()
    }
    
    func purchaseProduct(productId: String) async throws -> [PurchasedEntitlement] {
        try await purchaseManager.purchaseProduct(productId: productId)
    }
    
    func updateProfileAttributes(attributes: PurchaseProfileAttributes) async throws {
        try await purchaseManager.updateProfileAttributes(attributes: attributes)
    }
    
    // MARK: Haptics
    
    func prepareHaptic(option: HapticOption) {
        Task {
            await hapticManager.prepare(option: option)
        }
    }
        
    func playHaptic(option: HapticOption) {
        Task {
            await hapticManager.play(option: option)
        }
    }
    
    func tearDownHaptic(option: HapticOption) {
        Task {
            await hapticManager.tearDown(option: option)
        }
    }
    
    // MARK: Sound Effects
    
    func prepareSoundEffect(sound: SoundEffectFile, simultaneousPlayers: Int = 1) {
        Task {
            await soundEffectManager.prepare(url: sound.url, simultaneousPlayers: simultaneousPlayers, volume: 1)
        }
    }
    
    func tearDownSoundEffect(sound: SoundEffectFile) {
        Task {
            await soundEffectManager.tearDown(url: sound.url)
        }
    }
    
    func playSoundEffect(sound: SoundEffectFile) {
        Task {
            await soundEffectManager.play(url: sound.url)
        }
    }
    
    // MARK: SHARED
    
    func logIn(user: UserAuthInfo, isNewUser: Bool) async throws {
        try await userManager.logIn(auth: user, isNewUser: isNewUser)
        try await purchaseManager.logIn(
            userId: user.uid,
            userAttributes: PurchaseProfileAttributes(
                email: user.email,
                mixpanelDistinctId: Constants.mixpanelDistinctId,
                firebaseAppInstanceId: Constants.firebaseAnalyticsAppInstanceID
            )
        )
    }
    
    func signOut() async throws {
        try authManager.signOut()
        try await purchaseManager.logOut()
        userManager.signOut()
    }
    
    func deleteAccount() async throws {
        _ = try authManager.getAuthId()
        try await userManager.deleteCurrentUser()
        try await authManager.deleteAccount()
        try await purchaseManager.logOut()
        logManager.deleteUserProfile()
    }

}
