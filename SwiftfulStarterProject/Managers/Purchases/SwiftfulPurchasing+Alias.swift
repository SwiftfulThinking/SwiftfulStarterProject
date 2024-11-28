//
//  SwiftfulPurchasing+Alias.swift
//  SwiftfulStarterProject
//
//  
//
import SwiftfulPurchasing
import SwiftfulPurchasingRevenueCat

typealias PurchaseManager = SwiftfulPurchasing.PurchaseManager
typealias PurchaseProfileAttributes = SwiftfulPurchasing.PurchaseProfileAttributes
typealias PurchasedEntitlement = SwiftfulPurchasing.PurchasedEntitlement
typealias AnyProduct = SwiftfulPurchasing.AnyProduct
typealias MockPurchaseService = SwiftfulPurchasing.MockPurchaseService
typealias StoreKitPurchaseService = SwiftfulPurchasing.StoreKitPurchaseService
typealias RevenueCatPurchaseService = SwiftfulPurchasingRevenueCat.RevenueCatPurchaseService

extension PurchaseLogType {
    
    var type: LogType {
        switch self {
        case .info:
            return .info
        case .analytic:
            return .analytic
        case .warning:
            return .warning
        case .severe:
            return .severe
        }
    }
    
}
extension LogManager: @retroactive PurchaseLogger {
    
    public func trackEvent(event: any PurchaseLogEvent) {
        trackEvent(eventName: event.eventName, parameters: event.parameters, type: event.type.type)
    }
    
}
