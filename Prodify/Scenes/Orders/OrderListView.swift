import SwiftUI
import FirebaseAuth

struct OrderListView: View {
    @EnvironmentObject var vm: OrderViewModel
    @State private var currentEmail = ""
    @State private var refreshID = UUID()
    @ObservedObject private var currency = CurrencyManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                Group {
                    if vm.isLoading {
                        loadingView
                    } else if let error = vm.errorMessage {
                        errorView(error)
                    } else if vm.orders.isEmpty {
                        emptyStateView
                    } else {
                        ordersListView
                    }
                }
            }
            .navigationTitle("My Orders")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await reloadOrders()
            }
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.3)
                .tint(.blue)
            Text("Loading orders...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Error View
    private func errorView(_ error: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.red.opacity(0.7))
            
            Text("Something went wrong")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(error)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding()
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "shippingbox.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue.opacity(0.6), .purple.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("No Orders Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Your orders will appear here once you make a purchase")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 50)
        }
        .padding()
    }
    
    // MARK: - Orders List View
    private var ordersListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(vm.orders, id: \.id) { order in
                    orderCard(for: order)
                }
            }
            .padding()
        }
        .id(refreshID)
        .refreshable {
            await reloadOrders()
        }
    }
    
    // MARK: - Order Card
    private func orderCard(for order: ShopifyOrder) -> some View {
        VStack(spacing: 0) {
            // Header Section
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Order #\(order.id)")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let dateStr = order.created_at {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption)
                            Text(formatDate(from: dateStr))
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if let status = order.financial_status {
                    statusBadge(status: status)
                }
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.05)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            
            Divider()
            
            // Details Section
            VStack(spacing: 12) {
                if let total = order.total_price {
                    HStack {
                        HStack(spacing: 6) {
                            Image(systemName: "banknote.fill")
                                .font(.subheadline)
                                .foregroundColor(.green)
                            Text("Total Amount")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if let usd = Double(total) {
                            Text(currency.formatPrice(fromUSD: usd))
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        } else {
                            Text(total)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                if let url = order.order_status_url {
                    Divider()
                        .padding(.vertical, 4)
                    
                    Link(destination: URL(string: url)!) {
                        HStack {
                            Image(systemName: "arrow.up.right.square.fill")
                                .font(.subheadline)
                            Text("View Order Details")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
    
    // MARK: - Status Badge
    private func statusBadge(status: String) -> some View {
        let (color, icon) = statusStyle(for: status)
        
        return HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(status.capitalized)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.15))
        .foregroundColor(color)
        .clipShape(Capsule())
    }
    
    // MARK: - Status Styling
    private func statusStyle(for status: String) -> (Color, String) {
        switch status.lowercased() {
        case "paid":
            return (.green, "checkmark.circle.fill")
        case "pending":
            return (.orange, "clock.fill")
        case "refunded":
            return (.red, "arrow.uturn.backward.circle.fill")
        case "authorized":
            return (.blue, "checkmark.seal.fill")
        default:
            return (.gray, "circle.fill")
        }
    }
    
    // MARK: - Reload helper
    private func reloadOrders() async {
        if let user = Auth.auth().currentUser {
            currentEmail = user.email ?? "guest@prodify.com"
            await vm.fetchOrders(for: currentEmail)
            refreshID = UUID()
        }
    }
    
    // MARK: - Date formatter
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
