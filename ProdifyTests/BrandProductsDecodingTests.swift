//
//  BrandProductsDecodingTests.swift
//  Prodify
//
//  Created by abdulrhman urabi on 02/11/2025.
//

import XCTest
@testable import Prodify

final class BrandProductsDecodingTests: XCTestCase {
    func testBrandProductsResponse_decodesCorrectly() throws {
        let json = """
        {
            "products": [
                {
                    "id": 101,
                    "title": "Nike Air Zoom",
                    "vendor": "Nike",
                    "product_type": "Shoes",
                    "image": { "src": "https://cdn.example.com/nike.jpg" },
                    "variants": [ { "price": "150.0" } ]
                },
                {
                    "id": 102,
                    "title": "Nike Shorts",
                    "vendor": "Nike",
                    "product_type": "Clothing",
                    "image": { "src": "https://cdn.example.com/shorts.jpg" },
                    "variants": [ { "price": "50.0" } ]
                }
            ]
        }
        """.data(using: .utf8)!
        
        let decoded = try JSONDecoder().decode(ProductsResponse.self, from: json)
        
        XCTAssertEqual(decoded.products.count, 2)
        XCTAssertEqual(decoded.products.first?.vendor, "Nike")
        XCTAssertEqual(decoded.products.first?.variants?.first?.price, "150.0")
    }
}
