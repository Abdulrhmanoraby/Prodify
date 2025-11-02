//
//  SwiftUIView.swift
//  Prodify
//
//  Created by abdulrhman urabi on 23/10/2025.
//


import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RegisterView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var isLoading = false
    @Environment(\.dismiss) private var dismiss

    private let db = Firestore.firestore()

    var body: some View {
        VStack(spacing: 20) {
            Image("loginImage")
                .resizable()
                .scaledToFill()
                .frame(height: 450)
                .clipped()
                .ignoresSafeArea(edges: .top)
            
            // Space for image
            VStack{
                Text("Register")
                    .font(.title)
                    .fontWeight(.bold)
                
                TextField("First Name", text: $firstName)
                    .textFieldStyle(.roundedBorder)
                TextField("Last Name", text: $lastName)
                    .textFieldStyle(.roundedBorder)
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(.roundedBorder)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
                
                Button {
                    Task { await registerUser() }
                } label: {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Register")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding(.horizontal)
           
            Spacer().frame(height: 150)
        }
        .padding()
        Spacer()
        .navigationTitle("Register")
    }

    private func registerUser() async {
        guard !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty,
              !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            guard let user = Auth.auth().currentUser else { return }

            // Send verification email
            try await user.sendEmailVerification()

            //Save user info in Firestore
            let userInfo = [
                "id": result.user.uid,
                "firstName": firstName,
                "lastName": lastName,
                "email": email,
                "verified": false
            ] as [String: Any]

            try await db.collection("users").document(result.user.uid).setData(userInfo)

            errorMessage = "Account created! Please verify your email."
            print("User saved to Firestore:", userInfo)

            dismiss()

        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
#Preview{
    RegisterView()
}
