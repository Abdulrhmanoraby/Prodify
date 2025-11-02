//
//  AuthService.swift
//  Prodify
//
//  Created by abdulrhman urabi on 20/10/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class AuthService {
    static let shared = AuthService()
    private let db = Firestore.firestore()
    private init() {}

    // MARK: - Sign Up and Save User Info
    func signUp(firstName: String, lastName: String, email: String, password: String, completion: @escaping (Result<UserInfo, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let e = error { return completion(.failure(e)) }
            guard let user = result?.user else {
                return completion(.failure(NSError(domain: "Auth", code: -1)))
            }

            user.sendEmailVerification { _ in
                // build model
                let userInfo = UserInfo(
                    id: user.uid,
                    firstName: firstName,
                    lastName: lastName,
                    email: user.email ?? email,
                    verified: user.isEmailVerified
                )

                // store in Firestore
                do {
                    try self.db.collection("users").document(user.uid).setData(from: userInfo)
                    completion(.success(userInfo))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }

    // MARK: - Sign In (Fetch User Info from Firestore)
    func signIn(email: String, password: String, completion: @escaping (Result<UserInfo, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let e = error { return completion(.failure(e)) }
            guard let user = result?.user else {
                return completion(.failure(NSError(domain: "Auth", code: -1)))
            }

            user.reload { _ in
                let docRef = self.db.collection("users").document(user.uid)
                docRef.getDocument { snapshot, err in
                    if let err = err { return completion(.failure(err)) }

                    if let snapshot = snapshot, snapshot.exists {
                        do {
                            var fetched = try snapshot.data(as: UserInfo.self)
                            fetched.verified = user.isEmailVerified // ensure real-time verified state
                            completion(.success(fetched))
                        } catch {
                            completion(.failure(error))
                        }
                    } else {
                        // fallback if Firestore record not found
                        let fallback = UserInfo(
                            id: user.uid,
                            firstName: "",
                            lastName: "",
                            email: user.email ?? email,
                            verified: user.isEmailVerified
                        )
                        completion(.success(fallback))
                    }
                }
            }
        }
    }

    // MARK: - Resend Verification
    func resendVerification(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            return completion(.failure(NSError(domain: "Auth", code: -1)))
        }
        user.sendEmailVerification { error in
            if let e = error { completion(.failure(e)); return }
            completion(.success(()))
        }
    }

    // MARK: - Sign Out
    func signOut() -> Result<Void, Error> {
        do { try Auth.auth().signOut(); return .success(()) }
        catch { return .failure(error) }
    }

    // MARK: - Current User Snapshot
    func currentUser(completion: @escaping (Result<UserInfo, Error>) -> Void) {
        guard let u = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No signed-in user"])))
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(u.uid).getDocument { snapshot, error in
            if let err = error {
                completion(.failure(err))
                return
            }

            let data = snapshot?.data()
            let firstName = data?["firstName"] as? String ?? ""
            let lastName = data?["lastName"] as? String ?? ""
            let email = data?["email"] as? String ?? u.email ?? ""

            let info = UserInfo(
                id: u.uid,
                firstName: firstName,
                lastName: lastName,
                email: email,
                verified: u.isEmailVerified
            )

            completion(.success(info))
        }
    }

    // MARK: - Refresh Current User
    func refreshCurrentUser(completion: @escaping (Result<UserInfo, Error>) -> Void) {
        guard let firebaseUser = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No signed-in user"])))
            return
        }

        firebaseUser.reload { error in
            if let err = error {
                completion(.failure(err))
                return
            }

            // Fetch latest Firestore user info
            self.db.collection("users").document(firebaseUser.uid).getDocument { snapshot, err in
                if let err = err { return completion(.failure(err)) }
                if let snapshot = snapshot, snapshot.exists {
                    do {
                        var info = try snapshot.data(as: UserInfo.self)
                        info.verified = firebaseUser.isEmailVerified
                        completion(.success(info))
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    let info = UserInfo(id: firebaseUser.uid, firstName: "", lastName: "", email: firebaseUser.email, verified: firebaseUser.isEmailVerified)
                    completion(.success(info))
                }
            }
        }
    }
}
