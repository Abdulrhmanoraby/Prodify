// RegisterView.swift
import SwiftUI

struct RegisterView: View {
    @EnvironmentObject private var vm : AuthViewModel
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirm = ""
    @State private var navigateToVerify = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("Create account").font(.title2).bold()
            TextField("First name", text: $firstName).textFieldStyle(.roundedBorder)
            TextField("Last name", text: $lastName).textFieldStyle(.roundedBorder)
            TextField("Email", text: $email).textFieldStyle(.roundedBorder).keyboardType(.emailAddress).autocapitalization(.none)
            SecureField("Password", text: $password).textFieldStyle(.roundedBorder)
            SecureField("Confirm password", text: $confirm).textFieldStyle(.roundedBorder)

            if let err = vm.errorMessage {
                Text(err).foregroundColor(.red).font(.caption)
            }

            Button {
                register()
               
            } label: {
                if vm.isLoading {
                    ProgressView()
                } else {
                    Text("Register").bold().frame(maxWidth: .infinity).padding().background(Color.blue).foregroundColor(.white).cornerRadius(8)
                }
            }
            .disabled(vm.isLoading)
            .padding(.top)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Register")
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
