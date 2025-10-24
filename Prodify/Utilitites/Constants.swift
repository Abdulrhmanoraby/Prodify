//
//  Constants.swift
//  Prodify
//
//  Created by abdulrhman urabi on 20/10/2025.
//
import Foundation
enum Constants{
    static let shopDomain = "iosr2g3.myshopify.com"
   
    static let storeFrontAccessToken =  "4f22313fc9e3c591d0f0be44b2acd29d"
    
    static let AdminApiAccessToken = "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"
    
    static let APIKey = "8a679eadd548c0aebc56cc61440b1c39"
    
    static let APISecretKey = "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"
    
    static var storeFrontGraphQLEndpoint: URL{
        URL(string: "https://\(shopDomain)/api/2025-07/graphql.json")!
    }
   
    static let mainAccentColorHex = "#2B6CF3"
    
    static let adminAPIVersion = "2025-07"
    
    static var baseAdminURL: String {
           "https://\(shopDomain)/admin/api/\(adminAPIVersion)"
       }

}
