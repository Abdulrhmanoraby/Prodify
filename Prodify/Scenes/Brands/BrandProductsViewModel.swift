//
//  BrandProductsViewModel.swift
//  Prodify
//
//  Created by abdulrhman urabi on 22/10/2025.
//
import Foundation
@MainActor
final class BrandProductsViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service = ShopifyService.shared
    let vendor: String

    init(vendor: String) {
        self.vendor = vendor
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            products = try await service.fetchProducts(byVendor: vendor)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
