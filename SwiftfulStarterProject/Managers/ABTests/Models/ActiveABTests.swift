//
//  ActiveABTests.swift
//  
//
//  
//
import SwiftUI

struct ActiveABTests: Codable {
    
    private(set) var boolTest: Bool
    private(set) var enumTest: EnumTestOption

    init(
        boolTest: Bool,
        enumTest: EnumTestOption
    ) {
        self.boolTest = boolTest
        self.enumTest = enumTest
    }
    
    enum CodingKeys: String, CodingKey {
        case boolTest = "_202411_BoolTest"
        case enumTest = "_202411_EnumTest"
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "test\(CodingKeys.boolTest.rawValue)": boolTest,
            "test\(CodingKeys.enumTest.rawValue)": enumTest.rawValue
        ]
        return dict.compactMapValues({ $0 })
    }
    
    mutating func update(boolTest newValue: Bool) {
        boolTest = newValue
    }
    
    mutating func update(enumTest newValue: EnumTestOption) {
        enumTest = newValue
    }
}

// MARK: REMOTE CONFIG

import FirebaseRemoteConfig

extension ActiveABTests {
    
    init(config: RemoteConfig) {
        let boolTest = config.configValue(forKey: ActiveABTests.CodingKeys.boolTest.rawValue).boolValue
        self.boolTest = boolTest
        
        let enumTestStringValue = config.configValue(forKey: ActiveABTests.CodingKeys.enumTest.rawValue).stringValue
        if let option = EnumTestOption(rawValue: enumTestStringValue) {
            self.enumTest = option
        } else {
            self.enumTest = .default
        }
    }
    
    // Converted to a NSObject dictionary to setDefaults within FirebaseABTestService
    var asNSObjectDictionary: [String: NSObject]? {
        [
            CodingKeys.boolTest.rawValue: boolTest as NSObject,
            CodingKeys.enumTest.rawValue: enumTest.rawValue as NSObject
        ]
    }
}
