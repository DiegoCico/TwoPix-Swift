import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUpView: View {
    @State private var fullName: String = ""
    @State private var username: String = ""
    @State private var dob: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var navigateToPixCode: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 20) {
                    Text("Sign Up")
                        .font(.largeTitle)
                        .foregroundColor(.pink)
                        .bold()
                    
                    TextField("Full Name", text: $fullName)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .autocapitalization(.words)
                    
                    TextField("Username", text: $username)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                    
                    TextField("Date of Birth (YYYY-MM-DD)", text: $dob)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                    
                    TextField("Email", text: $email)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                    
                    Button(action: handleSignUp) {
                        Text("Continue")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
                // Navigate to PixCodeView once sign up is successful.
                NavigationLink(
                    destination: PixCodeView(fullName: fullName, username: username, dob: dob),
                    isActive: $navigateToPixCode,
                    label: { EmptyView() }
                )
            }
        }
    }
    
    private func handleSignUp() {
        // Ensure all fields are filled.
        guard !fullName.isEmpty, !username.isEmpty, !dob.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }
        
        // Create the user with Firebase Auth.
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }
            guard let uid = authResult?.user.uid else { return }
            // Prepare user data with a default connection status (not connected yet).
            let userData: [String: Any] = [
                "fullName": fullName,
                "username": username,
                "dob": dob,
                "email": email,
                "isConnected": false  // User not yet connected via Pix Code.
            ]
            // Save user details in Firestore under the "users" collection.
            Firestore.firestore().collection("users").document(uid).setData(userData) { err in
                if let err = err {
                    errorMessage = "Error saving user data: \(err.localizedDescription)"
                } else {
                    navigateToPixCode = true
                }
            }
        }
    }
}
