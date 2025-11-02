import SwiftUI
import FirebaseAuth

struct OrderListView: View {
    @EnvironmentObject  var vm: OrderViewModel
    @State private var currentEmail = ""

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView("Loading orders...")
                } else if let error = vm.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else if vm.orders.isEmpty {
                    Text("No orders found yet.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(vm.orders) { order in
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Order ID: \(order.id)")
                                .font(.headline)

                            if let total = order.total_price {
                                Text("Total: \(total) EGP")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                            }

                            if let status = order.financial_status {
                                Text("Status: \(status.capitalized)")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }

                            if let dateStr = order.created_at {
                                Text("Date: \(formatDate(from: dateStr))")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }

                            if let url = order.order_status_url {
                                Link("View order online", destination: URL(string: url)!)
                                    .font(.footnote)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("My Orders")
            .task {
                if let user = Auth.auth().currentUser {
                    currentEmail = user.email ?? "guest@prodify.com"
                    await vm.fetchOrders(for: currentEmail)
                }
            }
        }
    }

    // MARK: - Helper to format Shopify date strings
    private func formatDate(from isoDate: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: isoDate) {
            return date.formatted(date: .abbreviated, time: .shortened)
        } else {
            return isoDate
        }
    }
}

#Preview {
    OrderListView()
}


