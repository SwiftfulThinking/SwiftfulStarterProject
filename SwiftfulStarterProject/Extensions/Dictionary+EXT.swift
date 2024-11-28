//
//  Dictionary+EXT.swift
//  
//
//  
//
import Foundation

extension Dictionary where Key == String, Value == Any {
    
    var asAlphabeticalArray: [(key: String, value: Any)] {
        self.map({ (key: $0, value: $1) }).sortedByKeyPath(keyPath: \.key)
    }
}

extension Dictionary where Key == String {
    
    mutating func first(upTo maxItems: Int) {
        var counter: Int = 0
        for (key, _) in self {
            if counter >= maxItems {
                removeValue(forKey: key)
            } else {
                counter += 1
            }
        }
    }
}

extension Dictionary {
    
    mutating func merge(_ other: Dictionary?, conflictTakeExisting: Bool = true) {
        if let other {
            self.merge(other, uniquingKeysWith: { (existing, new) in
                return conflictTakeExisting ? existing : new
            })
        }
    }
    
}
