//
//  UserDefaultPropertyWrapper.swift
//  SwiftfulStarterProject
//
//  Created by Nick Sarno on 11/19/24.
//
import SwiftUI

protocol UserDefaultsCompatible { }
extension Bool: UserDefaultsCompatible { }
extension Int: UserDefaultsCompatible { }
extension Float: UserDefaultsCompatible { }
extension Double: UserDefaultsCompatible { }
extension String: UserDefaultsCompatible { }
extension URL: UserDefaultsCompatible { }

@propertyWrapper
struct UserDefault<Value: UserDefaultsCompatible> {
    private let key: String
    private let startingValue: Value
    
    init(key: String, startingValue: Value) {
        self.key = key
        self.startingValue = startingValue
    }
    
    var wrappedValue: Value {
        get {
            if let savedValue = UserDefaults.standard.value(forKey: key) as? Value {
                return savedValue
            } else {
                UserDefaults.standard.set(startingValue, forKey: key)
                return startingValue
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
struct UserDefaultEnum<T: RawRepresentable> where T.RawValue == String {
    private let key: String
    private let startingValue: T
    
    init(key: String, startingValue: T) {
        self.key = key
        self.startingValue = startingValue
    }
    
    var wrappedValue: T {
        get {
            if let savedString = UserDefaults.standard.string(forKey: key), let savedValue = T(rawValue: savedString) {
                return savedValue
            } else {
                UserDefaults.standard.set(startingValue.rawValue, forKey: key)
                return startingValue
            }
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: key)
        }
    }
}
