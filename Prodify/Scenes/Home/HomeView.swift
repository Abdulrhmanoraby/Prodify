//
//  ContentView.swift
//  Prodify
//
//  Created by abdulrhman urabi on 20/10/2025.
import SwiftUI

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    HomeHeaderView()

                    HomeSearchBar(searchText: $searchText)
                        .onChange(of: searchText) { newValue in
                            vm.filterSearch(newValue)
                        }

                    CouponAndAdsFeature()

                    if !vm.filteredVendors.isEmpty {
                        BrandCollectionView(vendors: vm.filteredVendors.map { $0.title })
                    }

                    if !vm.filteredProducts.isEmpty {
                        ProductsGridView(
                            products: vm.filteredProducts,
                            isLoading: vm.isLoading,
                            errorMessage: vm.errorMessage
                        )
                    }

                    if vm.filteredVendors.isEmpty && vm.filteredProducts.isEmpty && !searchText.isEmpty {
                        Text("No results found for \"\(searchText)\"")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
                .padding(.vertical)
            }
            .task {
                await vm.load()
            }
            .overlay {
                if vm.isLoading {
                    ProgressView().scaleEffect(1.3)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
