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
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 20) {
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
            }
            .padding()
        }
    }
    
    private func handleGeneratePixCode() {
        // Generate a random 6-digit code.
        let code = String(Int.random(in: 100000...999999))
        generatedPixCode = code
    }
    
    private func handleSubmitPixCode() {
        // In a real app, you’d match this code with a partner’s input.
        // For demo purposes, we check if the entered code matches the generated code.
        if inputPixCode == generatedPixCode && !generatedPixCode.isEmpty {
            message = "Users connected successfully!"
            
            // Update the current user's Firestore document to store the Pix Code and mark them as connected.
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
}
