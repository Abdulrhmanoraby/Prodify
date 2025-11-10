//
//  CategoriesBar.swift
//  Prodify
//
//  Created by abdulrhman urabi on 25/10/2025.
//

import SwiftUI

struct CategoriesBar: View {
    var body: some View {
        // MARK: - Top Bar (Search + Buttons)
        HStack(spacing: 12) {
            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search products...", text: .constant(""))
                    .textFieldStyle(.plain)
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)


        }
        .padding(.horizontal)
    }
}

#Preview {
    CategoriesBar()
}
