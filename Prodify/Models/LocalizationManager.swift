//
//  LocalizationManager.swift
//  Settings2
//
//  Created by Ahmed Tarek on 05/11/2025.
//

import SwiftUI
import Combine

final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    private init() {}

    @AppStorage("selectedLanguage") var selectedLanguage: String = "en" {
        didSet { reloadBundle() }
    }

    @Published var bundle: Bundle = .main

    func reloadBundle() {
        guard let path = Bundle.main.path(forResource: selectedLanguage, ofType: "lproj"),
              let newBundle = Bundle(path: path) else {
            bundle = .main
            return
        }
        bundle = newBundle

        // Change layout direction dynamically
        if selectedLanguage == "ar" {
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        } else {
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }

        // Notify views to refresh
        objectWillChange.send()
    }

    func localizedString(for key: String) -> String {
        NSLocalizedString(key, bundle: bundle, comment: "")
    }
}

