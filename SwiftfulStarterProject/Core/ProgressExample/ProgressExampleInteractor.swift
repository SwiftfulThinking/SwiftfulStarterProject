import SwiftUI

@MainActor
protocol ProgressExampleInteractor: GlobalInteractor {
    func getAllProgress() -> [String: Double]
    func getAllProgressItems() -> [ProgressItem]
    @discardableResult func addProgress(id: String, value: Double, metadata: [String: GamificationDictionaryValue]?) async throws -> ProgressItem
    func deleteProgress(id: String) async throws
    func deleteAllProgress() async throws
}

extension CoreInteractor: ProgressExampleInteractor { }
