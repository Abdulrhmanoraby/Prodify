//
//  AuthViewModel.swift
//  Prodify
//
//  Created by abdulrhman urabi on 23/10/2025.
//

import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var user: UserInfo?

    private let auth = AuthService.shared

    func signUp(email: String, password: String) {
        isLoading = true; errorMessage = nil
        auth.signUp(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let u): self?.user = u
                case .failure(let e): self?.errorMessage = e.localizedDescription
                }
            }
        }
    }

    func signIn(email: String, password: String) {
        isLoading = true; errorMessage = nil
        auth.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let u): self?.user = u
                case .failure(let e): self?.errorMessage = e.localizedDescription
                }
            }
        }
    }

    func resendVerification() {
        isLoading = true; errorMessage = nil
        auth.resendVerification { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(): self?.errorMessage = "Verification email sent."
                case .failure(let e): self?.errorMessage = e.localizedDescription
                }
            }
        }
    }

    func signOut() {
        switch auth.signOut() {
        case .success(): user = nil
        case .failure(let e): errorMessage = e.localizedDescription
        }
    }

    func loadCurrent() {
        user = auth.currentUser()
    }
    // AuthViewModel.swift (add this method)
    func refreshUser(completion: (() -> Void)? = nil) {
        isLoading = true
        AuthService.shared.refreshCurrentUser { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let info):
                    self?.user = info
                case .failure(let err):
                    // optional: show error, but don't block
                    self?.errorMessage = err.localizedDescription
                }
                completion?()
            }
        }
        
    }
}
