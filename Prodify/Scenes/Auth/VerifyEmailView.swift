import SwiftUI

struct VerifyEmailView: View {
    @ObservedObject var vm: AuthViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Verify Your Email")
                .font(.title2)
                .fontWeight(.semibold)

            Text("We’ve sent a verification link to your email. Once verified, tap the button below to refresh your status.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("I Verified — Refresh") {
                vm.refreshUser {
                    if vm.user?.verified == true {
                        // when verified, reload user & behave like before (show MeView / logged in)
                        vm.loadCurrent()
                        dismiss()
                    } else {
                        vm.errorMessage = "Still not verified. Try again in a few seconds."
                    }
                }
            }
            .buttonStyle(.borderedProminent)

            Button("Resend Verification Email") {
                vm.resendVerification()
            }
            .buttonStyle(.bordered)

            // NEW: allow user to cancel and go back to Login / Register
            Button("Back to Login or Register") {
         
                dismiss()
            }
            .foregroundColor(.red)
            .padding(.top, 10)

            if let msg = vm.errorMessage {
                Text(msg)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Email Verification")
    }
}
