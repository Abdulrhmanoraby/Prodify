import SwiftUI

struct CartView: View {
    @EnvironmentObject var vm: CartViewModel
    @EnvironmentObject var authVM: AuthViewModel

    @State private var navigateToPayment = false
    @State private var navigateToAddress = false
    @State private var discountedTotal: Double = 0
    var body: some View {
        NavigationStack {
            VStack {
                if vm.items.isEmpty {
                    Text("Your cart is empty")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(vm.items) { item in
                            HStack {
                                AsyncImage(url: URL(string: item.imageURL ?? "")) { image in
                                    image.resizable().scaledToFit()
                                } placeholder: {
                                    Color.gray.opacity(0.3)
                                }
                                .frame(width: 60, height: 60)
                                .cornerRadius(8)

                                VStack(alignment: .leading) {
                                    Text(item.title)
                                        .font(.subheadline)
                                    Stepper {
                                        Text("Qty: \(item.quantity)")
                                            .font(.footnote)
                                    } onIncrement: {
                                        Task { await vm.increaseQuantity(itemId: item.id) }
                                    } onDecrement: {
                                        Task { await vm.decreaseQuantity(itemId: item.id) }
                                    }
                                    .padding()
                                }

                                Spacer()

                                Text("$\(item.price * Double(item.quantity), specifier: "%.2f")")
                                    .bold()
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    Task { await vm.remove(itemId: item.id) }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)

                    // Total Section
                    HStack {
                        Text("Subtotal:")
                            .font(.headline)
                        Spacer()
                        Text("$\(vm.total, specifier: "%.2f")")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)

                    // Coupon Section (Inline)
                   
                    CouponView(
                        cartProducts: vm.products,
                        initialTotal: vm.total,
                        discountedTotal: $discountedTotal
                    )
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Checkout Button (only here now)
                    Button {
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
                            .padding(.bottom, 20)
                    }

                    // Navigation Links (keep hidden)
                    NavigationLink(
                        destination: PaymentView(
                            address: formatAddress(),
                           
                            totalAmount: discountedTotal,
                            userEmail: authVM.user?.email ?? "guest@prodify.com"
                        ),
                        isActive: $navigateToPayment
                    ) { EmptyView() }

                    NavigationLink(
                        destination: ProfileAddressView(),
                        isActive: $navigateToAddress
                    ) { EmptyView() }
                }
            }
            .navigationTitle("Shopping Cart")
            .task { await vm.loadCart() }
        }
    }

    private func proceedToCheckout() {
        print(vm.items.count)
        guard let user = authVM.user else { return }

        let missingInfo = [user.street, user.city, user.country, user.phoneNumber]
            .contains { $0?.isEmpty ?? true }

        if missingInfo {
            print("Missing address info — navigating to address view")
            navigateToAddress = true
        } else {
            print("Proceeding to payment with total:", discountedTotal)
            navigateToPayment = true
        }
    }

    private func formatAddress() -> String {
        let s = authVM.user?.street ?? ""
        let c = authVM.user?.city ?? ""
        let co = authVM.user?.country ?? ""
        return "\(s), \(c), \(co)"
    }
}
