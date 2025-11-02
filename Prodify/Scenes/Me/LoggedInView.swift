//
//  LoggedInView.swift
//  Prodify
//
//  Created by abdulrhman urabi on 30/10/2025.
//

import SwiftUI

struct LoggedInView: View {
    @ObservedObject var vm: AuthViewModel
    @ObservedObject var orderVM: OrderViewModel
    let user: UserInfo

    @State private var currentEmail = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Welcome, \(user.firstName ?? "User")")
                .font(.title3)
                .fontWeight(.medium)
                .padding(.top)

            OrdersPreviewView(orderVM: orderVM)
            WishlistView()

            Button(role: .destructive) {
                vm.logout()
            } label: {
                Text("Logout")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)

            Spacer()
        }
        .padding()
        .task {
            currentEmail = user.email ?? ""
            await orderVM.fetchOrders(for: currentEmail)
        }
    }
}


