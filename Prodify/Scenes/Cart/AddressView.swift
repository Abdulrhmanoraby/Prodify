//
//  AddressView.swift
//  Prodify
//
//  Created by abdulrhman urabi on 27/10/2025.
//

import SwiftUI

struct AddressView: View {
    @State private var address = ""
    let cartProducts: [Product]

    var body: some View {
        VStack(spacing: 20) {
            Text("Enter Shipping Address")
                .font(.title3)

            TextField("Your address", text: $address)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            NavigationLink("Continue to Payment", destination: PaymentView(address: address, cartProducts: cartProducts))
                .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Address")
    }
}

