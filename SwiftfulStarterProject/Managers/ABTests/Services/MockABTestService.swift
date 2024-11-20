//
//  MockABTestService.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 10/31/24.
//
import SwiftUI

@MainActor
class MockABTestService: ABTestService {
    
    var activeTests: ActiveABTests

    init(
        boolTest: Bool? = nil,
        enumTest: EnumTestOption? = nil
    ) {
        self.activeTests = ActiveABTests(
            boolTest: boolTest ?? false,
            enumTest: enumTest ?? .default
        )
    }
    
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws {
        activeTests = updatedTests
    }
    
    func fetchUpdatedConfig() async throws -> ActiveABTests {
        activeTests
    }
}
