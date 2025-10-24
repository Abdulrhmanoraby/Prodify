//
//  MeView.swift
//  Prodify
//
//  Created by abdulrhman urabi on 22/10/2025.
//

// MeView.swift — logic-based screen showing Login, Verify, or Profile.
import SwiftUI

struct MeView: View {
    @StateObject private var vm = AuthViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if let user = vm.user {
                    if user.verified {
                        // 1. Verified user → show profile
                        ProfileView(vm: vm)
                    } else {
                        // 2. Not verified → show verify email screen
                        VerifyEmailView(vm: vm)
                    }
                } else {
                    //  3. No user → show login screen
                    LoginView()
                }
            }
            .navigationTitle("Me")
            .onAppear {
                vm.loadCurrent()
            }
        }
    }
}

#Preview {
    MeView()
}
