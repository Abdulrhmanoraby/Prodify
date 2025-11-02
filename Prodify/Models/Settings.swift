//
//  SettingsModel.swift
//  Prodify
//
//  Created by Ahmed Tarek on 29/10/2025.
//

import Foundation
import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable, Codable {
    case english = "English"
    case arabic = "العربية"
    
    var id: String { self.rawValue }
}

enum AppTheme: String, CaseIterable, Identifiable, Codable {
    case system, light, dark

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

struct Settings: Codable {
    var language: AppLanguage = .english
    var theme: AppTheme = .system
    var notificationsEnabled: Bool = true
    var permissions: [String: Bool] = [
        "Camera": false,
        "Location": false,
        "Photos": false
    ]
}
