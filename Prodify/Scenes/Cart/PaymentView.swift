//
//  PaymentView.swift
//  Prodify
//
//  Created by abdulrhman urabi on 27/10/2025.
//

import SwiftUI

struct PaymentView: View {
    let address: String
    @State private var selectedPayment = "Cash"
    let cartProducts: [Product]
    let paymentMethods = ["Cash", "Online"]

    var body: some View {
        VStack(spacing: 20) {
            Text("Select Payment Method")
                .font(.title3)

            Picker("Payment", selection: $selectedPayment) {
                ForEach(paymentMethods, id: \.self) { method in
                    Text(method)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            NavigationLink("Continue to Coupon", destination: CouponView(cartProducts: cartProducts, address: address, paymentMethod: selectedPayment))
                .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Payment")
    }
}

