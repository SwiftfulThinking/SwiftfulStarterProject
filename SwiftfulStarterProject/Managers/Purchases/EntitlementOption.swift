//
//  EntitlementOption.swift
//  
//
//  
//

enum EntitlementOption: Codable, CaseIterable {
    case yearly
    
    var productId: String {
        switch self {
        case .yearly:
            return "organization.app.yearly"
        }
    }
    
    static var allProductIds: [String] {
        EntitlementOption.allCases.map({ $0.productId })
    }
}
