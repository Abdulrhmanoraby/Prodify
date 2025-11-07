//
//  PayPalConfig.swift
//  Prodify
//
//  Created by abdulrhman urabi on 04/11/2025.
//

//
//  PayPalConfig.swift
//  Prodify
//
//
//  PayPalConfig.swift
//  Prodify
//

import Foundation
import PayPalCheckout

class PayPalConfig {
    static func configure() {
        // SANDBOX Configuration
        let config = CheckoutConfig(
            clientID: "AYr_jjlCOlxBGThrQlWX4L6ySOWwtgcLTHtRkp3fFw93T43iYMPrLz9-U3Mhm_FIAmgMrCHcPk0kvOAI", // Replace with your PayPal sandbox client ID
            returnUrl: "prodify://paypalpay",
            environment: .sandbox
        )
        
        Checkout.set(config: config)
        print("PayPal SDK configured for SANDBOX mode")
    }
}
