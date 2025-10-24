//
//  HomeSearchBar.swift
//  Prodify
//
//  Created by abdulrhman urabi on 22/10/2025.
//

import SwiftUI

struct HomeSearchBar: View {
    @Binding var searchText: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search products or brands", text: $searchText)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}
