//
//  ProductInfoView.swift
//  Prodify
//
//  Created by alaa  on 30/10/2025.
//
//


import SwiftUI
import SwiftData
import UIKit

struct ProductInfoView: View {
    let product: Product
    @EnvironmentObject var cartVM: CartViewModel
    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var currency = CurrencyManager.shared

    // UI state
    @State private var isAdding = false
    @State private var navigateToCart = false
    @State private var isFavorite = false
    @State private var showFavoriteAlert = false
    @State private var animateHeart = false
    
    // MARK: - Computed alert strings
    private var alertTitle: String { isFavorite ? "Remove from Favorites" : "Add to Favorites" }
    private var alertMessage: String {
        isFavorite
            ? "Are you sure you want to remove this item from your favorites? You can add it again anytime."
            : "Are you sure you want to add this item to your favorites? You can find it later in the Favorites section."
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // MARK: - Image
                AsyncImage(url: URL(string: product.image?.src ?? "")) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(maxWidth: .infinity, maxHeight: 300)
                .cornerRadius(12)

                // MARK: - Title & Vendor
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.title)
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text(product.vendor ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // MARK: - Price
                if let priceString = product.variants?.first?.price, let usdPrice = Double(priceString) {
                    Text(currency.formatPrice(fromUSD: usdPrice))
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.vertical, 4)
                } else {
                    Text("—")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.vertical, 4)
                }

                // MARK: - Description
                if let desc = product.body_html, !desc.isEmpty {
                    Text(desc.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression))
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                // MARK: - Add to Cart Button
                Button {
                    Task {
                        isAdding = true
                        await cartVM.add(product: product)
                        isAdding = false
                        navigateToCart = true
                    }
                } label: {
                    HStack {
                        if isAdding {
                            ProgressView()
                        } else {
                            Image(systemName: "cart.badge.plus")
                            Text("Add to Cart")
                                .bold()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.top, 10)

                // MARK: - Navigation to Cart
                NavigationLink("", destination: CartView().environmentObject(cartVM), isActive: $navigateToCart)
                    .hidden()
            }
            .padding()
        }
        .navigationTitle(product.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                favoriteButton
            }
        }
        .onAppear {
            loadIsFavorite()
        }
        // dynamic confirmation alert
        .alert(alertTitle, isPresented: $showFavoriteAlert) {
            if isFavorite {
                Button("Remove", role: .destructive) { removeFromFavorites() }
                Button("Cancel", role: .cancel) { }
            } else {
                Button("Add", role: .none) { addToFavorites() }
                Button("Cancel", role: .cancel) { }
            }
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - Favorite button view
    private var favoriteButton: some View {
        Button {
            showFavoriteAlert = true
        } label: {
            ZStack {
                Circle()
                    .fill(Color(.systemBackground))
                    .frame(width: 40, height: 40)
                    .shadow(color: Color.black.opacity(0.06), radius: 6, y: 3)

                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 18, weight: .semibold))
                    .scaleEffect(animateHeart ? 1.15 : 1.0)
                    .foregroundColor(isFavorite ? .blue : Color.primary)
                    .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
                    .accessibilityHint("Adds or removes this product from your favorites list")
            }
        }
        .buttonStyle(.plain)
    }


    // MARK: - Persistence actions (SwiftData)
    private func loadIsFavorite() {
        guard let id = product.id else {
            isFavorite = false
            return
        }
        let pid = Int64(id)
        let fd = FetchDescriptor<FavoriteProduct>(predicate: #Predicate { $0.productId == pid })
        do {
            let results = try modelContext.fetch(fd)
            isFavorite = !results.isEmpty
        } catch {
            print("Failed to fetch favorite state:", error)
            isFavorite = false
        }
    }

    private func addToFavorites() {
        // guard for product id
        guard let id = product.id else { return }
        let pid = Int64(id)

        // create model and insert
        let favorite = FavoriteProduct(
            productId: pid,
            title: product.title,
            vendor: product.vendor,
            imageURL: product.image?.src,
            price: product.variants?.first?.price,
            bodyHTML: product.body_html
        )

        modelContext.insert(favorite)
        do {
            try modelContext.save()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                isFavorite = true
                animateHeart = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation(.easeOut(duration: 0.25)) { animateHeart = false }
            }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        } catch {
            print("Failed to save favorite:", error)
        }
    }

    private func removeFromFavorites() {
        guard let id = product.id else { return }
        let pid = Int64(id)
        let fd = FetchDescriptor<FavoriteProduct>(predicate: #Predicate { $0.productId == pid })
        do {
            let results = try modelContext.fetch(fd)
            for obj in results {
                modelContext.delete(obj)
            }
            try modelContext.save()
            withAnimation { isFavorite = false }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } catch {
            print("Failed to remove favorite:", error)
        }
    }
}

