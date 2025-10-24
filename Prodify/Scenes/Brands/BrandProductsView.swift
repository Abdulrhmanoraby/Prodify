//
//  BrandProductsView.swift
//  Prodify
//
//  Created by abdulrhman urabi on 22/10/2025.
//

import SwiftUI
struct BrandProductsView: View {
    let vendor: String
    @StateObject private var vm: BrandProductsViewModel

    init(vendor: String) {
        self.vendor = vendor
        _vm = StateObject(wrappedValue: BrandProductsViewModel(vendor: vendor))
    }

    var body: some View {
        ScrollView {
            if vm.products.isEmpty && !vm.isLoading {
                VStack(spacing: 12) {
                    Image(systemName: "shippingbox")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Text("No products found for \(vendor)")
                        .foregroundColor(.gray)
                }
                .padding(.top, 100)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(vm.products) { product in
                        VStack(alignment: .leading, spacing: 8) {
                            AsyncImage(url: URL(string: product.image?.src ?? "")) { img in
                                img.resizable().scaledToFill()
                            } placeholder: {
                                Color(.systemGray5)
                            }
                            .frame(height: 140)
                            .cornerRadius(10)

                            Text(product.title)
                                .font(.subheadline)
                                .lineLimit(2)
                            Text("$\(product.variants?.first?.price ?? "-")")
                                .font(.headline)
                        }
                        .padding(8)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(vendor)
        .navigationTitle(vendor)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .task { await vm.load() }
        .overlay {
            if vm.isLoading {
                ProgressView().scaleEffect(1.3)
            }
        }
    }
}


