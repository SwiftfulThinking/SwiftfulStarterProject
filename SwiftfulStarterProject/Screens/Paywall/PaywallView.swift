//
//  PaywallView.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 11/1/24.
//

import SwiftUI

struct PaywallView: View {
    
    @State var presenter: PaywallPresenter

    var body: some View {
        ZStack {
            storeKitPaywall
            //customPaywall
        }
        .screenAppearAnalytics(name: "Paywall")
        .task {
            await presenter.onLoadProducts()
        }
    }
    
    private var storeKitPaywall: some View {
        StoreKitPaywallView(
            productIds: presenter.productIds,
            onInAppPurchaseStart: presenter.onPurchaseStart,
            onInAppPurchaseCompletion: { (product, result) in
                presenter.onPurchaseComplete(product: product, result: result)
            }
        )
    }
    
    @ViewBuilder
    private var customPaywall: some View {
        if presenter.products.isEmpty {
            ProgressView()
        } else {
            CustomPaywallView(
                products: presenter.products,
                onBackButtonPressed: {
                    presenter.onBackButtonPressed()
                },
                onRestorePurchasePressed: {
                    presenter.onRestorePurchasePressed()
                },
                onPurchaseProductPressed: { product in
                    presenter.onPurchaseProductPressed(product: product)
                }
            )
        }
    }
    
}

#Preview("Paywall") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    return RouterView { router in
        builder.paywallView(router: router)
    }
    .previewEnvironment()
}


extension CoreBuilder {
    
    func paywallView(router: Router) -> some View {
        PaywallView(
            presenter: PaywallPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }

}

extension CoreRouter {
    
    func showPaywallView() {
        router.showScreen(.sheet) { router in
            builder.paywallView(router: router)
        }
    }

}
