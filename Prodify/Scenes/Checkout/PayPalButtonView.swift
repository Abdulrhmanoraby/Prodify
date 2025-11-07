//
//  PayPalButtonView.swift
//  Prodify
//

import SwiftUI
import PayPalCheckout

struct PayPalButtonView: UIViewRepresentable {
    let amount: String
    let cartProducts: [Product]
    let address: String
    let email: String
    let onOrderCreated: () -> Void
    let onError: (Error) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Pay with PayPal", for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 8
        button.addTarget(context.coordinator, action: #selector(Coordinator.startCheckout), for: .touchUpInside)
        return button
    }

    func updateUIView(_ uiView: UIButton, context: Context) {}

    // MARK: - Coordinator
    final class Coordinator: NSObject {
        let parent: PayPalButtonView
        init(_ parent: PayPalButtonView) { self.parent = parent }

        @objc func startCheckout() {
            print("🟦 Starting PayPal checkout...")

            let amount = PurchaseUnit.Amount(currencyCode: .usd, value: parent.amount)
            let unit = PurchaseUnit(amount: amount)
            let order = OrderRequest(intent: .capture, purchaseUnits: [unit])

            Checkout.start(
                createOrder: { action in
                    print("Creating PayPal order...")
                    action.create(order: order)
                },
                onApprove: { approval in
                    print("Payment approved by user")

                    #if targetEnvironment(simulator)
                    // Simulator path — PayPal sandbox doesn’t open full web flow here
                    print("Simulator detected: Simulating successful PayPal capture")
                    Task {
                        do {
                            try await self.createShopifyOrder()
                            await MainActor.run {
                                self.parent.onOrderCreated()
                            }
                        } catch {
                            self.parent.onError(error)
                        }
                    }
                    #else
                    // Real device: capture PayPal payment first
                    print("Capturing PayPal payment...")
                    approval.actions.capture { (response, error) in
                        if let error = error {
                            print("Capture failed: \(error.localizedDescription)")
                            self.parent.onError(error)
                            return
                        }
                        guard let response = response else {
                            let err = NSError(domain: "PayPal", code: 0, userInfo: [NSLocalizedDescriptionKey: "No capture response"])
                            self.parent.onError(err)
                            return
                        }
                        print("✅ PayPal payment captured successfully:")
                        dump(response)

                        // After successful PayPal payment, create Shopify order
                        Task {
                            do {
                                try await self.createShopifyOrder()
                                await MainActor.run {
                                    self.parent.onOrderCreated()
                                }
                            } catch {
                                self.parent.onError(error)
                            }
                        }
                    }
                    #endif
                },
                onCancel: {
                    print("User cancelled the PayPal payment")
                    let err = NSError(domain: "PayPal", code: -1, userInfo: [NSLocalizedDescriptionKey: "User cancelled payment"])
                    self.parent.onError(err)
                },
                onError: { error in
                    print("PayPal SDK Error: \(error)")
                    if let err = error as? Error {
                        self.parent.onError(err)
                    } else {
                        let nsError = NSError(domain: "PayPalSDK", code: -2, userInfo: [NSLocalizedDescriptionKey: String(describing: error)])
                        self.parent.onError(nsError)
                    }
                }
            )
        }

        // MARK: - Create Shopify Order after payment
        private func createShopifyOrder() async throws {
            print("Creating Shopify order...")

            let url = URL(string: "https://\(Constants.shopDomain)/admin/api/2025-07/orders.json")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(Constants.adminApiAccessToken, forHTTPHeaderField: "X-Shopify-Access-Token")

            let lineItems = parent.cartProducts.map { product in
                [
                    "title": product.title,
                    "quantity": 1,
                    "price": product.variants?.first?.price ?? "0.0"
                ]
            }

            let body: [String: Any] = [
                "order": [
                    "email": parent.email,
                    "send_receipt": true,
                    "send_fulfillment_receipt": true,
                    "financial_status": "paid",
                    "payment_gateway_names": ["PayPal"],
                    "line_items": lineItems,
                    "shipping_address": [
                        "address1": parent.address,
                        "first_name": "Prodify",
                        "last_name": "User",
                        "country": "Egypt"
                    ]
                ]
            ]

            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
            }

            if http.statusCode == 201 {
                print("Shopify order created successfully")
            } else {
                let msg = String(data: data, encoding: .utf8) ?? "Unknown error"
                print("Shopify order creation failed: \(msg)")
                throw NSError(domain: "", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: msg])
            }
        }
    }
}
