// AuthService.swift
import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestore

final class AuthService {
    static let shared = AuthService()
    private let db = Firestore.firestore()
    private init() {}

    // Sign up and create user doc in Firestore
    func signUp(firstName: String,
                lastName: String,
                email: String,
                password: String,
                completion: @escaping (Result<UserInfo, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let e = error { return completion(.failure(e)) }
            guard let firebaseUser = result?.user else {
                return completion(.failure(NSError(domain: "Auth", code: -1)))
            }

            let info = UserInfo(
                id: firebaseUser.uid,
                firstName: firstName,
                lastName: lastName,
                email: email,
                verified: firebaseUser.isEmailVerified,
                phoneNumber: nil,
                street: nil,
                city: nil,
                country: nil
            )

            do {
                try self.db.collection("users").document(firebaseUser.uid).setData(from: info) { err in
                    if let err = err { completion(.failure(err)); return }
                    // Send verification email and return info
                    firebaseUser.sendEmailVerification { _ in
                        completion(.success(info))
                    }
                }
            } catch {
                completion(.failure(error))
            }
        }
        
    }

    // Sign in
    func signIn(email: String, password: String, completion: @escaping (Result<UserInfo, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { res, err in
            if let e = err { return completion(.failure(e)) }
            guard let u = res?.user else {
                return completion(.failure(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user returned."])))
            }

            // dForce reload to get correct verification state
            u.reload { _ in
                self.fetchUserInfo(uid: u.uid) { result in
                    switch result {
                    case .success(let info):
                        var updated = info
                        updated.verified = u.isEmailVerified // Ensure up-to-date verification
                        completion(.success(updated))
                    case .failure(let err):
                        completion(.failure(err))
                    }
                }
            }
        }
    }

    // Sign out
    func signOut() -> Result<Void, Error> {
        do {
            try Auth.auth().signOut()
            return .success(())
        } catch {
            return .failure(error)
        }
    }

    // Resend verification
    func resendVerification(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else { return completion(.failure(NSError(domain: "Auth", code: -1))) }
        user.sendEmailVerification { error in
            if let e = error { completion(.failure(e)); return }
            completion(.success(()))
        }
    }

    // Fetch user doc from Firestore
    func fetchUserInfo(uid: String, completion: @escaping (Result<UserInfo, Error>) -> Void) {
        let ref = db.collection("users").document(uid)
        ref.getDocument { snapshot, err in
            if let e = err { return completion(.failure(e)) }
            do {
                if let doc = try snapshot?.data(as: UserInfo.self) {
                    completion(.success(doc))
                } else {
                    completion(.failure(NSError(domain: "Auth", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }

    // Update address/phone fields
    func updateUserAddress(uid: String,
                           phone: String?,
                           street: String?,
                           city: String?,
                           country: String?,
                           completion: @escaping (Result<Void, Error>) -> Void) {
        var data: [String: Any] = [:]
        if let v = phone { data["phoneNumber"] = v }
        if let v = street { data["street"] = v }
        if let v = city { data["city"] = v }
        if let v = country { data["country"] = v }

        db.collection("users").document(uid).updateData(data) { error in
            if let e = error { completion(.failure(e)); return }
            completion(.success(()))
        }
    }

    // Refresh firebase current user and return snapshot
    func refreshCurrentUser(completion: @escaping (Result<UserInfo, Error>) -> Void) {
        guard let firebaseUser = Auth.auth().currentUser else { return completion(.failure(NSError(domain: "Auth", code: -1))) }
        firebaseUser.reload { err in
            if let e = err { return completion(.failure(e)) }
            self.fetchUserInfo(uid: firebaseUser.uid, completion: completion)
        }
    }
}
