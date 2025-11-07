import SwiftUI

struct CouponView: View {
    @EnvironmentObject var authVM: AuthViewModel

    let cartProducts: [Product]

    @State private var couponCode = ""
    @State private var discount: Double = 0
    @State private var totalAmount: Double = 0
    @State private var discountedTotal: Double = 0
    @State private var navigateToPayment = false
    @State private var navigateToAddress = false
    @State private var showInvalidCouponAlert = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Apply Coupon").font(.title2).bold()

            HStack {
                TextField("Enter coupon code", text: $couponCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.allCharacters)
                    .disableAutocorrection(true)

                Button("Apply") { applyCoupon() }
                    .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 8) {
                Text("Subtotal: \(totalAmount, specifier: "%.2f") EGP")
                if discount > 0 {
                    Text("Discount: -\(discount, specifier: "%.2f") EGP").foregroundColor(.green)
                }
                Divider()
                Text("Total: \(discountedTotal, specifier: "%.2f") EGP").font(.headline)
            }
            .padding()

            Spacer()

            Button {
                print("Proceed pressed — auth user:", authVM.user?.email ?? "nil")
                proceedToCheckout()
            } label: {
                Text("Proceed to Checkout")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }

            // Hidden links driven by state (must be in this same view)
            NavigationLink(
                destination: PaymentView(
                    address: "\(authVM.user?.street ?? ""), \(authVM.user?.city ?? ""), \(authVM.user?.country ?? "")",
                    cartProducts: cartProducts,
                    totalAmount: discountedTotal,        //
                    userEmail: authVM.user?.email ?? "guest@prodify.com"
                ),
                isActive: $navigateToPayment
            ) { EmptyView() }

            NavigationLink(
                destination: ProfileAddressView(),
                isActive: $navigateToAddress
            ) { EmptyView() }
        }
        .onAppear(perform: calculateTotal)
        .alert("Invalid Coupon", isPresented: $showInvalidCouponAlert) {
            Button("OK", role: .cancel) {}
        } message: { Text("Invalid coupon code") }
        .navigationTitle("Coupons & Discounts")
    }

    private func applyCoupon() {
        let code = couponCode.uppercased()
        if code == "SAVE10" {
            discount = totalAmount * 0.10
        } else if code == "FREESHIP" {
            discount = 50
        } else if code.isEmpty {
            discount = 0
        } else {
            showInvalidCouponAlert = true
            discount = 0
        }
        discountedTotal = totalAmount - discount
    }

    private func calculateTotal() {
        totalAmount = cartProducts.compactMap { Double($0.variants?.first?.price ?? "0") }.reduce(0, +)
        discountedTotal = totalAmount
    }

    private func proceedToCheckout() {
        guard let user = authVM.user else {
            authVM.errorMessage = "You must log in first."
            return
        }

        let missingInfo =
            (user.street?.isEmpty ?? true) ||
            (user.city?.isEmpty ?? true) ||
            (user.country?.isEmpty ?? true) ||
            (user.phoneNumber?.isEmpty ?? true)

        // ensure main thread
        DispatchQueue.main.async {
            if missingInfo {
                print("missing info -> navigating to profile address")
                navigateToAddress = true
            } else {
                print("all info present -> navigating to payment")
                navigateToPayment = true
            }
        }
    }
}
