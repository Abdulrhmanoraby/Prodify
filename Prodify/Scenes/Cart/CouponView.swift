//
//  CouponView.swift
//  Prodify
//
//  Created by abdulrhman urabi on 27/10/2025.
//

import SwiftUI
import FirebaseAuth

struct CouponView: View {
    let cartProducts: [Product]
    let address: String
    let paymentMethod: String

    @State private var coupon = ""
    @State private var isLoading = false
    @State private var currentEmail: String = ""
    @State private var navigateToOrders = false
    @EnvironmentObject var vm: CartViewModel
    @EnvironmentObject var orderVM : OrderViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Apply Coupon (optional)")
                .font(.title3)

            TextField("Enter coupon", text: $coupon)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            Button {
                Task { await placeOrder()
                    
                }
            } label: {
                Text("Place Order")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            if isLoading {
                ProgressView("Processing...")
            } else if let msg = orderVM.successMessage {
                Text(msg).foregroundColor(.green)
        
            } else if let err = orderVM.errorMessage {
                Text(err).foregroundColor(.red)
                
            }
            // Navigate to OrderListView after placing order
            NavigationLink(destination: OrderListView(), isActive: $navigateToOrders) {
                            EmptyView()
                        }
                        .hidden()
        }
        .navigationTitle("Place Order")
        .task {
            if let user = Auth.auth().currentUser {
                currentEmail = user.email ?? "guest@prodify.com"
            }
        }
    }

    // MARK: - Place Order Logic (Fixed)
    private func placeOrder() async {
        guard !cartProducts.isEmpty else {
            print("No products in cart.")
            return
        }

        isLoading = true
        defer { isLoading = false }

        let email = currentEmail.isEmpty ? "guest@prodify.com" : currentEmail

        // Create Firestore order using real cart products
        await orderVM.createOrder(
            products: cartProducts,
            email: email,
            address: address
        )

        // (Optional) confirmation log
        if let msg = orderVM.successMessage {
            print("\(msg)")
            await vm.clearCart()
            await orderVM.fetchOrders(for: currentEmail)
            navigateToOrders = true
        } else if let err = orderVM.errorMessage {
            print("\(err)")
        }
    }
}


