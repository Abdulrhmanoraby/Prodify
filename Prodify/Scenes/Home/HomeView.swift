//
//  ContentView.swift
//  Prodify
//
//  Created by abdulrhman urabi on 20/10/2025.
//
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

                    // Hero Carousel placeholder
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                        .frame(height: 160)
                        .overlay(
                            Text("Hero Carousel Placeholder")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        )
                        .padding(.horizontal)

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

