import SwiftUI
import FirebaseCore

@main
struct TwoPixApp: App {
    @StateObject private var authManager = AuthManager() // This uses the single definition from AuthManager.swift.
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
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
