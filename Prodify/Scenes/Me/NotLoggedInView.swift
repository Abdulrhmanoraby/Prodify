//
//  NotLoggedInView.swift
//  Prodify
//
//  Created by abdulrhman urabi on 30/10/2025.
//
import SwiftUI

struct NotLoggedInView: View {
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top 2/3 - Image
                Image("loginImage")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height * 2/3)
                    .clipped()
                
                // Bottom 1/3 - Content
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("Welcome to Prodify")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Sign in or create an account to continue")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 12) {
                        NavigationLink(destination: LoginView()) {
                            HStack {
                                Image(systemName: "person.fill")
                                    .font(.headline)
                                Text("Login")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .blue.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        NavigationLink(destination: RegisterView()) {
                            HStack {
                                Image(systemName: "person.badge.plus")
                                    .font(.headline)
                                Text("Register")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(.systemGray6))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: geometry.size.height * 1/3)
                .background(Color(.systemBackground))
            }
        }
        .ignoresSafeArea(edges: .top)
    }
}

#Preview {
    NotLoggedInView()
}
