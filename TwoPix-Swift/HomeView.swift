import SwiftUI
import AVFoundation

struct HomeView: View {
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var authManager = AuthManager() // Assumes AuthManager exists and is set up.
    @State private var showChat = false
    @State private var showProfile = false
    @State private var showPermissionAlert = false

    var body: some View {
        Group {
            if authManager.isAuthenticated {
                if authManager.isConnected {
                    ZStack {
                        // Bottom layer: Camera preview.
                        CameraPreviewView(cameraManager: cameraManager)
                            .ignoresSafeArea()
                        
                        // Overlay: Transparent controls.
                        VStack {
                            // Top controls (e.g., chat, profile, flip, flash)
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
                                    Button(action: { cameraManager.toggleFlash() }) {
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
                                Button(action: { print("FitCheck tapped") }) {
                                    Text("FitCheck")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(width: 80, height: 80)
                                        .background(Circle().fill(Color.red.opacity(0.7)))
                                }
                                .tag(0)
                                
                                Button(action: { print("Blank tapped") }) {
                                    Text("")
                                        .frame(width: 80, height: 80)
                                        .background(Circle().fill(Color.gray))
                                }
                                .tag(1)
                                
                                Button(action: { print("Spicy tapped") }) {
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
                        .background(Color.clear) // ensure overlay is transparent
                        
                        // Hidden NavigationLinks.
                        NavigationLink(destination: ChatView(pixCode: authManager.pixCode), isActive: $showChat) {
                            EmptyView()
                        }
                        NavigationLink(destination: ProfileView(), isActive: $showProfile) {
                            EmptyView()
                        }
                    }
                    .onAppear {
                        cameraManager.checkPermissions()
                        cameraManager.startSession()
                        print("HomeView appeared. Camera session should be running.")
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
                    PixCodeView(fullName: authManager.fullName,
                                username: authManager.username,
                                dob: authManager.dob)
                }
            } else {
                AuthView()
            }
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
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
