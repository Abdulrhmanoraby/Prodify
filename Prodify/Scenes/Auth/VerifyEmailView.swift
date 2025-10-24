//
//  VerifyEmailView.swift
//  Prodify
//
//  Created by abdulrhman urabi on 23/10/2025.
//


import SwiftUI

struct VerifyEmailView: View {
    @ObservedObject var vm: AuthViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("Verify your email").font(.title2).bold()
            Text("Check your inbox and follow the link. If you didn't get it, resend.")
                .font(.body).multilineTextAlignment(.center)

            Button("Resend email") {
                vm.resendVerification()
            }

            // VerifyEmailView.swift (inside Button "I verified — Refresh")
            Button("I verified — Refresh") {
                vm.refreshUser {
                    // run on main after refresh; dismiss if verified
                    if vm.user?.verified == true {
                        dismiss()
                    } else {
                        // optional: show hint to user
                        vm.errorMessage = "Still not verified. Try waiting a few seconds and refresh again."
                    }
                }
            }
            .buttonStyle(.borderedProminent)

            if let msg = vm.errorMessage {
                Text(msg).foregroundColor(.gray).font(.caption)
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    VerifyEmailView(vm: AuthViewModel())
}
