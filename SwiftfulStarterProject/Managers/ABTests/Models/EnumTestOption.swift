//
//  CategoryRowTestOption.swift
//  
//
//  
//
import SwiftUI

enum EnumTestOption: String, Codable, CaseIterable {
    case alpha, beta
    
    static var `default`: Self {
        .alpha
    }
}
