//
//  MainTabView.swift
//  Prodify
//
//  Created by abdulrhman urabi on 22/10/2025.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            CategoriesView()
                .tabItem {
                    Label("Categories", systemImage: "square.grid.2x2")
                }

            MeView()
                .tabItem {
                    Label("Me", systemImage: "person.circle")
                }
        }
        .tint(.black)
    }
}
