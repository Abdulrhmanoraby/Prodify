//
//  HomeViewModel.swift
//  Prodify
//
//  Created by abdulrhman urabi on 20/10/2025.
//
import Foundation
@MainActor
final class HomeViewModel: ObservableObject {
    @Published var vendors: [String] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service = ShopifyService.shared

    func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            vendors = try await service.fetchVendors()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    
}

