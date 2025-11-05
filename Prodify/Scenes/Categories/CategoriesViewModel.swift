//
//  CategoriesViewModel.swift
//  Prodify
//
//  Created by abdulrhman urabi on 25/10/2025.
//
import Foundation
@MainActor
final class CategoriesViewModel: ObservableObject{
    @Published var categories: [Category] = []
    @Published var products: [Product] = []
    @Published var errorMessage : String?
    @Published var selectedCategory: Category?
    @Published var filteredProducts: [Product] = []
    @Published var allProductTypes: [String] = []
    @Published var allProducts: [Product] = []
    @Published var searchText: String = "" {
        didSet {
            print("[VM] searchText didSet -> '", searchText, "'")
            filterProductsBySearch(searchText)
        }
    }
    @Published var isLoading = false
    
    func loadCategories() async throws{
        isLoading = true
        defer {
            isLoading = false
        }
        do{
            let fetched = try await ShopifyService.shared.fetchCategories()
            categories = fetched
            self.selectedCategory = fetched.first
        }catch{
            errorMessage = error.localizedDescription
            throw error
        }
        
    }
    func loadProducts(for categoryID: Int) async throws {
        isLoading = true
        errorMessage = nil
        do {
            let fetched = try await ShopifyService.shared.fetchProducts(for: categoryID)
           // products = fetched
            filteredProducts = fetched // default same as all
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    
    func loadAllProductTypes() async throws {
        let allProducts = try await ShopifyService.shared.fetchAllProducts(limit: 250)
        let types = Set(allProducts.compactMap { $0.product_type?.trimmingCharacters(in: .whitespacesAndNewlines) })
        allProductTypes = ["All"] + types.sorted()
    }
   @MainActor
    func loadAllProducts() async throws {
        isLoading = true
        errorMessage = nil
        do {
            let fetched = try await ShopifyService.shared.fetchAllProducts(limit: 250)
            allProducts = fetched
            products = fetched
            filteredProducts = fetched
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    
    func filterByCategory(_ category: Category) {
        // This assumes you can match by title or handle — adjust as needed
        filteredProducts = allProducts.filter { product in
            product.title.localizedCaseInsensitiveContains(category.title)
        }
    }
    
    @MainActor
    func filterProductsBySearch(_ query: String) {
        print("[VM] filterProductsBySearch called with query: '", query, "'")
        let source = products.isEmpty ? allProducts : products
        print("[VM] filtering source count:", source.count)

        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            filteredProducts = source
            print("[VM] filteredProducts reset to all (", filteredProducts.count, ")")
            return
        }

        let lowerQuery = query.lowercased()
        let filtered = source.filter { product in
            product.title.lowercased().contains(lowerQuery) ||
            (product.product_type?.lowercased().contains(lowerQuery) ?? false)
        }
        filteredProducts = filtered
        print("[VM] filteredProducts count after filtering:", filteredProducts.count)
    }
  
    // MARK: - Added: filter by product type used by the Picker
    @MainActor
    func filterProducts(byType type: String) {
        let source = products.isEmpty ? allProducts : products
        if type == "All" {
            filteredProducts = source
        } else {
            filteredProducts = source.filter { ($0.product_type ?? "").caseInsensitiveCompare(type) == .orderedSame }
        }
    }
}
