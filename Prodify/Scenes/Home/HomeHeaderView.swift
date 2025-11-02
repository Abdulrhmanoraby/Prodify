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
                
                // TODO: Navigate to favorites
                    Image(systemName: "heart")
                

                NavigationLink(destination: CartView()) {
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

