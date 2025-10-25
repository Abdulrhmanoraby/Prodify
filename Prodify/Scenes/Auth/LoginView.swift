//
//  LoginView.swift
//  Prodify
//
//  Created by abdulrhman urabi on 23/10/2025.
//


import SwiftUI

struct LoginView: View {
    @StateObject private var vm = AuthViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var showVerify = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Sign in ").font(.title2).bold()

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            if vm.isLoading { ProgressView() }

            Button("Sign In") {
                vm.signIn(email: email, password: password)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    if let u = vm.user, !u.verified { showVerify = true }
                }
            }
            .buttonStyle(.borderedProminent)

            NavigationLink("Create account", destination: SignupView())

            if let err = vm.errorMessage {
                Text(err).foregroundColor(.red).font(.caption)
            }

            Spacer()
        }
        .padding()
        .sheet(isPresented: $showVerify) {
            VerifyEmailView(vm: vm)
        }
        .onAppear { vm.loadCurrent() }
    }
}

#Preview {
    LoginView()
}
