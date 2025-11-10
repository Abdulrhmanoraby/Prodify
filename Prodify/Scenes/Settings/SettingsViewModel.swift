//
//  SettingsViewModel.swift
//  Settings2
//
//  Created by Ahmed Tarek on 05/11/2025.
//

import Combine
import SwiftUI
import CoreLocation
import UserNotifications

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var model: SettingsModel
    @Published var convertedRate: Double? = nil
    @Published var showNotificationAlert = false
    @Published var showLocationAlert = false
    @Published var manualAddress = ""
    @Published var liveAddress: String? = nil // ✅ live update while dragging the pin
    @Published var conversionDate: Date? = nil   // ✅ new
    var saveAddressToUserProfile: ((String, String, String, String, String) -> Void)? = nil

    private let defaultsKey = "ShopifySettings_v1"
    private let geocoder = CLGeocoder()

    init() {
        if let data = UserDefaults.standard.data(forKey: defaultsKey),
           let saved = try? JSONDecoder().decode(SettingsModel.self, from: data) {
            self.model = saved
        } else {
            self.model = SettingsModel()
        }
        self.model.migrateLegacyAddressIfNeeded()
    }
    // TODO: Ensure SettingsModel has addressBuilding, addressStreet, addressCity, addressCountry, addressPhone, and optionally a computed composedAddress

    func save() {
        if let data = try? JSONEncoder().encode(model) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
        applyTheme()
        applyLanguage()
    }

    // MARK: - Notifications
    func askForNotificationPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                DispatchQueue.main.async {
                    self.model.notificationsEnabled = granted
                    self.save()
                }
            }
    }

    // MARK: - Location
    func requestLocationFromSystem() {
        LocationService.shared.requestWhenInUse { location in
            guard let loc = location else {
                DispatchQueue.main.async {
                    self.model.locationName = nil
                    self.model.locationCoordinate = nil
                    self.save()
                }
                return
            }
            self.updateLocationName(for: loc.coordinate)
            DispatchQueue.main.async {
                self.model.locationCoordinate = LocationCoordinate(
                    lat: loc.coordinate.latitude,
                    lon: loc.coordinate.longitude
                )
                self.save()
            }
        }
    }

    /// Automatically detect location when opening settings for the first time
    func detectCurrentCityIfNeeded() {
        // Only if no saved location yet
        guard model.locationCoordinate == nil else { return }

        LocationService.shared.requestWhenInUse { location in
            guard let loc = location else { return }
            let coordinate = loc.coordinate
            self.updateLocationName(for: coordinate)
            DispatchQueue.main.async {
                self.model.locationCoordinate = LocationCoordinate(lat: coordinate.latitude,
                                                                   lon: coordinate.longitude)
                self.save()
            }
        }
    }

    /// Reverse-geocode coordinates into a readable city name (called on drag)
    func updateLocationName(for coordinate: CLLocationCoordinate2D) {
        geocoder.reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude,
                                                   longitude: coordinate.longitude)) { placemarks, _ in
            let name = placemarks?.first?.locality ?? placemarks?.first?.name ?? "Unknown"
            DispatchQueue.main.async {
                self.liveAddress = name
            }
        }
    }

    /// Confirm final pin position and save it
    func confirmPickedLocation(_ coordinate: CLLocationCoordinate2D) {
        let loc = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(loc) { placemarks, _ in
            let name = placemarks?.first?.locality ?? placemarks?.first?.name ?? "Unknown"
            DispatchQueue.main.async {
                self.model.locationName = name
                self.model.locationCoordinate = LocationCoordinate(
                    lat: coordinate.latitude,
                    lon: coordinate.longitude
                )
                self.save()
            }
        }
    }

    func setManualLocation(name: String) {
        model.locationName = name
        model.locationCoordinate = nil
        save()
    }


    // MARK: - Addresses (Multiple)
    func addManualAddress(building: String, street: String, city: String, country: String, phone: String) {
        let addr = Address(building: building, street: street, city: city, country: country, phone: phone)
        model.addresses.append(addr)
        model.selectedAddressID = addr.id
        // Keep legacy fields in sync (optional)
        model.addressBuilding = building
        model.addressStreet = street
        model.addressCity = city
        model.addressCountry = country
        model.addressPhone = phone
        model.locationName = addr.composed
        model.locationCoordinate = nil
        save()
        saveAddressToUserProfile?(building, street, city, country, phone)
    }

    func selectAddress(id: UUID) {
        guard model.addresses.contains(where: { $0.id == id }) else { return }
        model.selectedAddressID = id
        if let addr = model.selectedAddress { // sync legacy display
            model.addressBuilding = addr.building
            model.addressStreet = addr.street
            model.addressCity = addr.city
            model.addressCountry = addr.country
            model.addressPhone = addr.phone
            model.locationName = addr.composed
            model.locationCoordinate = nil
        }
        save()
    }

    func deleteAddress(at offsets: IndexSet) {
        let idsToRemove = offsets.map { model.addresses[$0].id }
        model.addresses.remove(atOffsets: offsets)
        if let selected = model.selectedAddressID, idsToRemove.contains(selected) {
            model.selectedAddressID = model.addresses.first?.id
            if let addr = model.selectedAddress {
                model.addressBuilding = addr.building
                model.addressStreet = addr.street
                model.addressCity = addr.city
                model.addressCountry = addr.country
                model.addressPhone = addr.phone
                model.locationName = addr.composed
                model.locationCoordinate = nil
            } else {
                model.addressBuilding = nil
                model.addressStreet = nil
                model.addressCity = nil
                model.addressCountry = nil
                model.addressPhone = nil
                model.locationName = nil
                model.locationCoordinate = nil
            }
        }
        save()
    }

    /// Backwards-compatible single-entry setter (kept for existing call sites)
    func setManualAddress(building: String, street: String, city: String, country: String, phone: String) {
        addManualAddress(building: building, street: street, city: city, country: country, phone: phone)
    }


    // MARK: - Currency
    func updateCurrencyConversion() async {
        if model.currency == "EGP" {
            do {
                let rate = try await CurrencyService.shared.convert(amount: 1, from: "USD", to: "EGP")
                convertedRate = rate
                conversionDate = Date()  // ✅ make sure this is here
                CurrencyManager.shared.update(currency: model.currency, rate: rate)
                print("💰 1 USD = \(rate) EGP")
            } catch {
                print("Error fetching currency rate:", error)
            }
        } else {
            convertedRate = nil
            conversionDate = nil       // ✅ clear when switching back to USD
            CurrencyManager.shared.update(currency: model.currency, rate: 1.0)
        }
    }


    // MARK: - Theme & Language
    func applyTheme() {
        for scene in UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }) {
            for window in scene.windows {
                switch model.theme {
                case .system: window.overrideUserInterfaceStyle = .unspecified
                case .light: window.overrideUserInterfaceStyle = .light
                case .dark: window.overrideUserInterfaceStyle = .dark
                }
            }
        }
    }

    func applyLanguage() {
        LocalizationManager.shared.selectedLanguage = model.language.rawValue
        LocalizationManager.shared.reloadBundle()
    }

}

extension Notification.Name {
    static let languageDidChange = Notification.Name("languageDidChange")
}

