import SwiftUI

struct PaymentView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var orderVM: OrderViewModel
    
    let address: String
    let cartProducts: [Product]
    let totalAmount: Double
    let userEmail: String
    
    @State private var selectedPayment = "Cash"
    @State private var showLimitAlert = false
    @State private var isLoading = false
    @State private var navigateToOrders = false
    @State private var errorMessage: String?

    private let paymentMethods = ["Cash", "PayPal"]
    private let cashLimit: Double = 10000.0

    var body: some View {
        VStack(spacing: 25) {
            Text("Payment")
                .font(.title2)
                .bold()
            
            // MARK: Payment Method Picker
            Picker("Payment", selection: $selectedPayment) {
                ForEach(paymentMethods, id: \.self) { method in
                    Text(method)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            // MARK: Order Summary
            VStack(spacing: 8) {
                Text("Order Summary")
                    .font(.headline)
                Text("Total: $\(String(format: "%.2f", totalAmount))")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
            .padding(.bottom, 20)

            // MARK: Payment Options
            if selectedPayment == "Cash" {
                Button(action: handleCashCheckout) {
                    Text("Place Order (Cash on Delivery)")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            } else {
                VStack(spacing: 12) {
                    Text("Pay securely with PayPal Sandbox")
                        .font(.headline)
                    PayPalButtonView(
                        amount: String(format: "%.2f", totalAmount),
                        cartProducts: cartProducts,
                        address: address,
                        email: userEmail,
                        onOrderCreated: {
                            Task {
                                await handlePayPalSuccess()
                            }
                        },
                        onError: { error in
                            errorMessage = error.localizedDescription
                        }
                    )
                    .frame(height: 45)
                }
            }

            // MARK: Status & Navigation
            if isLoading { ProgressView("Processing order...") }
            if let msg = errorMessage {
                Text(msg).foregroundColor(.red).font(.footnote)
            }
            NavigationLink(destination: OrderListView(), isActive: $navigateToOrders) { EmptyView() }
        }
        .padding()
        .alert("Cash limit exceeded", isPresented: $showLimitAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Cash on delivery is available for orders up to \(Int(cashLimit)) EGP only.")
        }
    }

    // MARK: - Cash Checkout Logic
    private func handleCashCheckout() {
        if totalAmount > cashLimit {
            showLimitAlert = true
            return
        }
        Task {
            isLoading = true
            await orderVM.createOrder(
                products: cartProducts,
                email: userEmail,
                address: address,
                paymentMethod: "Cash"
            )
            isLoading = false
            if orderVM.successMessage != nil {
                navigateToOrders = true
            } else {
                errorMessage = orderVM.errorMessage
            }
        }
    }

    // MARK: - PayPal Success → Create Order
    private func handlePayPalSuccess() async {
        isLoading = true
        await orderVM.createOrder(
            products: cartProducts,
            email: userEmail,
            address: address,
            paymentMethod: "PayPal"
        )
        isLoading = false
        if orderVM.successMessage != nil {
            navigateToOrders = true
        } else {
            errorMessage = orderVM.errorMessage
        }
    }
}
