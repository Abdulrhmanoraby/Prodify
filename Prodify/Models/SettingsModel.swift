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


struct SettingsModel: Codable {
    var notificationsEnabled: Bool = false
    var theme: AppTheme = .system
    var language: AppLanguage = .english
    var locationName: String? = nil
    var locationCoordinate: LocationCoordinate? = nil
    var currency: String = "USD"
}


