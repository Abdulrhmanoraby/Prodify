import SwiftUI

struct CartView: View {
    @EnvironmentObject var vm: CartViewModel
    
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
                                    Text("Qty: \(item.quantity)")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
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
                    
                    HStack {
                        Text("Total:")
                            .font(.headline)
                        Spacer()
                        Text("$\(vm.total, specifier: "%.2f")")
                            .bold()
                    }
                    .padding()
                    
                    NavigationLink("Proceed to Checkout") {
                        AddressView(cartProducts: vm.products) // placeholder
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.bottom, 12)
                }
            }
            .navigationTitle("Shopping Cart")
            .task { await vm.loadCart() }
        }
    }
}
