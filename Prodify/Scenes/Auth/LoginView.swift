// LoginView.swift
import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var vm :AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("Sign in").font(.title2).bold()
            TextField("Email", text: $email).textFieldStyle(.roundedBorder).autocapitalization(.none)
            SecureField("Password", text: $password).textFieldStyle(.roundedBorder)

            if let err = vm.errorMessage {
                Text(err).foregroundColor(.red).font(.caption)
            }

            Button {
                vm.signIn(email: email, password: password)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
               
            } label: {
                if vm.isLoading {
                    ProgressView()
                } else {
                    Text("Login").bold().frame(maxWidth: .infinity).padding().background(Color.blue).foregroundColor(.white).cornerRadius(8)
                }
            }

            NavigationLink("Register", destination: RegisterView())

            Spacer()
        }
        .padding()
        .navigationTitle("Login")
    }
}
