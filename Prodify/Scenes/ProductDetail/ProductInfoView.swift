//
//  ProductInfoView.swift
//  Prodify
//
//  Created by alaa  on 30/10/2025.
//
//


import SwiftUI

struct ProductInfoView: View {
    let product: Product
    @EnvironmentObject var cartVM: CartViewModel
    @State private var isAdding = false
    @State private var navigateToCart = false

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
                Text("\(product.variants?.first?.price ?? "—") EGP")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.vertical, 4)

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
                NavigationLink(destination: CartView(), isActive: $navigateToCart) {
                    EmptyView()
                }
            }
            .padding()
        }
        .navigationTitle(product.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ProductInfoView(product: Product(id: 10, title: "", vendor: "", image: nil, variants: nil, product_type: "Nike", body_html: nil))
        .environmentObject(CartViewModel())
}

