//
//  SettingsView.swift
//  Prodify
//
//  Created by Ahmed Tarek on 29/10/2025.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var vm: SettingsViewModel
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - Language
                Section(header: Text("Language")) {
                    Picker("App Language", selection: $vm.settings.language) {
                        ForEach(AppLanguage.allCases, id: \.id) { lang in
                            Text(lang.rawValue).tag(lang)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    .onChange(of: vm.settings.language) { newLang in
                        vm.updateLanguage(newLang)
                    }
                }
                
                // MARK: - Theme
                Section(header: Text("Theme")) {
                    Picker("Appearance", selection: $vm.settings.theme) {
                        ForEach(AppTheme.allCases, id: \.id) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: vm.settings.theme) { newTheme in
                        vm.updateTheme(newTheme)
                    }
                }
                
                // MARK: - Notifications
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: $vm.settings.notificationsEnabled)
                        .onChange(of: vm.settings.notificationsEnabled) { _ in
                            vm.toggleNotification()
                        }
                }
                
                // MARK: - Permissions
                Section(header: Text("Permissions")) {
                    ForEach(vm.settings.permissions.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        Toggle(key, isOn: Binding(
                            get: { value },
                            set: { _ in vm.togglePermission(key) }
                        ))
                    }
                }
                
                // MARK: - Legal & About
                Section(header: Text("Legal & About")) {
                    NavigationLink(destination: AboutView()) {
                        Label("About App", systemImage: "info.circle")
                    }
                    NavigationLink(destination: LegalView()) {
                        Label("Terms & Privacy", systemImage: "doc.text")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

// MARK: - Simple Subpages
struct AboutView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Shopify App")
                .font(.largeTitle).bold()
            Text("Version 1.0.0")
                .foregroundColor(.secondary)
            Text("Developed by Your Name")
        }
        .padding()
        .navigationTitle("About")
    }
}

struct LegalView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Terms of Service")
                    .font(.title2).bold()
                Text("Here you can write your app’s terms and conditions...")
                
                Text("Privacy Policy")
                    .font(.title2).bold()
                Text("Here you can describe how user data is handled...")
            }
            .padding()
        }
        .navigationTitle("Legal")
    }
}

#Preview {
    SettingsView()
}
