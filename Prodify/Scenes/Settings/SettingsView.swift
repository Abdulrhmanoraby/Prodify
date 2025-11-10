
//  SettingsView.swift
//
//  Created by Ahmed Tarek on 05/11/2025.
//

import SwiftUI
import MapKit
import UserNotifications

struct SettingsView: View {
    @StateObject private var vm = SettingsViewModel()
    @ObservedObject private var localizer = LocalizationManager.shared

    @State private var showMapPicker = false
    @State private var showManualLocationSheet = false
    @State private var addressBuilding = ""
    @State private var addressStreet = ""
    @State private var addressCity = ""
    @State private var addressCountry = ""
    @State private var addressPhone = ""
    @State private var showingNotificationAlert = false
    @State private var showingLocationAlert = false

    var body: some View {
        NavigationStack {
            Form {
                // MARK: Notifications
                Section(header: Text(localizer.localizedString(for: "Notifications"))) {
                    Toggle(isOn: $vm.model.notificationsEnabled) {
                        Text(localizer.localizedString(for: "Enable Notifications"))
                    }
                    .onChange(of: vm.model.notificationsEnabled) { newValue in
                        if newValue {
                            showingNotificationAlert = true
                        } else {
                            vm.save()
                        }
                    }
                    .alert(localizer.localizedString(for: "Allow Notifications?"),
                           isPresented: $showingNotificationAlert) {
                        Button(localizer.localizedString(for: "Allow")) {
                            vm.askForNotificationPermission()
                        }
                        Button(localizer.localizedString(for: "Cancel"), role: .cancel) {
                            vm.model.notificationsEnabled = false
                            vm.save()
                        }
                    } message: {
                        Text(localizer.localizedString(for: "This app would like to send you notifications about your orders and promotions."))
                    }
                }

                // MARK: Theme
                Section(header: Text(localizer.localizedString(for: "Theme"))) {
                    Picker(localizer.localizedString(for: "Theme"), selection: $vm.model.theme) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Text(theme.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: vm.model.theme) { _ in vm.save() }
                }

                // MARK: Language
                Section(header: Text(localizer.localizedString(for: "Language"))) {
                    Picker(localizer.localizedString(for: "Language"), selection: $vm.model.language) {
                        Text("English").tag(AppLanguage.english)
                        Text("العربية").tag(AppLanguage.arabic)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: vm.model.language) { _ in
                        vm.save()
                        vm.applyLanguage()
                    }
                }

                // MARK: Location
                Section(header: Text(localizer.localizedString(for: "Address"))) {
                    VStack(alignment: .leading, spacing: 6) {
                        if !vm.model.addresses.isEmpty {
                            ForEach(vm.model.addresses) { addr in
                                HStack(alignment: .firstTextBaseline) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(addr.composed)
                                            .font(.subheadline)
                                        if !addr.phone.isEmpty {
                                            Text(localizer.localizedString(for: "Phone") + ": " + addr.phone)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    Spacer()
                                    if vm.model.selectedAddressID == addr.id {
                                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.tint)
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture { vm.selectAddress(id: addr.id) }
                            }
                            .onDelete { offsets in
                                vm.deleteAddress(at: offsets)
                            }
                        } else {
                            Text(vm.model.composedAddress?.isEmpty == false ? vm.model.composedAddress! : (vm.model.locationName ?? localizer.localizedString(for: "No location set")))
                                .font(.subheadline)
                            if let coord = vm.model.locationCoordinate {
                                Text(String(format: "Lat: %.4f, Lon: %.4f", coord.lat, coord.lon))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            if let phone = vm.model.addressPhone, !phone.isEmpty {
                                Text(localizer.localizedString(for: "Phone") + ": " + phone)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        HStack {
                            Spacer()
                            Menu {
                                Button(localizer.localizedString(for: "Use Current Location (Map)")) {
                                    showingLocationAlert = true
                                }
                                Button(localizer.localizedString(for: "Add Address Manually")) {
                                    addressBuilding = ""
                                    addressStreet = ""
                                    addressCity = ""
                                    addressCountry = ""
                                    addressPhone = ""
                                    showManualLocationSheet = true
                                }
                            } label: {
                                Label(localizer.localizedString(for: "Manage Addresses"), systemImage: "location.circle")
                            }
                            Spacer()
                        }
                    }
                }
                .alert(localizer.localizedString(for: "Allow Location Access?"), isPresented: $showingLocationAlert) {
                    Button(localizer.localizedString(for: "Allow")) {
                        vm.requestLocationFromSystem()
                        showMapPicker = true
                    }
                    Button(localizer.localizedString(for: "Cancel"), role: .cancel) {}
                }
                .sheet(isPresented: $showMapPicker) {
                    MapPickerView(viewModel: vm)
                }
                .sheet(isPresented: $showManualLocationSheet) {
                    NavigationStack {
                        Form {
                            Section(header: Text(localizer.localizedString(for: "Address Details"))) {
                                TextField(localizer.localizedString(for: "Building"), text: $addressBuilding)
                                TextField(localizer.localizedString(for: "Street"), text: $addressStreet)
                                TextField(localizer.localizedString(for: "City"), text: $addressCity)
                                TextField(localizer.localizedString(for: "Country"), text: $addressCountry)
                                TextField(localizer.localizedString(for: "Phone Number"), text: $addressPhone)
                                    .keyboardType(.phonePad)
                            }
                        }
                        .navigationTitle(localizer.localizedString(for: "Enter address"))
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button(localizer.localizedString(for: "Cancel")) {
                                    showManualLocationSheet = false
                                }
                            }
                            ToolbarItem(placement: .confirmationAction) {
                                Button(localizer.localizedString(for: "Save")) {
                                    vm.addManualAddress(
                                        building: addressBuilding,
                                        street: addressStreet,
                                        city: addressCity,
                                        country: addressCountry,
                                        phone: addressPhone
                                    )
                                    showManualLocationSheet = false
                                }.bold()
                            }
                        }
                    }
                }

                // MARK: Currency
                Section(header: Text(localizer.localizedString(for: "Currency"))) {
                    Picker(localizer.localizedString(for: "Currency"), selection: $vm.model.currency) {
                        Text("USD").tag("USD")
                        Text("EGP").tag("EGP")
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: vm.model.currency) { _ in
                        vm.save()
                        Task { await vm.updateCurrencyConversion() }
                    }

                    if let rate = vm.convertedRate, vm.model.currency == "EGP" {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(format: "💱 1 USD = %.2f EGP", rate))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            if let date = vm.conversionDate {
                                Text(localizer.localizedString(for: "As of") + " " + formattedDate(date))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 4)
                    }
                }
            }
            .navigationTitle(localizer.localizedString(for: "Settings"))
            .onAppear {
                vm.applyTheme()
                vm.applyLanguage()
                vm.detectCurrentCityIfNeeded()
                Task { await vm.updateCurrencyConversion() }
            }
        }
    }
}

// MARK: - Helper
private func formattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter.string(from: date)
}

#Preview {
    SettingsView()
}
