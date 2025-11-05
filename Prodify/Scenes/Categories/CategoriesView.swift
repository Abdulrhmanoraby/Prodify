//
//  CategoriesView.swift
//  Prodify
//
//  Created by Abdulrhman on 2025-10-25.
//

import SwiftUI

struct CategoriesView: View {
    @StateObject private var viewModel = CategoriesViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                
                // Categories Bar view
                CategoriesBar()
                .onChange(of: viewModel.searchText) { newValue in
                    print("Search text updated:", newValue)
//                    viewModel.filterProductsBySearch(newValue)
                }
                
//sub and main categories filters view
                SubAndMainCategoriesView()
                // MARK: - Placeholder for filtered products
                if viewModel.filteredProducts.isEmpty {
                Spacer()
                    VStack(spacing: 8) {
                        Text("No products found.")
                            .foregroundColor(.gray)
                    }
                Spacer()
                } else {
                   
                }
            }
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    CategoriesView()
}
