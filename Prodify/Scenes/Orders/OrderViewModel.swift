//
//  OrderViewModel.swift
//  Prodify
//
//  Created by Abdulrhman Urabi on 28/10/2025.
//

import Foundation

@MainActor
final class OrderViewModel: ObservableObject {
    @Published var orders: [ShopifyOrder] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    // MARK: - Create new order in Shopify (triggers confirmation mail)
    func createOrder(products: [Product], email: String, address: String) async {
        guard !products.isEmpty else {
            errorMessage = "Cart is empty."
            return
        }

        let url = URL(string: "https://\(Constants.shopDomain)/admin/api/2025-07/orders.json")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Constants.adminApiAccessToken, forHTTPHeaderField: "X-Shopify-Access-Token")

        // Build line_items from our Product model
        let lineItems = products.map { product in
            [
                "title": product.title,
                "quantity": 1,
                "price": product.variants?.first?.price ?? "0.0"
            ]
        }

        // Create JSON body
        let body: [String: Any] = [
            "order": [
                "email": email,
                "send_receipt": true,   // triggers confirmation mail
                "send_fulfillment_receipt": true,
                "financial_status": "pending", // order created but not paid
                "line_items": lineItems,
                "shipping_address": [
                    "address1": address,
                    "first_name": "Test",
                    "last_name": "User",
                    "country": "Egypt"
                ]
            ]
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let http = response as? HTTPURLResponse, http.statusCode == 201 else {
                let msg = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: msg])
            }

            let createdOrder = try JSONDecoder().decode([String: ShopifyOrder].self, from: data)["order"]
            if let createdOrder {
                orders.append(createdOrder)
                successMessage = "Order placed successfully! Confirmation email sent."
            }

        } catch {
            errorMessage = "Failed to create order: \(error.localizedDescription)"
        }
    }

    // MARK: - Fetch orders for the signed-in user
    func fetchOrders(for email: String) async {
        isLoading = true
        defer { isLoading = false }

        let url = URL(string: "https://\(Constants.shopDomain)/admin/api/2025-07/orders.json?email=\(email)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Constants.adminApiAccessToken, forHTTPHeaderField: "X-Shopify-Access-Token")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                let msg = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: msg])
            }

            let decoded = try JSONDecoder().decode(ShopifyOrdersResponse.self, from: data)
            self.orders = decoded.orders
        } catch {
            errorMessage = "Failed to fetch orders: \(error.localizedDescription)"
        }
    }
}
