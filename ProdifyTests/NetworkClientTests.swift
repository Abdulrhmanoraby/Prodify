//
//  NetworkClientTests.swift
//  ProdifyTests
//
//  Created by abdulrhman urabi on 02/11/2025.
//

import XCTest
@testable import Prodify
final class NetworkClientTests: XCTestCase {
    

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
        
    }
    func testFetchCategories_returnsCollections() async throws {
          // GIVEN: The collections (categories) endpoint
          let url = URL(string: "https://iosr2g3.myshopify.com/admin/api/2025-07/custom_collections.json")!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(Constants.adminApiAccessToken, forHTTPHeaderField: "X-Shopify-Access-Token")

        let (data, response) = try await URLSession.shared.data(for: request)
          let http = response as? HTTPURLResponse

          // THEN
          XCTAssertEqual(http?.statusCode, 200, "Shopify API should return 200 OK")
          
          let decoded = try JSONDecoder().decode(CategoryResponse.self, from: data)
          XCTAssertGreaterThan(decoded.custom_collections.count, 0, "Expected non-empty categories")
      }
    func testFetchProductsByVendor_returnsProducts() async throws {
        
        let vendor = "Nike"
        let url = URL(string: "https://iosr2g3.myshopify.com/admin/api/2025-07/products.json?vendor=\(vendor)")!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(Constants.adminApiAccessToken, forHTTPHeaderField: "X-Shopify-Access-Token")

        
        let (data, response) = try await URLSession.shared.data(for: request)
        let http = response as? HTTPURLResponse
        XCTAssertEqual(http?.statusCode, 200, "Should return 200 OK")

        let decoded = try JSONDecoder().decode(ProductsResponse.self, from: data)
        XCTAssertNotNil(decoded.products.first, "Expected at least one product for vendor: \(vendor)")
    }

 

}
