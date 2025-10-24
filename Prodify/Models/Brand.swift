//
//  Brand.swift
//  Prodify
//
//  Created by abdulrhman urabi on 22/10/2025.
//
import Foundation

struct Brand: Identifiable, Decodable {
    let id: Int
    let title: String
    let image: BrandImage?

    struct BrandImage: Decodable {
        let src: String?
    }
}

struct BrandsResponse: Decodable {
    let custom_collections: [Brand]
}
