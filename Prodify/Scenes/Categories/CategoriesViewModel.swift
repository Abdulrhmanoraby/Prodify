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
    @Published var allProducts: [Product] = []  // Store everything once
    @Published var isLoading = false
    
    func loadCategories() async{
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
        }
        
    }
    func loadProducts(for categoryID: Int) async throws {
        // Fetch but don't assign directly to products — we only use allProducts for filtering
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let fetched = try await ShopifyService.shared.fetchProducts(for: categoryID)
            // Optional: keep a cache by category ID if you want later
            print("Fetched \(fetched.count) for category \(categoryID)")
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    @MainActor
    func applyFilters(subCategory: String? = nil) {
        guard !allProducts.isEmpty else {
            print("⚠️ No products loaded yet")
            return
        }

        let currentSub = subCategory ?? "All"
        var result = allProducts

        // 🩵 Case 1 — Reset to original (no filters)
        if selectedCategory == nil && currentSub == "All" {
            filteredProducts = allProducts
            print("🔄 Reset filters — showing all \(filteredProducts.count) products")
            return
        }

        // 🟢 Case 2 — Filter by main category (if any)
        if let category = selectedCategory {
            let catName = category.title.lowercased()
            result = result.filter { product in
                let title = product.title.lowercased()
                let type = product.product_type?.lowercased() ?? ""
                return title.contains(catName) || type.contains(catName)
            }
        }

        // 🟠 Case 3 — Filter by subcategory (if not All)
        if currentSub != "All" {
            let sub = currentSub.lowercased()
            result = result.filter { product in
                let type = product.product_type?.lowercased() ?? ""
                let title = product.title.lowercased()
                return type.contains(sub) || title.contains(sub)
            }
        }

        filteredProducts = result
        print("✅ Filtered \(filteredProducts.count) products (category: \(selectedCategory?.title ?? "none"), sub: \(currentSub))")
    }
    func filterProducts(by subCategory: String) {
        guard let selectedCategory = selectedCategory else {
            print("No main category selected yet — using all products")
            filteredProducts = allProducts
            return
        }

        // Start with products belonging to the selected category
        var baseProducts = products

        // Then apply subcategory filter only if not "All"
        if subCategory != "All" {
            let sub = subCategory.lowercased()
            baseProducts = baseProducts.filter { product in
                let type = product.product_type?.lowercased() ?? ""
                return type.contains(sub)
            }
        }

        filteredProducts = baseProducts
        print("Filtered count: \(filteredProducts.count)")
    }
    func loadAllProductTypes() async throws {
        let allProducts = try await ShopifyService.shared.fetchAllProducts(limit: 250)
        let types = Set(allProducts.compactMap { $0.product_type?.trimmingCharacters(in: .whitespacesAndNewlines) })
        allProductTypes = ["All"] + types.sorted()
    }
 
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
    
    var subCategoriesFromAPI: [String] {
        let types = Set(products.compactMap { $0.product_type?.trimmingCharacters(in: .whitespacesAndNewlines) })
        let cleaned = types.filter { !$0.isEmpty }
        return ["All"] + cleaned.sorted()
    }
  
}
