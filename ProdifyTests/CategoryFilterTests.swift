//
//  CategoryFilterTests.swift
//  Prodify
//
//  Created by abdulrhman urabi on 02/11/2025.
//

import XCTest
@testable import Prodify

final class CategoryFilterTests: XCTestCase {
    func testFilter_removesHomePageCategory() {
        let categories = [
            Category(id: 1, title: "HomePage", image: nil),
            Category(id: 2, title: "Shoes", image: nil),
            Category(id: 3, title: "Bags", image: nil)
        ]
        
        
        let filtered = categories.filter { $0.title.lowercased() != "homepage" }
        
        XCTAssertEqual(filtered.count, 2)
        XCTAssertFalse(filtered.contains { $0.title == "HomePage" })
        XCTAssertEqual(filtered.map(\.title), ["Shoes", "Bags"])
    }
}
