//
//  User.swift
//  Prodify
//
//  Created by abdulrhman urabi on 20/10/2025.
//



import Foundation
import FirebaseFirestore

struct UserInfo: Identifiable, Codable {
    @DocumentID var id: String?
    var firstName: String
    var lastName: String
    var email: String
    var verified: Bool
    
   
    var phoneNumber: String?
    var street: String?
    var city: String?
    var country: String?
    
   
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    init(
        id: String? = nil,
        firstName: String,
        lastName: String,
        email: String,
        verified: Bool,
        phoneNumber: String? = nil,
        street: String? = nil,
        city: String? = nil,
        country: String? = nil
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.verified = verified
        self.phoneNumber = phoneNumber
        self.street = street
        self.city = city
        self.country = country
    }
}
