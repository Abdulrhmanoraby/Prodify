//
//  BrandCollectionView.swift
//  Prodify
//
//  Created by abdulrhman urabi on 22/10/2025.
//

import SwiftUI

struct BrandCollectionView: View {
    let vendors: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Brands")
                .font(.headline)
                .padding(.horizontal)

            // Two-row scroll of vendor logos
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [GridItem(.fixed(110)), GridItem(.fixed(110))], spacing: 12) {
                    ForEach(vendors, id: \.self) { vendor in
                        NavigationLink(destination: BrandProductsView(vendor: vendor)) {
                            VStack(spacing: 8) {
                                if let url = logoURL(for: vendor) {
                                    AsyncImage(url: url) { img in
                                        img.resizable().scaledToFill()
                                    } placeholder: {
                                        Color(.systemGray5)
                                    }
                                    .frame(width: 110, height: 80)
                                    .cornerRadius(10)
                                } else {
                                    Image(vendor)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 110, height: 80)
                                        .cornerRadius(10)
                                }

                                Text(vendor)
                                    .font(.caption)
                                    .lineLimit(1)
                            }
                            .frame(width: 110)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // Optional helper for free logos
    private func logoURL(for vendor: String) -> URL? {
        if UIImage(named: vendor) != nil {
            return nil
        }
        let name = vendor.replacingOccurrences(of: " ", with: "_")
        print(name)
        return URL(string: "https://logo.clearbit.com/\(name.lowercased()).com")
    }
}
