//
//  CurrencyManager.swift
//  Settings2
//
//  Created by Ahmed Tarek on 05/11/2025.
//

import Foundation
import Combine

final class CurrencyManager: ObservableObject {
    static let shared = CurrencyManager()
    @Published private(set) var currentCurrency: String = "USD"
    @Published private(set) var conversionRate: Double = 1.0

    private var currencyCode: String { currentCurrency }

    private init() {}

    /// Update current currency and rate. `rate` must be the value of 1 USD in the selected currency.
    func update(currency: String, rate: Double) {
        currentCurrency = currency
        conversionRate = rate
    }

    func convertPrice(_ usdPrice: Double) -> Double {
        if currentCurrency == "EGP" { return usdPrice * conversionRate }
        return usdPrice
    }

    func formatPrice(fromUSD usdPrice: Double, minimumFractionDigits: Int = 2, maximumFractionDigits: Int = 2) -> String {
        let converted = convertPrice(usdPrice)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.minimumFractionDigits = minimumFractionDigits
        formatter.maximumFractionDigits = maximumFractionDigits

        if let formatted = formatter.string(from: NSNumber(value: converted)) {
            return formatted
        } else {
            // Fallback formatting if NumberFormatter fails
            return "\(converted) \(currencyCode)"
        }
    }
}
