//
//  NetworkClient.swift
//  Prodify
//
//  Created by abdulrhman urabi on 20/10/2025.
//
import Foundation


final class NetworkClient {
    static let shared = NetworkClient()
    private init() {}

    func get<T: Decodable>(_ endpoint: String, type: T.Type) async throws -> T {
        guard let url = URL(string: endpoint) else { throw URLError(.badURL) }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Constants.AdminApiAccessToken, forHTTPHeaderField: "X-Shopify-Access-Token")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            let msg = String(data: data, encoding: .utf8) ?? "No message"
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: msg])
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}

