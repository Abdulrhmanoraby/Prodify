//
//  Product.swift
//  Prodify
//
//  Created by abdulrhman urabi on 20/10/2025.
//
import Foundation

struct Product: Identifiable, Decodable {
    let id: Int
    let title: String
    let vendor: String?
    let image: ProductImage?
    let variants: [Variant]?

    struct ProductImage: Decodable {
        let src: String?
    }

    struct Variant: Decodable {
        let price: String?
    }
}

struct ProductsResponse: Decodable {
    let products: [Product]
}

