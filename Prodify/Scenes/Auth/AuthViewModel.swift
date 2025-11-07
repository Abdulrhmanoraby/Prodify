// AuthViewModel.swift
import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var user: UserInfo?
    @Published var isLoading = false
    @Published var errorMessage: String?
    private let db = Firestore.firestore()
    private let service = AuthService.shared

    // Sign up
    func signUp(firstName: String, lastName: String, email: String, password: String) {
        isLoading = true
        errorMessage = nil
        service.signUp(firstName: firstName, lastName: lastName, email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let info):
                    self?.user = info
                case .failure(let err):
                    self?.errorMessage = err.localizedDescription
                }
            }
        }
    }

    // Sign in
    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        service.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let info):
                    self?.user = info
                case .failure(let err):
                    self?.errorMessage = err.localizedDescription
                }
            }
        }
    }

    // Load current user (if logged in)
    @MainActor
    func loadCurrent() {
        guard let u = Auth.auth().currentUser else {
            self.user = nil
            return
        }

        u.reload { _ in
            Task { @MainActor in
                do {
                    let doc = try await Firestore.firestore().collection("users").document(u.uid).getDocument()
                    if let data = doc.data() {
                        let info = try Firestore.Decoder().decode(UserInfo.self, from: data)
                        self.user = UserInfo(
                            id: u.uid,
                            firstName: info.firstName,
                            lastName: info.lastName,
                            email: u.email ?? "",
                            verified: u.isEmailVerified,
                            phoneNumber: info.phoneNumber,
                            street: info.street,
                            city: info.city,
                            country: info.country
                        )
                    } else {
                        // fallback if user not found in Firestore
                        self.user = UserInfo(
                            id: u.uid,
                            firstName: "",
                            lastName: "",
                            email: u.email ?? "",
                            verified: u.isEmailVerified
                        )
                    }
                } catch {
                    print("⚠️ Error loading Firestore user info: \(error.localizedDescription)")
                }
            }
        }
    }

    // Refresh verification & user doc
    @MainActor
    func refreshUser(completion: (() -> Void)? = nil) {
        guard let current = Auth.auth().currentUser else {
            self.errorMessage = "No user logged in."
            completion?()
            return
        }

        current.reload { error in
            Task { @MainActor in
                if let error = error {
                    self.errorMessage = "Failed to refresh: \(error.localizedDescription)"
                } else {
                    // Refresh the user info after reload
                    let verified = current.isEmailVerified
                    self.user = UserInfo(
                        id: current.uid,
                        firstName: self.user?.firstName ?? "",
                        lastName: self.user?.lastName ?? "",
                        email: current.email ?? "",
                        verified: verified,
                        phoneNumber: self.user?.phoneNumber,
                        street: self.user?.street,
                        city: self.user?.city,
                        country: self.user?.country
                    )

                    // This is what allows the view to update properly
                    if verified {
                        self.errorMessage = "Email verified successfully!"
                    } else {
                        self.errorMessage = "Still not verified. Try again in a few seconds."
                    }
                }
                completion?()
            }
        }
    }

    func resendVerification() {
        service.resendVerification { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.errorMessage = "Verification email sent."
                case .failure(let err):
                    self?.errorMessage = err.localizedDescription
                }
            }
        }
    }

    func updateAddress(
            street: String?,
            city: String?,
            country: String?,
            phoneNumber: String?
        ) async throws {
            guard let uid = Auth.auth().currentUser?.uid else {
                throw NSError(domain: "", code: 401,
                              userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
            }

            // Build dictionary for updated fields
            var updates: [String: Any] = [:]
            if let street = street { updates["street"] = street }
            if let city = city { updates["city"] = city }
            if let country = country { updates["country"] = country }
            if let phoneNumber = phoneNumber { updates["phoneNumber"] = phoneNumber }

            // Save merged data into Firestore
            try await db.collection("users").document(uid).setData(updates, merge: true)

            // Refresh local user model
            if var existing = self.user {
                existing.street = street ?? existing.street
                existing.city = city ?? existing.city
                existing.country = country ?? existing.country
                existing.phoneNumber = phoneNumber ?? existing.phoneNumber
                self.user = existing
            } else {
                // If user not cached, fetch from Firestore
                try await fetchUserInfo()
            }
        }

    func logout() {
        let res = service.signOut()
        switch res {
        case .success:
            self.user = nil
        case .failure(let err):
            self.errorMessage = err.localizedDescription
        }
    }
    func fetchUserInfo() async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let doc = try await db.collection("users").document(uid).getDocument()
        if let data = try? doc.data(as: UserInfo.self) {
            self.user = data
        }
    }
}
    

