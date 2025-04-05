import SwiftUI
import AVFoundation
import FirebaseFirestore
import FirebaseAuth

// MARK: - HomeView
struct HomeView: View {
    @StateObject private var cameraManager = CameraManager() // Assume defined elsewhere.
    @EnvironmentObject var authManager: AuthManager          // Assume defined elsewhere.

    @State private var showChat = false
    @State private var showProfile = false
    @State private var showPermissionAlert = false
    @State private var showFrontFlashEffect = false
    @State private var baseZoom: CGFloat = 1.0  // Stores the zoom factor before the current pinch gesture.
    
    // Current photo tag ("FitCheck", "Normal", or "Spicy")
    @State private var currentPhotoTag: String = "Normal"

    var body: some View {
        if authManager.isAuthenticated {
            if authManager.isConnected {
                ZStack {
                    // Camera preview with pinch gesture for zoom.
                    CameraPreviewView(cameraManager: cameraManager)
                        .ignoresSafeArea()
                        .gesture(
                            TapGesture(count: 2)
                                .onEnded {
                                    cameraManager.flipCamera()
                                }
                        )
                        .simultaneousGesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    let newZoom = baseZoom * value
                                    if newZoom.isFinite {
                                        cameraManager.setZoomFactor(newZoom)
                                    } else {
                                        print("Invalid zoom value encountered.")
                                    }
                                }
                                .onEnded { _ in
                                    baseZoom = cameraManager.currentZoomFactor()
                                }
                        )
                    
                    // Optional front camera flash overlay.
                    if cameraManager.isFrontCamera && showFrontFlashEffect {
                        GeometryReader { geo in
                            RadialGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color.clear, location: 0.4),
                                    .init(color: Color.clear, location: 0.6),
                                    .init(color: Color.white, location: 1.0)
                                ]),
                                center: .center,
                                startRadius: geo.size.width * 0.4,
                                endRadius: geo.size.width * 0.8
                            )
                            .ignoresSafeArea()
                        }
                    }
                    
                    // Overlay controls.
                    VStack {
                        // Top controls.
                        HStack {
                            Spacer()
                            HStack(spacing: 16) {
                                Button(action: { showChat = true }) {
                                    Image(systemName: "message.fill")
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Circle().fill(Color.black.opacity(0.5)))
                                }
                                Button(action: { showProfile = true }) {
                                    Image(systemName: "person.crop.circle")
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Circle().fill(Color.black.opacity(0.5)))
                                }
                                Button(action: { cameraManager.flipCamera() }) {
                                    Image(systemName: "camera.rotate.fill")
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Circle().fill(Color.black.opacity(0.5)))
                                }
                                Button(action: {
                                    if cameraManager.isFrontCamera {
                                        showFrontFlashEffect.toggle()
                                    } else {
                                        cameraManager.toggleFlash()
                                    }
                                }) {
                                    Image(systemName: "bolt.fill")
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Circle().fill(Color.black.opacity(0.5)))
                                }
                            }
                            .padding()
                        }
                        
                        Spacer()
                        
                        // Bottom carousel buttons.
                        TabView(selection: .constant(1)) {
                            // FitCheck button.
                            Button(action: {
                                currentPhotoTag = "FitCheck"
                                cameraManager.capturePhoto()
                            }) {
                                Text("FitCheck")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(width: 80, height: 80)
                                    .background(Circle().fill(Color.red.opacity(0.7)))
                            }
                            .tag(0)
                            
                            // Normal (camera) button.
                            Button(action: {
                                currentPhotoTag = "Normal"
                                cameraManager.capturePhoto()
                            }) {
                                Image(systemName: "camera.circle.fill")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.white)
                            }
                            .tag(1)
                            
                            // Spicy button.
                            Button(action: {
                                currentPhotoTag = "Spicy"
                                cameraManager.capturePhoto()
                            }) {
                                Text("Spicy")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(width: 80, height: 80)
                                    .background(Circle().fill(Color.orange))
                            }
                            .tag(2)
                        }
                        .frame(height: 120)
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .padding(.bottom, 50)
                    }
                    .background(Color.clear)
                    
                    // Photo preview overlay.
                    if let capturedImage = cameraManager.capturedImage {
                        // If using the front camera, unmirror the image.
                        let fixedImage = cameraManager.isFrontCamera ? capturedImage.unmirror() : capturedImage
                        PhotoPreviewOverlay(
                            capturedImage: fixedImage,
                            onCancel: { cameraManager.capturedImage = nil },
                            onSend: {
                                FirebasePhotoUploader.shared.uploadPhoto(
                                    image: fixedImage,
                                    pixCode: authManager.pixCode,
                                    photoTag: currentPhotoTag
                                ) { urlString, error in
                                    if let error = error {
                                        print("Error uploading photo: \(error.localizedDescription)")
                                    } else if let photoURL = urlString {
                                        // Generate a random notification message based on the current photo tag.
                                        let notificationMessage = self.randomNotificationMessage(for: currentPhotoTag, senderName: authManager.fullName)
                                        
                                        // Add the photo as a chat message with the notification message.
                                        let db = Firestore.firestore()
                                        let data: [String: Any] = [
                                            "photoURL": photoURL,
                                            "timestamp": Timestamp(date: Date()),
                                            "sender": Auth.auth().currentUser?.uid ?? "unknown",
                                            "messageType": "photo",
                                            "notificationMessage": notificationMessage,
                                            "photoTag": currentPhotoTag
                                        ]
                                        db.collection("pixcodes")
                                            .document(authManager.pixCode)
                                            .collection("chats")
                                            .addDocument(data: data) { error in
                                                if let error = error {
                                                    print("Error adding photo message to chat: \(error.localizedDescription)")
                                                } else {
                                                    print("Photo message added to chat successfully")
                                                }
                                            }
                                        DispatchQueue.main.async {
                                            cameraManager.capturedImage = nil
                                        }
                                    }
                                }
                            }
                        )
                        .transition(.opacity)
                        .zIndex(1)
                    }
                    
                    // NavigationLinks.
                    NavigationLink(
                        destination: ChatView(pixCode: authManager.pixCode),
                        isActive: $showChat,
                        label: { EmptyView() }
                    )
                    NavigationLink(
                        destination: ProfileView(),
                        isActive: $showProfile,
                        label: { EmptyView() }
                    )
                }
                .onAppear {
                    cameraManager.checkPermissions()
                    cameraManager.startSession()
                    baseZoom = cameraManager.currentZoomFactor()
                }
                .onChange(of: cameraManager.cameraPermissionDenied) { denied in
                    if denied { showPermissionAlert = true }
                }
                .onChange(of: cameraManager.microphonePermissionDenied) { denied in
                    if denied { showPermissionAlert = true }
                }
                .alert(isPresented: $showPermissionAlert) {
                    Alert(
                        title: Text("Permissions Required"),
                        message: Text("This app requires access to both the camera and microphone for full functionality. Please enable these permissions in Settings."),
                        dismissButton: .cancel(Text("Cancel"), action: {
                            recheckPermissionsAfterDelay()
                        })
                    )
                }
            } else {
                PixCodeView(
                    fullName: authManager.fullName,
                    username: authManager.username,
                    dob: authManager.dob
                )
            }
        } else {
            AuthView()
        }
    }
    
    private func recheckPermissionsAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            cameraManager.checkPermissions()
            if cameraManager.cameraPermissionDenied || cameraManager.microphonePermissionDenied {
                showPermissionAlert = true
            }
        }
    }
    
    // MARK: - Notification Message Generator
    /// Returns a random notification message based on the photo tag.
    private func randomNotificationMessage(for tag: String, senderName: String) -> String {
        switch tag {
        case "Normal":
            let options = [
                "You got a pix!",
                "You received a pix from \(senderName)!",
                "Pix got sent!",
                "Sent you a pix!",
                "A fresh pix just landed!"
            ]
            return options.randomElement() ?? "You got a pix!"
        case "FitCheck":
            let options = [
                "Fit check sent!",
                "Sent you a fit, hbu?",
                "FITCHECK!",
                "Your fit check is on point!",
                "Lookin' sharp, fit check!"
            ]
            return options.randomElement() ?? "FITCHECK!"
        case "Spicy":
            let options = [
                "oooOoo ;)",
                "Spicy time!",
                "I want your pix ;)",
                "Hot stuff coming your way!",
                "Spice it up!",
                "Clothes off Pix On!"
            ]
            return options.randomElement() ?? "Spicy time!"
        default:
            return "Pix sent!"
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthManager())
    }
}
