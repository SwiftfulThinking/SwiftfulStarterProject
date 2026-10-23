import SwiftUI
import SwiftfulUI

struct TabBarTab: Identifiable {
    var id: String {
        title
    }

    let title: String
    let systemImage: String
    let content: AnyView

    @MainActor
    init<T: View>(
        title: String,
        systemImage: String,
        destination: @escaping (AnyRouter) -> T
    ) {
        self.title = title
        self.systemImage = systemImage
        self.content = RouterView { router in
            destination(router)
        }
        .any()
    }
    
    var eventParameters: [String: Any] {
        [
            "tab_title": title,
            "tab_id": id,
            "tab_icon": systemImage
        ]
    }

    static func == (lhs: TabBarTab, rhs: TabBarTab) -> Bool {
        lhs.id == rhs.id
    }
}

@Observable
@MainActor
class TabBarPresenter {

    private let interactor: TabBarInteractor
    private let router: TabBarRouter

    var tabs: [TabBarTab]
    var selectedTab: String

    /// Observed by the view: a session lost mid-session (or blocked at launch) surfaces the prompt without a relaunch.
    var shouldPromptForReauthentication: Bool {
        interactor.shouldPromptForReauthentication
    }

    /// Guards the prompt against double presentation (foreground + appear) and lets the foreground
    /// trigger skip while it is already on screen.
    private var isReauthenticationPromptOnScreen = false
    private var lastReauthenticationPromptShownAt: Date?
    private var reauthSignInCreatedNewAccount = false

    init(interactor: TabBarInteractor, router: TabBarRouter, delegate: TabBarDelegate) {
        self.interactor = interactor
        self.router = router
        self.tabs = delegate.tabs
        self.selectedTab = delegate.startingTabId ?? ""
    }
    
    func onViewAppear(delegate: TabBarDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
        showReauthenticationPromptIfNeeded()
    }

    func onViewDisappear(delegate: TabBarDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }

    func onTabSelected(tabId: String, isSameTabTapped: Bool, delegate: TabBarDelegate) {
        guard let tab = tabs.first(where: { $0.id == tabId }) else { return }

        // Track analytics
        if isSameTabTapped {
            interactor.trackEvent(event: Event.tabReselected(tab: tab, delegate: delegate))
        } else {
            interactor.trackEvent(event: Event.tabSelected(tab: tab, delegate: delegate))
        }

        // Update selection
        selectedTab = tabId
    }

    // MARK: Re-authentication (lost sessions)

    func onReauthenticationNeeded() {
        showReauthenticationPromptIfNeeded()
    }

    /// Returning from background: re-check ONLY the re-auth prompt. We deliberately do NOT force a token refresh:
    /// if the cached session still works the user keeps using the app; this only surfaces a session that has
    /// already been revoked. The delay lets in-flight auth state settle first.
    func onAppWillEnterForeground() {
        Task {
            try? await Task.sleep(for: .seconds(0.5))
            showReauthenticationPromptIfNeeded()
        }
    }

    /// Re-auth is needed, isn't already on screen, and hasn't been shown within the re-prompt interval.
    private var shouldShowReauthenticationPrompt: Bool {
        guard interactor.shouldPromptForReauthentication, !isReauthenticationPromptOnScreen else { return false }
        guard let lastShown = lastReauthenticationPromptShownAt else { return true }
        return Date().timeIntervalSince(lastShown) > interactor.reauthPromptPolicy.foregroundRepromptInterval
    }

    private func showReauthenticationPromptIfNeeded() {
        guard shouldShowReauthenticationPrompt else { return }
        showReauthenticationPrompt()
    }

    /// Presents the sign-back-in prompt for a revoked session (see AuthManager.shouldPromptForReauthentication)
    /// using the existing create-account sheet. Sign-in runs the full existing pipeline (signIn -> logIn realigns
    /// purchases/user/gamification, and the marker write resets the decline budget).
    ///
    /// Dismissing without ending up on a real account = a decline: spend a strike AND, on the session-less prompt,
    /// mint the anonymous account the launch path skipped so the user is never interactively userless. Later prompts
    /// run over that same anonymous session (one junk account per loss episode). After the budget the prompting stops.
    private func showReauthenticationPrompt() {
        isReauthenticationPromptOnScreen = true
        lastReauthenticationPromptShownAt = Date()
        reauthSignInCreatedNewAccount = false
        interactor.trackEvent(event: Event.reauthPromptShown(declineCount: interactor.reauthPromptDeclineCount, markerSource: interactor.reauthPromptMarkerSource))

        let delegate = CreateAccountDelegate(
            title: "Sign back in",
            subtitle: reauthenticationPromptSubtitle,
            preferredProvider: interactor.lastSignInProvider,
            onDidSignIn: { [weak self] isNewUser in
                self?.reauthSignInCreatedNewAccount = isNewUser
            }
        )
        router.showCreateAccountView(delegate: delegate, onDismiss: { [weak self] in
            self?.handleReauthenticationPromptDismissed()
        })
    }

    private var reauthenticationPromptSubtitle: String {
        let method: String
        switch interactor.lastSignInProvider {
        case .apple:    method = "Sign in with Apple"
        case .google:   method = "Sign in with Google"
        default:        method = "the account you used before"
        }
        return "Your session expired. Use \(method) to keep your account and purchases."
    }

    /// The sheet was dismissed — fires for BOTH a decline (swipe) and a successful sign-in (CreateAccountPresenter
    /// awaits signIn + logIn before dismissing). We distinguish them by the LIVE session: a successful recovery
    /// already reads as a real account here. "Real account" (not merely signed in) because the post-decline prompts
    /// run over an ANONYMOUS session and dismissing those must still count as a decline.
    private func handleReauthenticationPromptDismissed() {
        isReauthenticationPromptOnScreen = false

        if let auth = interactor.auth, !auth.isAnonymous {
            if reauthSignInCreatedNewAccount {
                showReauthenticationNewAccountAlert()
            } else {
                interactor.trackEvent(event: Event.reauthPromptSignedIn)
            }
            return
        }

        interactor.recordReauthPromptDeclined()
        interactor.trackEvent(event: Event.reauthPromptDeclined(declineCount: interactor.reauthPromptDeclineCount))

        // Later prompts run over the anonymous account minted after the first decline — nothing to mint.
        guard interactor.auth == nil else { return }

        Task {
            do {
                let result = try await interactor.signInAnonymously()
                try await interactor.logIn(user: result.user, isNewUser: result.isNewUser)
                interactor.trackEvent(event: Event.reauthDeclineMintSuccess)
            } catch {
                interactor.trackEvent(event: Event.reauthDeclineMintFail(error: error))
            }
        }
    }

    /// The recovery sign-in CREATED a new account (wrong Google account, unlinked Apple ID, fresh Hide-My-Email)
    /// rather than recovering the existing one. Keep it, or sign out and retry with the right provider — a correct
    /// login rewrites the marker and moves purchases back onto the real account.
    private func onReauthenticationNewAccountRetryPressed() {
        interactor.trackEvent(event: Event.reauthNewAccountRetry)
        Task {
            try? await interactor.signOut()
            // Re-present regardless: a correct retry replaces the session even if sign-out failed.
            showReauthenticationPrompt()
        }
    }

    private func showReauthenticationNewAccountAlert() {
        interactor.trackEvent(event: Event.reauthNewAccountAlertShown)
        router.showAlert(
            .alert,
            title: "This is a new account",
            subtitle: "You signed in to an account that has no history here. Keep it, or sign out and try the account you used before.",
            buttons: { [weak self] in
                AnyView(
                    Group {
                        Button("Keep this account") {
                            self?.interactor.trackEvent(event: Event.reauthNewAccountKeep)
                        }
                        Button("Sign out and retry", role: .destructive) {
                            self?.onReauthenticationNewAccountRetryPressed()
                        }
                    }
                )
            }
        )
    }
}

extension TabBarPresenter {

    enum Event: LoggableEvent {
        case onAppear(delegate: TabBarDelegate)
        case onDisappear(delegate: TabBarDelegate)
        case tabSelected(tab: TabBarTab, delegate: TabBarDelegate)
        case tabReselected(tab: TabBarTab, delegate: TabBarDelegate)
        case reauthPromptShown(declineCount: Int, markerSource: RealAccountMarkerSource?)
        case reauthPromptSignedIn
        case reauthPromptDeclined(declineCount: Int)
        case reauthDeclineMintSuccess
        case reauthDeclineMintFail(error: Error)
        case reauthNewAccountAlertShown
        case reauthNewAccountKeep
        case reauthNewAccountRetry

        var eventName: String {
            switch self {
            case .onAppear:                 return "TabBarView_Appear"
            case .onDisappear:              return "TabBarView_Disappear"
            case .tabSelected:              return "TabBar_TabSelected"
            case .tabReselected:            return "TabBar_TabReselected"
            case .reauthPromptShown:        return "TabBar_ReauthPrompt_Shown"
            case .reauthPromptSignedIn:     return "TabBar_ReauthPrompt_SignedIn"
            case .reauthPromptDeclined:     return "TabBar_ReauthPrompt_Declined"
            case .reauthDeclineMintSuccess: return "TabBar_ReauthDeclineMint_Success"
            case .reauthDeclineMintFail:    return "TabBar_ReauthDeclineMint_Fail"
            case .reauthNewAccountAlertShown: return "TabBar_ReauthNewAccount_Shown"
            case .reauthNewAccountKeep:     return "TabBar_ReauthNewAccount_Keep"
            case .reauthNewAccountRetry:    return "TabBar_ReauthNewAccount_Retry"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .onAppear(delegate: let delegate), .onDisappear(delegate: let delegate):
                return delegate.eventParameters
            case .tabSelected(tab: let tab, delegate: let delegate), .tabReselected(tab: let tab, delegate: let delegate):
                var params = tab.eventParameters
                params.merge(delegate.eventParameters)
                return params
            case .reauthPromptShown(declineCount: let declineCount, markerSource: let markerSource):
                return ["decline_count": declineCount, "marker_source": markerSource?.rawValue ?? "none"]
            case .reauthPromptDeclined(declineCount: let declineCount):
                return ["decline_count": declineCount]
            case .reauthDeclineMintFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .reauthDeclineMintFail:
                return .severe
            default:
                return .analytic
            }
        }
    }

}
