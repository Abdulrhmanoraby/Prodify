//
//  OrdersPreviewView.swift
//  Prodify
//
//  Created by abdulrhman urabi on 30/10/2025.
//

import SwiftUI

struct OrdersPreviewView: View {
    @ObservedObject var orderVM: OrderViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("My Orders")
                    .font(.headline)
                Spacer()
                NavigationLink("More") {
                    OrderListView()
                }
                .font(.subheadline)
            }

            if orderVM.orders.isEmpty {
                Text("No orders yet.")
                    .foregroundColor(.gray)
            } else {
                ForEach(orderVM.orders.prefix(2)) { order in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Order #\(order.id)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("Total: \(order.total_price ?? "—") EGP")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 1)
    }
}

