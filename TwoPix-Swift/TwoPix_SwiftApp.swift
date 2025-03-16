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
            if authManager.isAuthenticated {
                if authManager.isConnected {
                    HomeView()
                } else {
                    PixCodeView(fullName: authManager.fullName, username: authManager.username, dob: authManager.dob)
                }
            } else {
                AuthView()
            }
        }
    }
}
