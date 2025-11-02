//
//  CartService.swift
//  Prodify
//
//  Created by abdulrhman urabi on 20/10/2025.
//

import Foundation

actor CartService {
    static let shared = CartService()
    private init() {}
    
    private var items: [CartItem] = []
    
    // MARK: - Fetch Cart
    func fetchCart() async -> [CartItem] {
        return items
    }
    
    // MARK: - Add to Cart
    func addToCart(product: Product) async {
        if let index = items.firstIndex(where: { $0.id == product.id }) {
            var updated = items[index]
            updated.quantity += 1
            items[index] = updated
        } else {
            let item = CartItem(
                id: product.id ?? 0,
                title: product.title,
                price: Double(product.variants?.first?.price ?? "0") ?? 0,
                quantity: 1,
                imageURL: product.image?.src
            )
            items.append(item)
        }
    }
    
    // MARK: - Remove from Cart
    func removeFromCart(itemId: Int) async {
        items.removeAll { $0.id == itemId }
    }
    
    // MARK: - Clear Cart
    func clearCart() async {
        items.removeAll()
    }
}
