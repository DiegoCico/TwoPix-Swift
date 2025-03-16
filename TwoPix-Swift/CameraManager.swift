import AVFoundation
import SwiftUI

class CameraManager: NSObject, ObservableObject {
    private let session = AVCaptureSession()
    
    // Published properties for debugging and permission tracking.
    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    @Published var cameraPermissionDenied: Bool = false
    @Published var microphonePermissionDenied: Bool = false
    
    // Expose the session so that the preview view can use it.
    var captureSession: AVCaptureSession {
        return session
    }
    
    private var currentInput: AVCaptureDeviceInput?
    private var currentCameraPosition: AVCaptureDevice.Position = .back
    private var isFlashOn: Bool = false
    
    // MARK: - Permissions
    func checkPermissions() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                self.cameraPermissionDenied = !granted
                print("Video permission granted: \(granted)")
            }
        }
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            DispatchQueue.main.async {
                self.microphonePermissionDenied = !granted
                print("Audio permission granted: \(granted)")
            }
        }
    }
    
    // MARK: - Session Management
    func startSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.configureSession()
            self.session.startRunning()
            DispatchQueue.main.async {
                // For debugging, create a preview layer (though our custom view will use the session directly)
                self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
                self.previewLayer?.videoGravity = .resizeAspectFill
                if let connection = self.previewLayer?.connection {
                    connection.videoOrientation = .portrait
                }
                print("Session is running: \(self.session.isRunning)")
                print("Session inputs count: \(self.session.inputs.count)")
            }
        }
    }
    
    private func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .photo
        
        // Remove any existing inputs.
        for input in session.inputs {
            session.removeInput(input)
        }
        
        // Configure video input.
        guard let videoDevice = getCamera(for: currentCameraPosition) else {
            print("No video device found.")
            session.commitConfiguration()
            return
        }
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
                currentInput = videoInput
                print("Video input added: \(videoDevice.localizedName)")
            } else {
                print("Cannot add video input.")
            }
        } catch {
            print("Error creating video input: \(error.localizedDescription)")
        }
        
        // Configure audio input.
        guard let audioDevice = AVCaptureDevice.default(for: .audio) else {
            print("No audio device found.")
            session.commitConfiguration()
            return
        }
        do {
            let audioInput = try AVCaptureDeviceInput(device: audioDevice)
            if session.canAddInput(audioInput) {
                session.addInput(audioInput)
                print("Audio input added: \(audioDevice.localizedName)")
            } else {
                print("Cannot add audio input.")
            }
        } catch {
            print("Error creating audio input: \(error.localizedDescription)")
        }
        
        session.commitConfiguration()
    }
    
    private func getCamera(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: position
        )
        return discoverySession.devices.first
    }
    
    // MARK: - Camera Controls
    func flipCamera() {
        currentCameraPosition = (currentCameraPosition == .back) ? .front : .back
        DispatchQueue.global(qos: .userInitiated).async {
            self.configureSession()
            print("Camera flipped to: \(self.currentCameraPosition)")
        }
    }
    
    func toggleFlash() {
        guard let device = currentInput?.device, device.hasTorch else {
            print("Torch not available.")
            return
        }
        do {
            try device.lockForConfiguration()
            if isFlashOn {
                device.torchMode = .off
            } else {
                try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
            }
            device.unlockForConfiguration()
            isFlashOn.toggle()
            print("Flash toggled. New state: \(isFlashOn)")
        } catch {
            print("Error toggling flash: \(error)")
        }
    }
}
