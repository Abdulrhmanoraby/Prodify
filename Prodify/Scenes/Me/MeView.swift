import SwiftUI
import FirebaseAuth

struct MeView: View {
    @StateObject private var vm = AuthViewModel()
    @EnvironmentObject var orderVM: OrderViewModel
    @State private var currentEmail = ""

    var body: some View {
        NavigationStack {
            Group {
                if let user = vm.user {
                    if user.verified {
                        LoggedInView(vm: vm, orderVM: orderVM, user: user)
                    } else {
                        VerifyEmailView(vm: vm)
                    }
                } else {
                    NotLoggedInView()
                }
            }
            .navigationTitle("Me")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination:CartView() ) {
                        Image(systemName: "cart")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination:SettingsView() ) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .onAppear { vm.loadCurrent() }
        }
    }
}

#Preview {
    MeView()
}
