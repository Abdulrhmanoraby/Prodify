//
//  MapPickerView.swift
//  Settings2
//
//  Created by Ahmed Tarek on 05/11/2025.
//

import SwiftUI
import MapKit

struct MapPickerView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: SettingsViewModel

    @State private var region: MKCoordinateRegion
    @State private var selectedCoordinate: CLLocationCoordinate2D

    var body: some View {
        VStack(spacing: 0) {
            MapReader { proxy in
                Map(initialPosition: .region(region)) {
                    Annotation("Selected", coordinate: selectedCoordinate) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.red)
                            .shadow(radius: 3)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        if let newCoordinate = proxy.convert(value.location, from: .local) {
                                            selectedCoordinate = newCoordinate
                                            viewModel.updateLocationName(for: newCoordinate)
                                        }
                                    }
                            )
                    }
                }
                .onTapGesture { location in
                    if let newCoordinate = proxy.convert(location, from: .local) {
                        selectedCoordinate = newCoordinate
                        viewModel.updateLocationName(for: newCoordinate)
                    }
                }
            }
            .ignoresSafeArea(edges: .top)

            VStack {
                if let live = viewModel.liveAddress {
                    Text("📍 \(live)")
                        .font(.headline)
                }

                Text(String(format: "Lat: %.4f, Lon: %.4f",
                            selectedCoordinate.latitude,
                            selectedCoordinate.longitude))
                    .font(.subheadline)
                    .padding(.top, 4)

                HStack {
                    Button("Cancel") { dismiss() }
                    Spacer()
                    Button("Confirm") {
                        viewModel.confirmPickedLocation(selectedCoordinate)
                        dismiss()
                    }
                    .bold()
                }
                .padding()
            }
            .background(.thinMaterial)
        }
    }

    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel

        // Center map on saved location or fallback to Cairo
        if let coord = viewModel.model.locationCoordinate {
            let center = CLLocationCoordinate2D(latitude: coord.lat, longitude: coord.lon)
            _region = State(initialValue: MKCoordinateRegion(
                center: center,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
            _selectedCoordinate = State(initialValue: center)
        } else {
            let cairo = CLLocationCoordinate2D(latitude: 30.0444, longitude: 31.2357)
            _region = State(initialValue: MKCoordinateRegion(
                center: cairo,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
            _selectedCoordinate = State(initialValue: cairo)
        }
    }
}
