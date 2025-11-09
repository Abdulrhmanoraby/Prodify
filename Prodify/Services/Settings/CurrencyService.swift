//
//  CurrencyService.swift
//  Settings2
//
//  Created by Ahmed Tarek on 05/11/2025.
//

import Foundation

enum CurrencyError: Error {
    case invalidURL
    case network(Error)
    case decoding(Error)
    case missingData
}

final class CurrencyService {
    static let shared = CurrencyService()
    private init() {}

    // ✅ Convert method using open.er-api.com
    func convert(amount: Double, from: String, to: String) async throws -> Double {
        guard let url = URL(string: "https://open.er-api.com/v6/latest/\(from)") else {
            throw CurrencyError.invalidURL
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw CurrencyError.missingData
            }

            // Optional: print for debugging
            if let json = String(data: data, encoding: .utf8) {
                print("🔍 API Response:", json)
            }

            let decoded = try JSONDecoder().decode(OpenERResponse.self, from: data)
            if let rate = decoded.rates[to] {
                return rate * amount
            } else {
                throw CurrencyError.missingData
            }

        } catch {
            if let e = error as? DecodingError {
                throw CurrencyError.decoding(e)
            } else {
                throw CurrencyError.network(error)
            }
        }
    }
}

// MARK: - Response Model
private struct OpenERResponse: Codable {
    let result: String
    let base_code: String
    let rates: [String: Double]
}
