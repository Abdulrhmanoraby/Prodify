//
//  HomeHeaderView.swift
//  Prodify
//
//  Created by abdulrhman urabi on 22/10/2025.
//

import SwiftUI



struct HomeHeaderView: View {
    var body: some View {
        HStack {
            Text("Prodify")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.black)

            Spacer()

            HStack(spacing: 16) {
                Button(action: {
                    // TODO: Navigate to favorites
                }) {
                    Image(systemName: "heart")
                }

                Button(action: {
                    // TODO: Navigate to cart
                }) {
                    Image(systemName: "cart")
                }
            }
            .font(.title3)
            .foregroundColor(.primary)
        }
        .padding(.horizontal)
    }
}
#Preview {
   HomeHeaderView()
}

