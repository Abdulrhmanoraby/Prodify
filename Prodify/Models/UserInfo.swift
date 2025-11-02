//
//  User.swift
//  Prodify
//
//  Created by abdulrhman urabi on 20/10/2025.
//



import Foundation


// small app-facing user model
struct UserInfo: Codable, Identifiable {
    var id: String
    var firstName: String
    var lastName: String
    var email: String?
    var verified: Bool
}
