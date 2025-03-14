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
    @State private var currentSelection: Int = 1
    @StateObject private var cameraManager = CameraManager()
    
    var body: some View {
        ZStack {
            // Live camera preview as the background.
            CameraPreviewView(cameraManager: cameraManager)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                // Carousel of three circular buttons
                TabView(selection: $currentSelection) {
                    // Left button: FitCheck
                    Button(action: {
                        // Add FitCheck functionality here.
                        print("FitCheck tapped")
                    }) {
                        Text("FitCheck")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(Circle().fill(Color.red.opacity(0.7)))
                            .scaleEffect(currentSelection == 0 ? 1.2 : 1.0)
                    }
                    .tag(0)
                    
                    // Middle button: Blank
                    Button(action: {
                        // Add any functionality for the blank button.
                        print("Blank tapped")
                    }) {
                        Text("")
                            .frame(width: 80, height: 80)
                            .background(Circle().fill(Color.gray))
                            .scaleEffect(currentSelection == 1 ? 1.2 : 1.0)
                    }
                    .tag(1)
                    
                    // Right button: Spicy
                    Button(action: {
                        // Add Spicy functionality here.
                        print("Spicy tapped")
                    }) {
                        Text("Spicy")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(Circle().fill(Color.orange))
                            .scaleEffect(currentSelection == 2 ? 1.2 : 1.0)
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
    }
}

// MARK: - Preview

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
