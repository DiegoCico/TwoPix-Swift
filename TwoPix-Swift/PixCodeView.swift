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
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 20) {
                    // Custom "Go Back" Button: Signs out and returns to AuthView.
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
                    
                    // Button to generate a unique pix code.
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
                    
                    // TextField where the connecting user enters the pix code.
                    TextField("Enter Pix Code", text: $inputPixCode)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                    
                    // Button to submit a pix code from the connecting user.
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
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Generate a Unique Pix Code and Save It in Firestore
    private func handleGeneratePixCode() {
        let code = String(Int.random(in: 100000...999999))
        let db = Firestore.firestore()
        
        // Check if any user already has this pix code.
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
                    guard let uid = Auth.auth().currentUser?.uid else {
                        message = "User not authenticated."
                        return
                    }
                    
                    // Update the current user's document with the generated pix code.
                    let userDoc = db.collection("users").document(uid)
                    userDoc.updateData(["pixCode": code]) { error in
                        if let error = error {
                            message = "Error saving pix code to user: \(error.localizedDescription)"
                        } else {
                            // Also, create/update a document in the "pixcodes" collection.
                            db.collection("pixcodes").document(code).setData([
                                "uid": uid,
                                "createdAt": Timestamp(date: Date())
                            ]) { error in
                                if let error = error {
                                    message = "Error saving pix code in system: \(error.localizedDescription)"
                                } else {
                                    generatedPixCode = code
                                    message = "Pix code generated and saved."
                                }
                            }
                        }
                    }
                }
            }
    }
    
    // MARK: - Submit and Connect Using an Entered Pix Code
    private func handleSubmitPixCode() {
        guard !inputPixCode.isEmpty else {
            message = "Please enter a Pix Code."
            return
        }
        let db = Firestore.firestore()
        // Look up the entered pix code in the "pixcodes" collection.
        db.collection("pixcodes").document(inputPixCode).getDocument { snapshot, error in
            if let error = error {
                message = "Error checking pix code: \(error.localizedDescription)"
                return
            }
            if let snapshot = snapshot, snapshot.exists {
                // Get the partner's uid from the pixcodes document.
                guard let partnerUid = snapshot.data()?["uid"] as? String else {
                    message = "Invalid pix code data."
                    return
                }
                if let currentUid = Auth.auth().currentUser?.uid {
                    // Update the current user's document.
                    let currentUserDoc = db.collection("users").document(currentUid)
                    currentUserDoc.updateData([
                        "pixCode": inputPixCode,
                        "isConnected": true
                    ]) { error in
                        if let error = error {
                            message = "Error updating your connection: \(error.localizedDescription)"
                        } else {
                            // Update the partner's document.
                            let partnerDoc = db.collection("users").document(partnerUid)
                            partnerDoc.updateData([
                                "isConnected": true
                            ]) { error in
                                if let error = error {
                                    message = "Error updating partner connection: \(error.localizedDescription)"
                                } else {
                                    message = "Users connected successfully!"
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        navigateToHome = true
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                message = "Pix Code not found. Please check and try again."
            }
        }
    }
    
    // MARK: - Sign Out and Return to Auth Screen
    private func signOutAndRestart() {
        do {
            try Auth.auth().signOut()
            navigateToAuth = true
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
