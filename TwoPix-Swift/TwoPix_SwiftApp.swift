import SwiftUI
import FirebaseCore

@main
struct TwoPixApp: App {
    @StateObject private var authManager = AuthManager() // Single definition from AuthManager.swift.
    
    init() {
        FirebaseApp.configure()
        disableInputAssistant()
        // Ensure that any computed layout values in your views are valid (not NaN) to avoid CoreGraphics warnings.
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

func disableInputAssistant() {
    UITextField.appearance().inputAssistantItem.leadingBarButtonGroups = []
    UITextField.appearance().inputAssistantItem.trailingBarButtonGroups = []
    UITextView.appearance().inputAssistantItem.leadingBarButtonGroups = []
    UITextView.appearance().inputAssistantItem.trailingBarButtonGroups = []
}
