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
            Text("Verify your email")
                .font(.title2)
                .bold()

            Text("Check your inbox and follow the link to verify your account. If you didn't get the email, you can resend it.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // MARK: - Resend verification email
            Button("Resend email") {
                vm.resendVerification()
            }
            .buttonStyle(.bordered)
            .padding(.top, 8)

            // MARK: - Refresh after verification
            Button("I verified — Refresh") {
                vm.refresh()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    if vm.user?.verified == true {
                        dismiss()
                    } else {
                        vm.errorMessage = "Still not verified. Try waiting a few seconds and refresh again."
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 4)

            // MARK: - Status messages
            if let msg = vm.successMessage {
                Text(msg)
                    .foregroundColor(.green)
                    .font(.caption)
                    .padding(.top, 4)
            }

            if let msg = vm.errorMessage {
                Text(msg)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 2)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Verify Email")
    }
}

#Preview {
    VerifyEmailView(vm: AuthViewModel())
}
