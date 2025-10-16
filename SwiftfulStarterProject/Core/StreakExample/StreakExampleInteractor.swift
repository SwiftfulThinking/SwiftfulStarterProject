import SwiftUI

@MainActor
protocol StreakExampleInteractor: GlobalInteractor {
    var currentStreakData: CurrentStreakData { get }
    @discardableResult func addStreakEvent(metadata: [String: GamificationDictionaryValue]) async throws -> StreakEvent
    @discardableResult func addStreakFreeze(id: String, dateExpires: Date?) async throws -> StreakFreeze
    func useStreakFreezes() async throws
}

extension CoreInteractor: StreakExampleInteractor { } 
