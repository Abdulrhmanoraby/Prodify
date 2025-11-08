// RegisterView.swift
import SwiftUI

struct RegisterView: View {
    @EnvironmentObject private var vm: AuthViewModel
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirm = ""
    @State private var navigateToVerify = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top 1/3 - Image
                Image("loginImage")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height * 1/3)
                    .clipped()
                
                // Bottom 2/3 - Register Form
                ScrollView {
                    VStack(spacing: 16) {
                        Text("Create account")
                            .font(.title2)
                            .bold()
                            .padding(.top, 8)
                        
                        TextField("First name", text: $firstName)
                            .textFieldStyle(.roundedBorder)
                        
                        TextField("Last name", text: $lastName)
                            .textFieldStyle(.roundedBorder)
                        
                        TextField("Email", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                        
                        SecureField("Confirm password", text: $confirm)
                            .textFieldStyle(.roundedBorder)
                        
                        if let err = vm.errorMessage {
                            Text(err)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        
                        Button {
                            register()
                        } label: {
                            if vm.isLoading {
                                ProgressView()
                            } else {
                                Text("Register")
                                    .bold()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .disabled(vm.isLoading)
                        .padding(.top)
                        
                        Spacer()
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: geometry.size.height * 2/3)
                .background(Color(.systemBackground))
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationTitle("Register")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func register() {
        vm.errorMessage = nil
        guard !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !password.isEmpty else {
            vm.errorMessage = "Please fill all fields"
            return
        }
        guard password == confirm else {
            vm.errorMessage = "Passwords do not match"
            return
        }
        vm.signUp(firstName: firstName, lastName: lastName, email: email, password: password)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
    }
}
