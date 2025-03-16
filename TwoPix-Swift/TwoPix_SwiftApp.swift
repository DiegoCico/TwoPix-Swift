import SwiftUI
import Firebase

@main
struct TwoPixApp: App {
    @StateObject private var authManager = AuthManager()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            // If the user is authenticated, show HomeView; if not, show AuthView.
            if authManager.isAuthenticated {
                NavigationView {
                    HomeView()
                        .environmentObject(authManager)
                }
            } else {
                AuthView()
                    .environmentObject(authManager)
            }
        }
    }
}
