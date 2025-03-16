import FirebaseAuth
import FirebaseFirestore

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isConnected = false
    @Published var fullName = ""
    @Published var username = ""
    @Published var dob = ""

    init() {
        checkUserStatus()
    }

    func checkUserStatus() {
        if let user = Auth.auth().currentUser {
            isAuthenticated = true
            fetchUserData(userID: user.uid)
        } else {
            isAuthenticated = false
            isConnected = false
        }
    }

    private func fetchUserData(userID: String) {
        Firestore.firestore().collection("users").document(userID).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                DispatchQueue.main.async {
                    self.fullName = data["fullName"] as? String ?? ""
                    self.username = data["username"] as? String ?? ""
                    self.dob = data["dob"] as? String ?? ""
                    self.isConnected = data["isConnected"] as? Bool ?? false
                }
            }
        }
    }
}
