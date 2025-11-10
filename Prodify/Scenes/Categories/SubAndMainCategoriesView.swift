//
//  SubAndMainCategoriesView.swift
//  Prodify
//
//  Created by abdulrhman urabi on 25/10/2025.
//

import SwiftUI

struct SubAndMainCategoriesView: View {
    // MARK: - Temporary mock data
    @StateObject private var vm = CategoriesViewModel()
    @State private var selectedSub: String = "All"
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    
    var body: some View {
        // MARK: - Main Categories chips
        VStack(alignment: .leading) {
            
            // MARK: - Main Categories chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Button {
                        vm.selectedCategory = nil
                        Task { await vm.applyFilters(subCategory: selectedSub) }
                    } label: {
                        Text("All")
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(vm.selectedCategory == nil ? Color.black.opacity(0.2) : Color(.systemGray6))
                            .cornerRadius(20)
                    }
                    ForEach(vm.categories) { category in
                        Button {
                            vm.selectedCategory = category
                            Task { await vm.applyFilters(subCategory: selectedSub) }
                        } label: {
                            Text(category.title)
                                .foregroundColor(.black)
                                .font(.subheadline)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    vm.selectedCategory?.title == category.title ?
                                    Color.black.opacity(0.2) :
                                        Color(.systemGray6)
                                )
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top, 4)
            
            
            // MARK: - Subcategory picker
            HStack {
                Spacer()
                Picker("Subcategory", selection: $selectedSub) {
                    ForEach(vm.allProductTypes, id: \.self) { sub in
                        Text(sub).tag(sub)
                    }
                }
                .onChange(of: selectedSub) { newValue in
                    Task { await vm.applyFilters(subCategory: newValue) }
//                    vm.selectedSubCategory = newValue
//                    vm.applyFilters()
                }
                .pickerStyle(.menu)
                .tint(.blue)
                .padding(.trailing)
                
            }
            if vm.isLoading {
                ProgressView("Loading categories...")
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if let error = vm.errorMessage {
                Text("\(error)").foregroundColor(.red)
            } else { ProductsGridView(products: vm.filteredProducts,isLoading: vm.isLoading,errorMessage: vm.errorMessage)
            }
        }//end of Vstack
        .task{
            // only load once when categories are empty
            if vm.categories.isEmpty {
                do {
                    try await vm.loadCategories()
                } catch {
                    print("Error: \(error)")
                }
            }
            if vm.allProductTypes.isEmpty {
                try? await vm.loadAllProductTypes()
                }
            if vm.allProducts.isEmpty {
                    try? await vm.loadAllProducts()
                }
        }
        
    }
}

#Preview {
    SubAndMainCategoriesView()
}
