//
//  LocalABTestService.swift
//  
//
//  
//
import SwiftUI

@MainActor
class LocalABTestService: ABTestService {
    
    @UserDefault(key: ActiveABTests.CodingKeys.boolTest.rawValue, startingValue: .random())
    private var boolTest: Bool
    
    @UserDefaultEnum(key: ActiveABTests.CodingKeys.enumTest.rawValue, startingValue: EnumTestOption.allCases.randomElement()!)
    private var enumTest: EnumTestOption

    var activeTests: ActiveABTests {
        ActiveABTests(
            boolTest: boolTest,
            enumTest: enumTest
        )
    }
    
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws {
        boolTest = updatedTests.boolTest
        enumTest = updatedTests.enumTest
    }
    
    func fetchUpdatedConfig() async throws -> ActiveABTests {
        activeTests
    }
}
