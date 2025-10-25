//
//  SwiftUIView.swift
//  Prodify
//
//  Created by abdulrhman urabi on 23/10/2025.
//


import SwiftUI

struct SignupView: View {
    @StateObject private var vm = AuthViewModel()
    @State private var email = ""
    @State private var password = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("Create account ").font(.title2).bold()

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)

            SecureField("Password (6+)", text: $password)
                .textFieldStyle(.roundedBorder)

            if vm.isLoading { ProgressView() }

            Button("Sign Up") {
                vm.signUp(email: email, password: password)
            }
            .buttonStyle(.borderedProminent)
            .disabled(email.isEmpty || password.count < 6)

            if let err = vm.errorMessage {
                Text(err).foregroundColor(.red).font(.caption)
            }

            if let user = vm.user {
                Text("Signed up as \(user.email ?? "")\nCheck your email for verification.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.green)
            }

            Spacer()
        }
        .padding()
        .onAppear { vm.loadCurrent() }
    }
}

#Preview {
    SignupView()
}
