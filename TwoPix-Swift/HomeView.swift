import SwiftUI
import AVFoundation

// MARK: - Camera Manager

class CameraManager: NSObject, ObservableObject {
    private let session = AVCaptureSession()
    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    
    func checkPermissions() {
        // Request Camera Permission
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if !granted {
                // Handle permission denial if needed.
                print("Camera access denied")
            }
        }
        // Request Microphone Permission
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            if !granted {
                // Handle permission denial if needed.
                print("Microphone access denied")
            }
        }
    }
    
    func startSession() {
        DispatchQueue.global(qos: .background).async {
            self.configureSession()
            self.session.startRunning()
            DispatchQueue.main.async {
                self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
                self.previewLayer?.videoGravity = .resizeAspectFill
            }
        }
    }
    
    private func configureSession() {
        session.beginConfiguration()
        
        // Video Input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                        for: .video,
                                                        position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              self.session.canAddInput(videoInput)
        else {
            session.commitConfiguration()
            return
        }
        session.addInput(videoInput)
        
        // Audio Input
        guard let audioDevice = AVCaptureDevice.default(for: .audio),
              let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
              self.session.canAddInput(audioInput)
        else {
            session.commitConfiguration()
            return
        }
        session.addInput(audioInput)
        
        session.commitConfiguration()
    }
}

// MARK: - Camera Preview View

struct CameraPreviewView: UIViewRepresentable {
    @ObservedObject var cameraManager: CameraManager
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        if let previewLayer = cameraManager.previewLayer {
            previewLayer.frame = view.bounds
            view.layer.addSublayer(previewLayer)
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Ensure the preview layer fills the view.
        if let previewLayer = cameraManager.previewLayer {
            previewLayer.frame = uiView.bounds
        }
    }
}

// MARK: - HomeView with Carousel Buttons

struct HomeView: View {
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var authManager = AuthManager()
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                if authManager.isConnected {
                    ZStack {
                        // Live camera preview as the background.
                        CameraPreviewView(cameraManager: cameraManager)
                            .ignoresSafeArea()

                        VStack {
                            Spacer()
                            // Carousel of buttons
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
                    }
                    .onAppear {
                        cameraManager.checkPermissions()
                        cameraManager.startSession()
                    }
                } else {
                    PixCodeView(fullName: authManager.fullName, username: authManager.username, dob: authManager.dob)
                }
            } else {
                AuthView()
            }
        }
    }
}

// MARK: - Preview

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
