//
//  ProdifyApp.swift
//  Prodify
//
//  Created by abdulrhman urabi on 20/10/2025.
//

import SwiftUI
import FirebaseCore
@main
struct ProdifyApp: App {
    @StateObject private var cartVM = CartViewModel()
    @StateObject private var orderVM = OrderViewModel()
    @StateObject private var vm = SettingsViewModel()
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {


            MainTabView()
                .environmentObject(cartVM)
                .environmentObject(orderVM)
                .environmentObject(vm)


        }
    }
}
