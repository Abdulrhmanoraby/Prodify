//
//  ProductsGridView.swift
//  Prodify
//
//  Created by abdulrhman urabi on 26/10/2025.
//

import SwiftUI


struct ProductsGridView: View {
    let products: [Product]
    let isLoading: Bool
    let errorMessage: String?

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        Group {
            if isLoading {
                loadingView
            } else if let error = errorMessage {
                errorView(error)
            } else if products.isEmpty {
                emptyView
            } else {
                productsGrid
            }
        }
        .animation(.easeInOut, value: products.count)
    }

    // MARK: - Subviews

    private var loadingView: some View {
        ProgressView("Loading products...")
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
    }

    private func errorView(_ error: String) -> some View {
        Text("\(error)")
            .foregroundColor(.red)
            .multilineTextAlignment(.center)
            .padding()
    }

    private var emptyView: some View {
        VStack(spacing: 8) {
            Image(systemName: "bag")
                .font(.largeTitle)
                .foregroundColor(.gray)
            Text("No products found")
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
    }

    private var productsGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(products) { product in
                    ProductCard(product: product)
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    ProductsGridView(products: [], isLoading: false, errorMessage: nil)
}

#Preview {
    ProductsGridView(products: [], isLoading: true, errorMessage: "")
}
