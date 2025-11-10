import SwiftUI

struct PaymentView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var orderVM: OrderViewModel
    @EnvironmentObject var currencyManager: CurrencyManager
     @EnvironmentObject var cartVM: CartViewModel
    let address: String
    //let cartProducts: [Product]
    let totalAmount: Double
    let userEmail: String
    
    @State private var selectedPayment = "Cash"
    @State private var showLimitAlert = false
    @State private var isLoading = false
    @State private var navigateToOrders = false
    @State private var errorMessage: String?

    private let paymentMethods = ["Cash", "PayPal"]
    private let cashLimit: Double = 10000.0

    // MARK: - Currency Helpers (using CurrencyManager)
    private var isEGP: Bool { currencyManager.currentCurrency == "EGP" }
    private var usdToEGP: Double { currencyManager.conversionRate }
    private var displayTotalFormatted: String { currencyManager.formatPrice(fromUSD: totalAmount, minimumFractionDigits: isEGP ? 0 : 2, maximumFractionDigits: isEGP ? 0 : 2) }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // MARK: Header
                VStack(spacing: 8) {
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .padding(.top, 20)
                    
                    Text("Payment")
                        .font(.system(size: 32, weight: .bold))
                    
                    Text("Choose your payment method")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 30)
                
                // MARK: Payment Method Selector
                VStack(alignment: .leading, spacing: 12) {
                    Text("Payment Method")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                    
                    Picker("Payment", selection: $selectedPayment) {
                        ForEach(paymentMethods, id: \.self) { method in
                            Text(method)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 25)

                // MARK: Order Summary Card
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "cart.fill")
                            .foregroundColor(.blue)
                        Text("Order Summary")
                            .font(.headline)
                        Spacer()
                    }
                    
                    Divider()
                    
                    VStack(spacing: 10) {
                        HStack {
                            Text("Items")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(cartVM.items.count)")
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            Text("Delivery Address")
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        
                        Text(address)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        HStack {
                            Text("Total Amount")
                                .font(.headline)
                            Spacer()
                            Text(displayTotalFormatted)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 25)

                // MARK: Payment Action Area
                VStack(spacing: 16) {
                    if selectedPayment == "Cash" {
                        // Cash Payment Info Card
                        HStack(spacing: 12) {
                            Image(systemName: "banknote.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Cash on Delivery")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text("Pay when you receive your order")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green.opacity(0.1))
                        )
                        .padding(.horizontal, 20)
                        
                        Button(action: handleCashCheckout) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                Text("Place Order")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .blue.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                        
                    } else {
                        // PayPal Payment Info Card
                        HStack(spacing: 12) {
                            Image(systemName: "app.badge.checkmark.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("PayPal Sandbox")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text("Secure payment processing")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.1))
                        )
                        .padding(.horizontal, 20)
                        
                        PayPalButtonView(
                            amount: String(format: "%.2f", totalAmount),
                            cartProducts: cartVM.products,
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
                        .frame(height: 50)
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 20)

                // MARK: Status Messages
                if isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Processing your order...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                    .padding(.horizontal, 20)
                }
                
                if let msg = errorMessage {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text(msg)
                            .font(.subheadline)
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.red.opacity(0.1))
                    )
                    .padding(.horizontal, 20)
                }
                
                // MARK: Security Notice
                HStack(spacing: 8) {
                    Image(systemName: "lock.shield.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Your payment information is secure and encrypted")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                NavigationLink(destination: OrderListView(), isActive: $navigateToOrders) { EmptyView() }
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
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
                products: cartVM.products,
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
            products: cartVM.products,
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

