//
//  ShopifyService.swift
//  Prodify
//
//  Created by abdulrhman urabi on 20/10/2025.
//

import Foundation

final class ShopifyService {
    static let shared = ShopifyService()
    private init() {}

    func fetchBrands() async throws -> [Brand] {
        let url = "\(Constants.baseAdminURL)/custom_collections.json"
        let response: BrandsResponse = try await NetworkClient.shared.get(url, type: BrandsResponse.self)
        return response.custom_collections
    }

    func fetchProducts(for collectionID: Int) async throws -> [Product] {
        // Step 1: Get collects
        let collectsURL = "\(Constants.baseAdminURL)/collects.json?collection_id=\(collectionID)"
        struct CollectsResponse: Decodable { let collects: [Collect] }
        struct Collect: Decodable { let product_id: Int }
        let collectsResponse: CollectsResponse = try await NetworkClient.shared.get(collectsURL, type: CollectsResponse.self)

        let productIDs = collectsResponse.collects.map { String($0.product_id) }
        guard !productIDs.isEmpty else { return [] }

        // Step 2: Fetch products by IDs
        let idsString = productIDs.joined(separator: ",")
        let productsURL = "\(Constants.baseAdminURL)/products.json?ids=\(idsString)"
        let response: ProductsResponse = try await NetworkClient.shared.get(productsURL, type: ProductsResponse.self)
        return response.products
    }

    func fetchAllProducts(limit: Int = 8) async throws -> [Product] {
        let url = "\(Constants.baseAdminURL)/products.json?limit=\(limit)"
        let response: ProductsResponse = try await NetworkClient.shared.get(url, type: ProductsResponse.self)
        return response.products
    }
    func fetchVendors() async throws -> [String] {
        let url = "\(Constants.baseAdminURL)/products.json?limit=250"
        let response: ProductsResponse = try await NetworkClient.shared.get(url, type: ProductsResponse.self)

        // Extract unique vendor names from products
        let vendors = Set(response.products.compactMap { $0.vendor })
        return Array(vendors).sorted()
    }
    func fetchProducts(byVendor vendor: String) async throws -> [Product] {
        let encodedVendor = vendor.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? vendor
        let url = "\(Constants.baseAdminURL)/products.json?vendor=\(encodedVendor)"
        let response: ProductsResponse = try await NetworkClient.shared.get(url, type: ProductsResponse.self)
        return response.products
    }
}

