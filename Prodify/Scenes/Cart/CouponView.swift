import SwiftUI

struct CouponView: View {
    let cartProducts: [Product]
    let initialTotal: Double
    @Binding var discountedTotal: Double

    @State private var couponCode = ""
    @State private var discount: Double = 0
    @State private var totalAmount: Double = 0
    @State private var showInvalidCouponAlert = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Apply Coupon")
                .font(.headline)

            HStack {
                TextField("Enter coupon code", text: $couponCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.allCharacters)
                    .disableAutocorrection(true)

                Button("Apply") { applyCoupon() }
                    .buttonStyle(.borderedProminent)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Subtotal: \(totalAmount, specifier: "%.2f") EGP")
                if discount > 0 {
                    Text("Discount: -\(discount, specifier: "%.2f") EGP")
                        .foregroundColor(.green)
                }
                Divider()
                Text("Total: \(discountedTotal, specifier: "%.2f") EGP")
                    .font(.headline)
            }
        }
        .padding()
        .onAppear {
            totalAmount = initialTotal
            discountedTotal = initialTotal
        }
        .onChange(of: initialTotal) { newValue in
            totalAmount = newValue
            discountedTotal = totalAmount - discount
        }
        .alert("Invalid Coupon", isPresented: $showInvalidCouponAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The entered coupon code is invalid.")
        }
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
}
