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
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {


            MainTabView()


        }
    }
}
