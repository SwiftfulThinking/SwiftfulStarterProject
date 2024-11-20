//
//  CategoryRowTestOption.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 10/31/24.
//
import SwiftUI

enum EnumTestOption: String, Codable, CaseIterable {
    case alpha, beta
    
    static var `default`: Self {
        .alpha
    }
}
