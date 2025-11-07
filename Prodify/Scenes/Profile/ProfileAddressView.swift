//
//  ProfileAddressView.swift
//  Prodify
//

import SwiftUI

struct ProfileAddressView: View {
    @EnvironmentObject var vm: AuthViewModel
    @State private var phoneNumber: String = ""
    @State private var street: String = ""
    @State private var city: String = ""
    @State private var country: String = ""
    @State private var showSuccess = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section(header: Text("Contact Information")) {
                TextField("Phone Number", text: $phoneNumber)
                    .keyboardType(.phonePad)
            }

            Section(header: Text("Address")) {
                TextField("Street", text: $street)
                TextField("City", text: $city)
                TextField("Country", text: $country)
            }

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
            }

            Button(action: saveAddress) {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Save")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .disabled(isLoading)
        }
        .navigationTitle("My Address")
        .alert("Saved Successfully ✅", isPresented: $showSuccess) {
            Button("OK", role: .cancel) { }
        }
        .onAppear {
            if let user = vm.user {
                phoneNumber = user.phoneNumber ?? ""
                street = user.street ?? ""
                city = user.city ?? ""
                country = user.country ?? ""
            }
        }
    }

    private func saveAddress() {
        guard let user = vm.user else { return }

        let updatedUser = UserInfo(
            id: user.id,
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            verified: user.verified,
            phoneNumber: phoneNumber,
            street: street,
            city: city,
            country: country
        )

        Task {
            isLoading = true
            do {
                try await vm.updateAddress(street: street, city: city, country: country, phoneNumber: phoneNumber)
                isLoading = false
                showSuccess = true
            } catch {
                isLoading = false
                errorMessage = "Failed to save address: \(error.localizedDescription)"
            }
        }
    }
}
