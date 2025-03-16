//
//  ProfileView.swift
//  TwoPix-Swift
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @State private var fullName: String = ""
    @State private var dob: String = ""
    @State private var email: String = ""
    // Non-editable fields:
    @State private var username: String = ""
    @State private var pixCode: String = ""
    
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Information")) {
                    TextField("Full Name", text: $fullName)
                    TextField("Date of Birth", text: $dob)
                    TextField("Email", text: $email)
                }
                
                Section(header: Text("Account Info")) {
                    HStack {
                        Text("Username")
                        Spacer()
                        Text(username)
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Pix Code")
                        Spacer()
                        Text(pixCode)
                            .foregroundColor(.gray)
                    }
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                if let successMessage = successMessage {
                    Text(successMessage)
                        .foregroundColor(.green)
                }
                
                Section {
                    Button(action: updateProfile) {
                        Text("Save Changes")
                    }
                    
                    Button(action: deleteAccount) {
                        Text("Delete Account")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarItems(leading: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear(perform: loadUserData)
        }
    }
    
    private func loadUserData() {
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid
        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                fullName = data["fullName"] as? String ?? ""
                dob = data["dob"] as? String ?? ""
                email = data["email"] as? String ?? ""
                username = data["username"] as? String ?? ""
                pixCode = data["pixCode"] as? String ?? "Not Set"
            } else if let error = error {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func updateProfile() {
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid
        let updatedData: [String: Any] = [
            "fullName": fullName,
            "dob": dob,
            "email": email
        ]
        Firestore.firestore().collection("users").document(uid).updateData(updatedData) { error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                successMessage = "Profile updated successfully!"
            }
        }
    }
    
    private func deleteAccount() {
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid
        // Delete user data from Firestore first.
        Firestore.firestore().collection("users").document(uid).delete { error in
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }
            // Then delete the user account.
            user.delete { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
