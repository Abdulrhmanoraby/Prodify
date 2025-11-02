//
//  WishlistView.swift
//  Prodify
//
//  Created by abdulrhman urabi on 30/10/2025.
//

import SwiftUI

struct WishlistView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Wishlist")
                    .font(.headline)
                Spacer()
                NavigationLink("More") {
                    Text("Wishlist coming soon...")
                }
                .font(.subheadline)
            }

            Text("You have 0 items in your wishlist.")
                .foregroundColor(.gray)
                .font(.footnote)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 1)
    }
}
