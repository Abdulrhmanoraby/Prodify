//
//  Constants.swift
//  Prodify
//
//  Created by abdulrhman urabi on 20/10/2025.
//

import Foundation


enum Constants {
    // MARK: - Shopify Configuration

    static let shopDomain = "iosr2g3.myshopify.com"

    // Read secrets securely from environment variables
    static let storeFrontAccessToken = ProcessInfo.processInfo.environment["SHOPIFY_STOREFRONT_TOKEN"] ?? ""
    static let adminApiAccessToken   = ProcessInfo.processInfo.environment["SHOPIFY_ADMIN_TOKEN"] ?? ""
    static let apiKey                = ProcessInfo.processInfo.environment["SHOPIFY_API_KEY"] ?? ""
    static let apiSecretKey          = ProcessInfo.processInfo.environment["SHOPIFY_SECRET_KEY"] ?? ""
    

    // MARK: - URLs

    static var storeFrontGraphQLEndpoint: URL {
        URL(string: "https://\(shopDomain)/api/2025-07/graphql.json")!
    }

    static let adminAPIVersion = "2025-07"

    static var baseAdminURL: String {
        "https://\(shopDomain)/admin/api/\(adminAPIVersion)"
    }

    // MARK: - UI Configuration
    static let mainAccentColorHex = "#2B6CF3"
}



