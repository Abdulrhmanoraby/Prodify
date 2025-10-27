//
//  Category.swift
//  Prodify
//
//  Created by abdulrhman urabi on 20/10/2025.
//

import Foundation

struct CategoryResponse: Codable{
    let custom_collections : [Category]
}
struct Category: Codable, Identifiable,Hashable {
    let id: Int
    let title: String
    let image: CategoryImage?
}
struct CategoryImage: Codable, Hashable{
    let src: String?
}
