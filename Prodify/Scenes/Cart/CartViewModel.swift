//
//  CartViewModel.swift
//  Prodify
//
//  Created by abdulrhman urabi on 28/10/2025.
//

import Foundation

@MainActor
final class CartViewModel: ObservableObject {
    @Published var items: [CartItem] = []
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    
    func loadCart() async {
        isLoading = true
        items = await CartService.shared.fetchCart()
        isLoading = false
    }
    
    func add(product: Product) async {
        await CartService.shared.addToCart(product: product)
        products.append(product)
        await loadCart()
    }
    
    func remove(itemId: Int) async {
        await CartService.shared.removeFromCart(itemId: itemId)
        await loadCart()
    }
    
    func clearCart() async {
        await CartService.shared.clearCart()
        await loadCart()
    }
    
    var total: Double {
        items.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }
}
