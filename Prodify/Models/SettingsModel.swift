//
//  SettingsModel.swift
//  Settings2
//
//  Created by Ahmed Tarek on 05/11/2025.
//


import Foundation

struct LocationCoordinate: Codable {
    var lat: Double
    var lon: Double
}

enum AppTheme: String, CaseIterable, Codable {
    case system, light, dark
}

enum AppLanguage: String, Codable, CaseIterable {
    case english = "en"
    case arabic = "ar"

    var displayName: String {
        switch self {
        case .english: return "English"
        case .arabic: return "العربية"
        }
    }

    var locale: Locale {
        Locale(identifier: rawValue)
    }
}

struct Address: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var building: String
    var street: String
    var city: String
    var country: String
    var phone: String

    var composed: String {
        [building, street, city, country]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }
}

struct SettingsModel: Codable {
    var notificationsEnabled: Bool = false
    var theme: AppTheme = .system
    var language: AppLanguage = .english
    var locationName: String? = nil
    var locationCoordinate: LocationCoordinate? = nil
    var addressBuilding: String? = nil
    var addressStreet: String? = nil
    var addressCity: String? = nil
    var addressCountry: String? = nil
    var addressPhone: String? = nil
    var currency: String = "USD"

    var addresses: [Address] = []
    var selectedAddressID: UUID? = nil
}

extension SettingsModel {
    var composedAddress: String? {
        let parts = [addressBuilding, addressStreet, addressCity, addressCountry]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }
}

extension SettingsModel {
    var selectedAddress: Address? {
        guard let id = selectedAddressID else { return nil }
        return addresses.first(where: { $0.id == id })
    }

    mutating func migrateLegacyAddressIfNeeded() {
        // If we have legacy fields but no addresses stored, create one entry
        if addresses.isEmpty,
           let b = addressBuilding, let s = addressStreet, let c = addressCity, let co = addressCountry {
            let p = addressPhone ?? ""
            let addr = Address(building: b, street: s, city: c, country: co, phone: p)
            addresses = [addr]
            selectedAddressID = addr.id
        }
    }
}
