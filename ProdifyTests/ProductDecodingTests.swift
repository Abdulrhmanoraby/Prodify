//
//  ProductDecodingTests.swift
//  Prodify
//
//  Created by abdulrhman urabi on 02/11/2025.
//

import XCTest
@testable import Prodify

final class ProductDecodingTests: XCTestCase {
    func testProductDecoding_fromSampleJSON_decodesCorrectly() throws {
        let json = """
        {
          "id": 1001,
          "title": "Air Max 270",
          "vendor": "Nike",
          "product_type": "Shoes",
          "body_html": "<p>Lightweight shoe</p>",
          "image": { "src": "https://cdn.example.com/image1.jpg" },
          "variants": [ { "price": "129.99" } ]
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let product = try decoder.decode(Product.self, from: json)

        XCTAssertEqual(product.id, 1001)
        XCTAssertEqual(product.title, "Air Max 270")
        XCTAssertEqual(product.vendor, "Nike")
        XCTAssertEqual(product.product_type, "Shoes")
        XCTAssertEqual(product.image?.src, "https://cdn.example.com/image1.jpg")
        XCTAssertEqual(product.variants?.first?.price, "129.99")
        XCTAssertEqual(product.body_html?.trimmingCharacters(in: .whitespacesAndNewlines), "<p>Lightweight shoe</p>")
    }
}
