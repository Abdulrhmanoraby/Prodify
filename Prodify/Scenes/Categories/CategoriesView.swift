//
//  CategoriesView.swift
//  Prodify
//
//  Created by Abdulrhman on 2025-10-25.
//

import SwiftUI

struct CategoriesView: View {
  
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                
  //Categories Bar view
                CategoriesBar()

//sub and main categories filters view
                SubAndMainCategoriesView()

                // MARK: - Placeholder for filtered products
                Spacer()
                VStack(spacing: 8) {
                   
                }
                Spacer()
            }
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    CategoriesView()
}
