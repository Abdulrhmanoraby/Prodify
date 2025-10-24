//
//  AuthService.swift
//  Prodify
//
//  Created by abdulrhman urabi on 20/10/2025.
//

import Foundation
import FirebaseAuth

final class AuthService {
    static let shared = AuthService()
    private init() {}

    // sign up + send verification automatically (Firebase does automatically on create)
    func signUp(email: String, password: String, completion: @escaping (Result<UserInfo, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let e = error { return completion(.failure(e)) }
            guard let user = result?.user else {
                return completion(.failure(NSError(domain: "Auth", code: -1)))
            }
            // send verification (optional - Firebase sometimes auto-sends)
            user.sendEmailVerification { _ in
                let info = UserInfo(id: user.uid, email: user.email, verified: user.isEmailVerified)
                completion(.success(info))
            }
        }
    }

    // sign in
    func signIn(email: String, password: String, completion: @escaping (Result<UserInfo, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let e = error { return completion(.failure(e)) }
            guard let user = result?.user else {
                return completion(.failure(NSError(domain: "Auth", code: -1)))
            }
            // reload to get latest verification state
            user.reload { _ in
                let info = UserInfo(id: user.uid, email: user.email, verified: user.isEmailVerified)
                completion(.success(info))
            }
        }
    }

    // resend verification
    func resendVerification(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            return completion(.failure(NSError(domain: "Auth", code: -1)))
        }
        user.sendEmailVerification { error in
            if let e = error { completion(.failure(e)); return }
            completion(.success(()))
        }
    }

    // sign out
    func signOut() -> Result<Void, Error> {
        do { try Auth.auth().signOut(); return .success(()) }
        catch { return .failure(error) }
    }

    // current user (simple snapshot)
    func currentUser() -> UserInfo? {
        guard let u = Auth.auth().currentUser else { return nil }
        return UserInfo(id: u.uid, email: u.email, verified: u.isEmailVerified)
    }
}

import FirebaseAuth

extension AuthService {
    // Reload the Firebase current user from server and return updated UserInfo (via completion)
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
            // after reload, build the UserInfo snapshot
            let info = UserInfo(id: firebaseUser.uid, email: firebaseUser.email, verified: firebaseUser.isEmailVerified)
            completion(.success(info))
        }
    }
}


