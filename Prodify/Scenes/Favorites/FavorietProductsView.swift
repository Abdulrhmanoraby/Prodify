//
//  FavorietProductsView.swift
//  Prodify
//
//  Created by Alaa Muhamed on 03/11/2025.
//

import SwiftUI
import SwiftData

struct FavoriteProductView: View {
    @Query(sort: [.init(\FavoriteProduct.title, order: .forward)])
    private var favorites: [FavoriteProduct]
    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var currency = CurrencyManager.shared
    
    var body: some View {
        NavigationStack {
            List {
                if favorites.isEmpty {
                    Text("No favorites yet").foregroundColor(.secondary)
                } else {
                    ForEach(favorites) { fav in
                        HStack(spacing: 12) {
                            AsyncImage(url: URL(string: fav.imageURL ?? "")) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.2)
                            }
                            .frame(width: 56, height: 56)
                            .cornerRadius(8)
                            .clipped()
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(fav.title).font(.headline).lineLimit(2)
                                if let vendor = fav.vendor {
                                    Text(vendor).font(.subheadline).foregroundColor(.secondary)
                                }
                                if let priceString = fav.price, let usd = Double(priceString) {
                                    Text(currency.formatPrice(fromUSD: usd))
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                } else if let priceString = fav.price {
                                    Text(priceString)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .onDelete(perform: delete)
                }
            }
            .navigationTitle("Favorites")
        }
    }
    
    private func delete(at offsets: IndexSet) {
        for idx in offsets {
            let obj = favorites[idx]
            modelContext.delete(obj)
        }
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete favorite:", error)
        }
    }
}

