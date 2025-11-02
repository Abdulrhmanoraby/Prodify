//
//  CartItem.swift
//  Prodify
//
//  Created by abdulrhman urabi on 20/10/2025.
//

import Foundation
struct CartItem: Codable, Identifiable {
    let id: Int
    let title: String
    let price: Double
    var quantity: Int
    let imageURL: String?
}
