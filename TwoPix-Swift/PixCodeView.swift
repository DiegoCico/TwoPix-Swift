import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct PixCodeView: View {
    var fullName: String
    var username: String
    var dob: String
    
    @State private var generatedPixCode: String = ""
    @State private var inputPixCode: String = ""
    @State private var message: String = ""
    @State private var navigateToHome: Bool = false
    @State private var navigateToAuth: Bool = false  // For navigating back to AuthView
    
    // Remove the local presentationMode since we want to fully reset to AuthView.
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 20) {
                    // Custom "Go Back" Button that returns to AuthView
                    HStack {
                        Button(action: {
                            signOutAndRestart()
                        }) {
                            Text("Go Back")
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding()
                    
                    Text("Pix Code")
                        .font(.largeTitle)
                        .foregroundColor(.pink)
                        .bold()
                    
                    Button(action: handleGeneratePixCode) {
                        Text("Generate Pix Code")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    if !generatedPixCode.isEmpty {
                        Text("Your Code: \(generatedPixCode)")
                            .font(.title2)
                            .foregroundColor(.white)
                        Text("Waiting for partner to enter code")
                            .foregroundColor(.white)
                    }
                    
                    TextField("Enter Pix Code", text: $inputPixCode)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                    
                    Button(action: handleSubmitPixCode) {
                        Text("Submit Pix Code")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    if !message.isEmpty {
                        Text(message)
                            .foregroundColor(.yellow)
                    }
                    
                    NavigationLink(
                        destination: HomeView(),
                        isActive: $navigateToHome,
                        label: { EmptyView() }
                    )
                    
                    NavigationLink(
                        destination: AuthView(),
                        isActive: $navigateToAuth,
                        label: { EmptyView() }
                    )
                }
                .padding()
            }
            // Hide the default navigation bar to avoid stacking default back buttons.
            .navigationBarHidden(true)
        }
    }
    
    // Generates a random 6-digit pix code and checks Firestore to ensure uniqueness.
    private func handleGeneratePixCode() {
        let code = String(Int.random(in: 100000...999999))
        let db = Firestore.firestore()
        db.collection("users")
            .whereField("pixCode", isEqualTo: code)
            .getDocuments { snapshot, error in
                if let error = error {
                    message = "Error checking pix code: \(error.localizedDescription)"
                    return
                }
                if let snapshot = snapshot, !snapshot.documents.isEmpty {
                    // Code already exists, try again.
                    handleGeneratePixCode()
                } else {
                    // Code is unique.
                    generatedPixCode = code
                }
            }
    }
    
    private func handleSubmitPixCode() {
        // Check if the entered code matches the generated code.
        if inputPixCode == generatedPixCode && !generatedPixCode.isEmpty {
            message = "Users connected successfully!"
            if let uid = Auth.auth().currentUser?.uid {
                Firestore.firestore().collection("users").document(uid).updateData([
                    "pixCode": generatedPixCode,
                    "isConnected": true
                ]) { error in
                    if let error = error {
                        message = "Error updating connection: \(error.localizedDescription)"
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            navigateToHome = true
                        }
                    }
                }
            }
        } else {
            message = "Pix Code does not match. Please try again."
        }
    }
    
    // Signs out the current user and navigates back to the Auth screen.
    private func signOutAndRestart() {
        do {
            try Auth.auth().signOut()
            navigateToAuth = true
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
