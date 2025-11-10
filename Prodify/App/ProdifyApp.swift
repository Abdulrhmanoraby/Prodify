//
//  ProdifyApp.swift
//  Prodify
//
//  Created by abdulrhman urabi on 20/10/2025.
//

import SwiftUI
import FirebaseCore
import PayPalCheckout

@main
struct ProdifyApp: App {
    @StateObject private var cartVM = CartViewModel()
    @StateObject private var orderVM = OrderViewModel()
    @StateObject private var vm = SettingsViewModel()
    @StateObject private var authVM = AuthViewModel()
     @StateObject private var currencyManager = CurrencyManager.shared
    init() {
        FirebaseApp.configure()
        PayPalConfig.configure()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(cartVM)
                .environmentObject(orderVM)
                .environmentObject(vm)
                .environmentObject(authVM)
                .modelContainer(for: [FavoriteProduct.self])
                .environmentObject(currencyManager)
        }
    }
}

