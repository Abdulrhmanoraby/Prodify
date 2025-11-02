//
//  SettingsViewModel.swift
//  Prodify
//
//  Created by Ahmed Tarek on 29/10/2025.
//

import Foundation
import Combine

final class SettingsViewModel: ObservableObject {
    @Published var settings: Settings
    
    private let service: SettingsServiceProtocol
    
    init(service: SettingsServiceProtocol = SettingsService()) {
        self.service = service
        self.settings = service.load()
    }
    
    // MARK: - Intents
    func toggleNotification() {
        settings.notificationsEnabled.toggle()
        save()
    }
    
    func updateLanguage(_ newLanguage: AppLanguage) {
        settings.language = newLanguage
        save()
    }
    
    func updateTheme(_ newTheme: AppTheme) {
        var copy = settings
        copy.theme = newTheme
        settings = copy
        save()
    }
    
    func togglePermission(_ key: String) {
        settings.permissions[key]?.toggle()
        save()
    }
    
    private func save() {
        service.save(settings)
    }
}
