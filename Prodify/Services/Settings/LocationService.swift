//
//  LocationService.swift
//  Settings2
//
//  Created by Ahmed Tarek on 05/11/2025.
//

import Foundation
import CoreLocation

final class LocationService: NSObject, CLLocationManagerDelegate {
    static let shared = LocationService()
    private let manager = CLLocationManager()
    private var completion: ((CLLocation?) -> Void)?

    private override init() {
        super.init()
        manager.delegate = self
    }

    func requestWhenInUse(completion: @escaping (CLLocation?) -> Void) {
        self.completion = completion
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        completion?(locations.first)
        completion = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        completion?(nil)
        completion = nil
    }
}

