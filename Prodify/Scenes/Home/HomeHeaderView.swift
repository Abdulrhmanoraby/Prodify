import SwiftUI
import FirebaseAuth

struct HomeHeaderView: View {
    // Observe the auth state
    @State private var isUserLoggedIn: Bool = Auth.auth().currentUser != nil
    
    var body: some View {
        HStack {
            Text("Prodify")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.black)

            Spacer()

            HStack(spacing: 16) {
                
                // TODO: Navigate to favorites
                Image(systemName: "heart")
                
                // Cart NavigationLink
                NavigationLink(destination: CartView()) {
                    Image(systemName: "cart")
                }
                // Disable if no user
                .disabled(!isUserLoggedIn)
                // Optional: visually indicate disabled state
                .opacity(isUserLoggedIn ? 1 : 0.5)
            }
            .font(.title3)
            .foregroundColor(.primary)
        }
        .padding(.horizontal)
        // Listen for auth state changes
        .onAppear {
            // Update login state whenever view appears
            isUserLoggedIn = Auth.auth().currentUser != nil
            // Optional: listen for future auth changes
            Auth.auth().addStateDidChangeListener { _, user in
                isUserLoggedIn = user != nil
            }
        }
    }
}

#Preview {
   HomeHeaderView()
}
