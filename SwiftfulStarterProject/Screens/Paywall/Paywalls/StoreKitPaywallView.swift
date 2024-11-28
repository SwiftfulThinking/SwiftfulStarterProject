//
//  StoreKitPaywallView.swift
//  
//
//  
//
import SwiftUI
import StoreKit

struct StoreKitPaywallView: View {
    
    var productIds: [String] = EntitlementOption.allProductIds
    var onInAppPurchaseStart: ((Product) async -> Void)?
    var onInAppPurchaseCompletion: ((Product, Result<Product.PurchaseResult, any Error>) async -> Void)?
    
    var body: some View {
        SubscriptionStoreView(productIDs: productIds) {
            VStack(spacing: 8) {
                Text("My App 🤙")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                
                Text("Get premium access to unlock all features.")
                    .font(.subheadline)
            }
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .containerBackground(Color.accent.gradient, for: .subscriptionStore)
        }
        .storeButton(.visible, for: .restorePurchases)
        .subscriptionStoreControlStyle(.prominentPicker)
        .onInAppPurchaseStart(perform: onInAppPurchaseStart)
        .onInAppPurchaseCompletion(perform: onInAppPurchaseCompletion)
    }
}

#Preview {
    StoreKitPaywallView(
        onInAppPurchaseStart: nil,
        onInAppPurchaseCompletion: nil
    )
}
