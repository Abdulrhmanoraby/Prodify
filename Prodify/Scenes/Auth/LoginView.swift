// LoginView.swift
import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var vm: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top 2/3 - Image
                Image("loginImage")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height * 2/3)
                    .clipped()
                
                // Bottom 1/3 - Login Form
                VStack(spacing: 16) {
                    Text("Sign in")
                        .font(.title2)
                        .bold()
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                    
                    if let err = vm.errorMessage {
                        Text(err)
                            .foregroundColor(.red)
                            .font(.caption)
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
                            Text("Login")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    
                    NavigationLink("Register", destination: RegisterView())
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: geometry.size.height * 1/3)
                .background(Color(.systemBackground))
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationTitle("Login")
        .navigationBarTitleDisplayMode(.inline)
    }
}
