//
//  File.swift
//  Prodify
//
//  Created by Alaa Muhamed on 03/11/2025.
//

import Foundation
import SwiftData

@Model
final class FavoriteProduct: Identifiable {
    @Attribute(.unique) var productId: Int64
    var title: String
    var vendor: String?
    var imageURL: String?
    var price: String?
    var bodyHTML: String?

    init(productId: Int64,
         title: String,
         vendor: String? = nil,
         imageURL: String? = nil,
         price: String? = nil,
         bodyHTML: String? = nil) {
        self.productId = productId
        self.title = title
        self.vendor = vendor
        self.imageURL = imageURL
        self.price = price
        self.bodyHTML = bodyHTML
    }
}
