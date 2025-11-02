//
//  SettingsService.swift
//  Prodify
//
//  Created by Ahmed Tarek on 29/10/2025.
//

import Foundation

protocol SettingsServiceProtocol {
    func load() -> Settings
    func save(_ settings: Settings)
}

final class SettingsService: SettingsServiceProtocol {
    private let defaultsKey = "app.settings"
    private let defaults = UserDefaults.standard
    
    func load() -> Settings {
        if let data = defaults.data(forKey: defaultsKey),
           let settings = try? JSONDecoder().decode(Settings.self, from: data) {
            return settings
        }
        return Settings()
    }
    
    func save(_ settings: Settings) {
        if let data = try? JSONEncoder().encode(settings) {
            defaults.set(data, forKey: defaultsKey)
        }
    }
}
