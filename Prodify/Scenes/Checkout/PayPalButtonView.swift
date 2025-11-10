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
                print("Starting PayPal checkout...")

                let amount = PurchaseUnit.Amount(currencyCode: .usd, value: parent.amount)
                let unit = PurchaseUnit(amount: amount)
                let order = OrderRequest(intent: .capture, purchaseUnits: [unit])

                Checkout.start(
                    createOrder: { action in
                        print("Creating PayPal order...")
                        action.create(order: order)
                    },
                    onApprove: { approval in
                        print("PayPal payment approved")

                        #if targetEnvironment(simulator)
                        // Simulator shortcut
                        print("Simulator detected — simulating success")
                        Task { await MainActor.run { self.parent.onOrderCreated() } }
                        #else
                        approval.actions.capture { (response, error) in
                            if let error = error {
                                print("Capture failed: \(error.localizedDescription)")
                                self.parent.onError(error)
                                return
                            }
                            print("💰 PayPal payment captured successfully")
                            Task { await MainActor.run { self.parent.onOrderCreated() } }
                        }
                        #endif
                    },
                    onCancel: {
                        print("User cancelled payment")
                        let err = NSError(domain: "PayPal", code: -1,
                                          userInfo: [NSLocalizedDescriptionKey: "User cancelled payment"])
                        self.parent.onError(err)
                    },
                    onError: { error in
                        print("PayPal SDK Error: \(error)")
                        let nsError = NSError(
                            domain: "PayPalSDK",
                            code: -2,
                            userInfo: [NSLocalizedDescriptionKey: String(describing: error)]
                        )
                        self.parent.onError(nsError)
                    }
                )
            }
        }
}
