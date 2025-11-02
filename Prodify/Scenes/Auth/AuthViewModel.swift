//
//  AuthViewModel.swift
//  Prodify
//
//  Created by abdulrhman urabi on 20/10/2025.
//

import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var user: UserInfo?
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var isLoading = false
    
    private let service = AuthService.shared
    
    // MARK: - Sign Up
    func signUp(firstName: String, lastName: String, email: String, password: String) {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        service.signUp(firstName: firstName, lastName: lastName, email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let info):
                    self?.user = info
                    self?.successMessage = "Account created! Please verify your email."
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Sign In
    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        service.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let info):
                    self?.user = info
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Resend Verification
    func resendVerification() {
        service.resendVerification { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.successMessage = "Verification email sent."
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Sign Out
    func signOut() {
        switch service.signOut() {
        case .success:
            user = nil
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Load Current
    func loadCurrent() {
        service.currentUser { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let userInfo):
                    self?.user = userInfo
                case .failure(let error):
                    print("Failed to load current user: \(error.localizedDescription)")
                    self?.user = nil
                }
            }
        }
    }
    
    // MARK: - Refresh Current User
    func refresh() {
        service.refreshCurrentUser { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let info):
                    self?.user = info
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func logout() {
        let result = AuthService.shared.signOut()
        switch result {
        case .success:
            self.user = nil
            self.successMessage = "Signed out successfully."
        case .failure(let err):
            self.errorMessage = err.localizedDescription
        }
    }
}
