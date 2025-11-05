//
//  HomeViewModel.swift
//  Prodify
//
//  Created by abdulrhman urabi on 20/10/2025.
//
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var vendors: [Brand] = []
    @Published var products: [Product] = []
    @Published var filteredVendors: [Brand] = []
    @Published var filteredProducts: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            async let brands = ShopifyService.shared.fetchBrands()
            async let allProducts = ShopifyService.shared.fetchAllProducts(limit: 250)

            let (vendorsData, productsData) = try await (brands, allProducts)
            self.vendors = vendorsData
            self.products = productsData
            self.filteredVendors = vendorsData
            self.filteredProducts = productsData
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func filterSearch(_ text: String) {
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        if query.isEmpty {
            filteredVendors = vendors
            filteredProducts = products
            return
        }

        filteredVendors = vendors.filter {
            $0.title.lowercased().contains(query)
        }

        filteredProducts = products.filter {
            $0.title.lowercased().contains(query) ||
            ($0.product_type?.lowercased().contains(query) ?? false)
        }
    }
}
