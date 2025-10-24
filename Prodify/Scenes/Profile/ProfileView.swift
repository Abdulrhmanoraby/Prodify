//
//  ProfileView.swift
//  Prodify
//
//  Created by abdulrhman urabi on 23/10/2025.
//

// ProfileView.swift — simple user info + logout
import SwiftUI

struct ProfileView: View {
    @ObservedObject var vm: AuthViewModel

    var body: some View {
        VStack(spacing: 20) {
            if let user = vm.user {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue.opacity(0.8))
                    .padding(.top, 40)

                Text(user.email ?? "Unknown email")
                    .font(.headline)
                    .padding(.bottom, 8)

                Text("Account verified")
                    .foregroundColor(.green)
            }

            Button(role: .destructive) {
                vm.signOut()
            } label: {
                Text("Log Out")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)

            Spacer()
        }
        .padding()
    }
}
#Preview {
    ProfileView(vm: AuthViewModel())
}
