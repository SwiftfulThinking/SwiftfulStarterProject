//
//  PaywallInteractor.swift
//  
//
//  
//

@MainActor
protocol PaywallInteractor: GlobalInteractor {
    func getProducts(productIds: [String]) async throws -> [AnyProduct]
    func restorePurchase() async throws -> [PurchasedEntitlement]
    func purchaseProduct(productId: String) async throws -> [PurchasedEntitlement]
}

extension CoreInteractor: PaywallInteractor { }
