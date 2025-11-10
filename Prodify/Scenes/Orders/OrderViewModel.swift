import Foundation

@MainActor
final class OrderViewModel: ObservableObject {
    @Published var orders: [ShopifyOrder] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    // MARK: - Create new order in Shopify (COD or PayPal)
    func createOrder(
          products: [Product],
          email: String,
          address: String,
          paymentMethod: String,
          isSimulatedPayment: Bool = false
      ) async {
          guard !products.isEmpty else {
              errorMessage = "Cart is empty."
              return
          }

          let url = URL(string: "https://\(Constants.shopDomain)/admin/api/2025-07/orders.json")!
          var request = URLRequest(url: url)
          request.httpMethod = "POST"
          request.setValue("application/json", forHTTPHeaderField: "Content-Type")
          request.setValue(Constants.adminApiAccessToken, forHTTPHeaderField: "X-Shopify-Access-Token")

          // Build line items
          let lineItems = products.map { product in
              [
                  "title": product.title,
                  "quantity": 1,
                  "price": product.variants?.first?.price ?? "0.0"
              ]
          }

          //Payment simulation logic
          #if targetEnvironment(simulator)
          let isSimulator = true
          #else
          let isSimulator = false
          #endif

          let finalIsSimulated = isSimulatedPayment || isSimulator

          // Determine payment status
          let financialStatus: String
          if paymentMethod == "PayPal" {
              financialStatus = finalIsSimulated ? "paid" : "paid" // simulate real payment as 'paid'
          } else {
              financialStatus = "pending" // for Cash on Delivery
          }

          let gatewayName = (paymentMethod == "PayPal") ? "PayPal" : "Cash on Delivery"

          let body: [String: Any] = [
              "order": [
                  "email": email,
                  "send_receipt": true,
                  "send_fulfillment_receipt": true,
                  "financial_status": financialStatus,
                  "payment_gateway_names": [gatewayName],
                  "note": finalIsSimulated ? "Test order (Simulator Payment)" : "Real order",
                  "line_items": lineItems,
                  "shipping_address": [
                      "address1": address,
                      "first_name": "Prodify",
                      "last_name": "User",
                      "country": "Egypt"
                  ]
              ]
          ]

          do {
              request.httpBody = try JSONSerialization.data(withJSONObject: body)
              let (data, response) = try await URLSession.shared.data(for: request)

              guard let http = response as? HTTPURLResponse else {
                  throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
              }

              if http.statusCode == 201 {
                  let created = try JSONDecoder().decode([String: ShopifyOrder].self, from: data)
                  if let order = created["order"] {
                      orders.append(order)
                      successMessage = " Order placed successfully! Confirmation email sent."
                      print(" Shopify order created successfully (Status: \(financialStatus))")
                  } else {
                      errorMessage = "Order created but could not parse order object."
                  }
              } else {
                  let msg = String(data: data, encoding: .utf8) ?? "Unknown error"
                  let status = http.statusCode
                  throw NSError(domain: "", code: status, userInfo: [NSLocalizedDescriptionKey: msg])
              }

          } catch {
              errorMessage = "Failed to create order: \(error.localizedDescription)"
              print("Shopify order creation failed: \(error.localizedDescription)")
          }
      }

    // MARK: - Fetch orders for current user
    func fetchOrders(for email: String) async {
        isLoading = true
        defer { isLoading = false }

        guard let url = URL(string: "https://\(Constants.shopDomain)/admin/api/2025-07/orders.json?email=\(email)") else {
            errorMessage = "Invalid URL"
            return
        }

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
            self.orders = decoded.orders.sorted(by: { $0.created_at ?? "" > $1.created_at ?? "" })

        } catch {
            errorMessage = "Failed to fetch orders: \(error.localizedDescription)"
        }
    }
}
