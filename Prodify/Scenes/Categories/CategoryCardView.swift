//
//  CategoryCardView.swift
//  Prodify
//
//  Created by abdulrhman urabi on 25/10/2025.
//

import SwiftUI

struct ProductCard: View {
    let product: Product
    @ObservedObject private var currency = CurrencyManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            productImage
            productDetails
        }
        .padding(6)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 3)
    }

    private var productImage: some View {
        AsyncImage(url: URL(string: product.image?.src ?? "")) { phase in
            switch phase {
            case .empty:
                Color(.systemGray5)
                    .frame(height: 130)
                    .cornerRadius(12)
            case .success(let image):
                image.resizable()
                    .scaledToFill()
                    .frame(height: 130)
                    .cornerRadius(12)
                    .clipped()
            case .failure:
                Color(.systemGray5)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.title)
                            .foregroundColor(.gray)
                    )
                    .frame(height: 130)
                    .cornerRadius(12)
            @unknown default:
                EmptyView()
            }
        }
    }

    private var productDetails: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(product.title)
                .font(.headline)
                .lineLimit(1)
            if let priceString = product.variants?.first?.price, let usd = Double(priceString) {
                Text(currency.formatPrice(fromUSD: usd))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                Text("-")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
