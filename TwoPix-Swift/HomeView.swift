import SwiftUI
import AVFoundation

// MARK: - HomeView with Carousel and Top Right Buttons

struct HomeView: View {
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var authManager = AuthManager() // Assumes you have an AuthManager in your project.
    @State private var showChat = false
    @State private var showProfile = false

    var body: some View {
        Group {
            if authManager.isAuthenticated {
                if authManager.isConnected {
                    ZStack {
                        // Live camera preview as the background.
                        CameraPreviewView(cameraManager: cameraManager)
                            .ignoresSafeArea()
                        
                        VStack {
                            // Top-right overlay buttons.
                            HStack {
                                Spacer()
                                HStack(spacing: 16) {
                                    // Chat Button
                                    Button(action: {
                                        showChat = true
                                    }) {
                                        Image(systemName: "message.fill")
                                            .foregroundColor(.white)
                                            .padding(8)
                                            .background(Circle().fill(Color.black.opacity(0.5)))
                                    }
                                    // Profile Button
                                    Button(action: {
                                        showProfile = true
                                    }) {
                                        Image(systemName: "person.crop.circle")
                                            .foregroundColor(.white)
                                            .padding(8)
                                            .background(Circle().fill(Color.black.opacity(0.5)))
                                    }
                                    // Flip Camera Button
                                    Button(action: {
                                        cameraManager.flipCamera()
                                    }) {
                                        Image(systemName: "camera.rotate.fill")
                                            .foregroundColor(.white)
                                            .padding(8)
                                            .background(Circle().fill(Color.black.opacity(0.5)))
                                    }
                                    // Flash Button
                                    Button(action: {
                                        cameraManager.toggleFlash()
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
                            
                            // Carousel of buttons at the bottom.
                            TabView(selection: .constant(1)) {
                                Button(action: {
                                    print("FitCheck tapped")
                                }) {
                                    Text("FitCheck")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(width: 80, height: 80)
                                        .background(Circle().fill(Color.red.opacity(0.7)))
                                }
                                .tag(0)
                                
                                Button(action: {
                                    print("Blank tapped")
                                }) {
                                    Text("")
                                        .frame(width: 80, height: 80)
                                        .background(Circle().fill(Color.gray))
                                }
                                .tag(1)
                                
                                Button(action: {
                                    print("Spicy tapped")
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
                        
                        // NavigationLinks to ChatView and ProfileView.
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
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
