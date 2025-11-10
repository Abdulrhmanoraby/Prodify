//
//  Product.swift
//  Prodify
//
//  Created by abdulrhman urabi on 20/10/2025.
//
import Foundation

struct Product: Identifiable, Codable {
    let id: Int?
    let title: String
    let vendor: String?
    let image: ProductImage?
    let variants: [Variant]?
    let product_type : String?
    let body_html: String?
    var categoryID: Int? 
    struct ProductImage: Codable {
        let src: String?
    }

    struct Variant: Codable {
        let price: String?
    }
}

struct ProductsResponse: Codable{
    let products: [Product]
}






