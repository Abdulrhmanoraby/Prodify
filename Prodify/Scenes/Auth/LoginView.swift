//
//  LoginView.swift
//  Prodify
//
//  Created by abdulrhman urabi on 23/10/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
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
                Spacer().frame(height: 10)
                VStack{
                    Text("Login")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                    
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button {
                        Task { await loginUser() }
                    } label: {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Login")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                
                        }
                        
                    }
                    
                    NavigationLink("Don’t have an account? Register") {
                        RegisterView()
                    }
                }.padding(.horizontal)
                    .padding()
                .font(.footnote)
               
                .navigationTitle("Login")
            }
        Spacer().frame(height: 110)
            .padding()
            
            
        }
    
    
    

    private func loginUser() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)

            // Fetch user info from Firestore
            let snapshot = try await db.collection("users").document(result.user.uid).getDocument()
            if let data = snapshot.data() {
                print("Fetched user info:", data)
            }

            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
#Preview{
    LoginView()
}
