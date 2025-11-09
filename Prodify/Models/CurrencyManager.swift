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

    private init() {}

    func update(currency: String, rate: Double) {
        currentCurrency = currency
        conversionRate = rate
    }

    func convertPrice(_ usdPrice: Double) -> Double {
        if currentCurrency == "EGP" { return usdPrice * conversionRate }
        return usdPrice
    }
}
