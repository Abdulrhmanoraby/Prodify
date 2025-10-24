//
//  ContentView.swift
//  Prodify
//
//  Created by abdulrhman urabi on 20/10/2025.
//

import SwiftUI

struct AdCoupon: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
    let isCoupon: Bool
}

struct CouponAndAdsFeature: View {
    let items: [AdCoupon] = [
        AdCoupon(title: "Ad 1", description: "This is the first ad.", imageName: "Ad1", isCoupon: false),
        AdCoupon(title: "Ad 2", description: "This is the second ad.", imageName: "Ad2", isCoupon: false),
        AdCoupon(title: "Ad 3", description: "This is the third ad.", imageName: "Ad3", isCoupon: false),
        AdCoupon(title: "SAVE10", description: "10% Off", imageName: "coupon1", isCoupon: true),
        AdCoupon(title: "FREESHIP", description: "Free Shipping", imageName: "coupon2", isCoupon: true)
    ]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(items) { item in
                    VStack(alignment: .leading) {
                        Image(item.imageName)
                            .resizable()
                            .frame(width: 200, height: 200)
                            .cornerRadius(10)
                        
                        if item.isCoupon {
                            Button(action: {
                                UIPasteboard.general.string = item.title
                            }) {
                                Text("Copy Code")
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.green)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    CouponAndAdsFeature()
}
