import SwiftUI
import FirebaseAuth

struct AuthView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isAuthenticated = false
    @State private var showSignUp = false   // State variable to trigger navigation

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea() // Dark background

                VStack(spacing: 20) {
                    // App Logo
                    Text("TwoPix")
                        .font(.largeTitle)
                        .foregroundColor(.pink)
                        .bold()

                    // Email Field
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .foregroundColor(.white)
                        .autocapitalization(.none)

                    // Password Field
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .foregroundColor(.white)

                    // Login Button
                    Button(action: login) {
                        Text("Log In")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)

                    // Sign Up Navigation Button
                    Button(action: {
                        showSignUp = true  // Set state to trigger navigation
                    }) {
                        Text("Don't have an account? Sign Up")
                            .foregroundColor(.white)
                            .underline()
                    }
                    .padding()

                    // Error Message Display
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                .padding()

                // Invisible NavigationLink triggered by showSignUp state
                NavigationLink(destination: SignUpView(), isActive: $showSignUp) {
                    EmptyView()
                }
            }
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $isAuthenticated) {
            HomeView()  // Navigate to Home after successful login
        }
    }

    // Login with Firebase
    private func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                isAuthenticated = true
                print("User logged in successfully!")
            }
        }
    }
}
