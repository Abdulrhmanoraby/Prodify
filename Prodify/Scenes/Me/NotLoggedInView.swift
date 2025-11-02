//
//  NotLoggedInView.swift
//  Prodify
//
//  Created by abdulrhman urabi on 30/10/2025.
//
import SwiftUI

struct NotLoggedInView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image("loginImage")
                .resizable()
                .scaledToFill()
                .frame(height: 450)
                .clipped()
                .ignoresSafeArea(edges: .top)

            Spacer()

            Text("Welcome to Prodify")
                .font(.title)
                .fontWeight(.bold)

            NavigationLink("Login") {
                LoginView()
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)

            NavigationLink("Register") {
                RegisterView()
            }
            .buttonStyle(.bordered)

            Spacer()
        }
        .padding()
    }
}
