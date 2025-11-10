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
                // Top 2/3 - Hero Image with Overlay
                ZStack {
                    Image("welcomeHero")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height * 2/3)
                        .clipped()
                    
                    // Dark overlay to cover all text on the image
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.5),
                            Color.black.opacity(0.6),
                            Color.black.opacity(0.7),
                            Color(.systemBackground).opacity(0.85),
                            Color(.systemBackground)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    
                    // Clean branding in the center
                    VStack(spacing: 16) {
                        Image(systemName: "bag.fill")
                            .font(.system(size: 70))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, .white.opacity(0.9)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("Prodify")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Your Shopping Destination")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .offset(y: -40)
                }
                
                // Bottom 1/3 - Content
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("Welcome Back!")
                            .font(.system(size: 28, weight: .bold))
                        
                        Text("Sign in or create an account to continue")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 12) {
                        NavigationLink(destination: LoginView()) {
                            HStack(spacing: 10) {
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
                            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        
                        NavigationLink(destination: RegisterView()) {
                            HStack(spacing: 10) {
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
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1.5)
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
