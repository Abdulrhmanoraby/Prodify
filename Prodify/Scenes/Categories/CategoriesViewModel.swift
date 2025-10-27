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
    
    @MainActor
    func filterProducts(by subCategory: String) {
        guard !products.isEmpty else {
            print("No products to filter")
            return
        }

        print("Filtering by:", subCategory)
        print("Available product types:", Set(products.compactMap { $0.product_type }))

        guard subCategory != "All" else {
            if let selected = selectedCategory {
                filterByCategory(selected)
            } else {
                filteredProducts = allProducts
            }
            return
        }

        let sub = subCategory.lowercased()
        filteredProducts = products.filter { product in
            let type = product.product_type?.lowercased() ?? ""
            let title = product.title.lowercased()
            return type.contains(sub) || title.contains(sub)
        }

        print("Filtered count:", filteredProducts.count)
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
    
//    var subCategoriesFromAPI: [String] {
//        let types = Set(products.compactMap { $0.product_type?.trimmingCharacters(in: .whitespacesAndNewlines) })
//        let cleaned = types.filter { !$0.isEmpty }
//        return ["All"] + cleaned.sorted()
//    }
  
}
