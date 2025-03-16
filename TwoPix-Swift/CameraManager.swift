import AVFoundation
import SwiftUI

class CameraManager: NSObject, ObservableObject {
    private let session = AVCaptureSession()
    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    
    private var currentInput: AVCaptureDeviceInput?
    private var currentCameraPosition: AVCaptureDevice.Position = .back
    private var isFlashOn: Bool = false
    
    // Check camera and microphone permissions.
    func checkPermissions() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if !granted {
                print("Camera access denied")
            }
        }
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            if !granted {
                print("Microphone access denied")
            }
        }
    }
    
    // Start the camera session on a background thread.
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
    
    // Configure the session inputs.
    private func configureSession() {
        session.beginConfiguration()
        
        // Remove existing inputs.
        for input in session.inputs {
            session.removeInput(input)
        }
        
        // Configure video input.
        guard let videoDevice = getCamera(for: currentCameraPosition),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              session.canAddInput(videoInput)
        else {
            session.commitConfiguration()
            return
        }
        session.addInput(videoInput)
        currentInput = videoInput
        
        // Configure audio input.
        guard let audioDevice = AVCaptureDevice.default(for: .audio),
              let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
              session.canAddInput(audioInput)
        else {
            session.commitConfiguration()
            return
        }
        session.addInput(audioInput)
        
        session.commitConfiguration()
    }
    
    // Return the camera device for the given position.
    private func getCamera(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: position
        )
        return discoverySession.devices.first
    }
    
    // Toggle between front and back cameras.
    func flipCamera() {
        currentCameraPosition = (currentCameraPosition == .back) ? .front : .back
        DispatchQueue.global(qos: .background).async {
            self.configureSession()
        }
    }
    
    // Toggle the flash (torch) mode if available.
    func toggleFlash() {
        guard let device = currentInput?.device, device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            if isFlashOn {
                device.torchMode = .off
            } else {
                try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
            }
            device.unlockForConfiguration()
            isFlashOn.toggle()
        } catch {
            print("Error toggling flash: \(error)")
        }
    }
}
