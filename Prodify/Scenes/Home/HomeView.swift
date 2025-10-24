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
                    // Header with logo + icons
                    HomeHeaderView()

                    // Search bar
                    HomeSearchBar(searchText: $searchText)

                    
                    CouponAndAdsFeature()
                    // Brand collection
                    BrandCollectionView(vendors: vm.vendors)
                }
                .padding(.vertical)
            }
            .task { await vm.load() }
            .overlay {
                if vm.isLoading { ProgressView().scaleEffect(1.3) }
            }
        }
    }
}

