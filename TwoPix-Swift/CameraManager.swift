import AVFoundation
import SwiftUI

class CameraManager: NSObject, ObservableObject {
    private let session = AVCaptureSession()
    
    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    @Published var cameraPermissionDenied: Bool = false
    @Published var microphonePermissionDenied: Bool = false
    @Published var capturedImage: UIImage? = nil  // Captured photo.
    
    var captureSession: AVCaptureSession {
        return session
    }
    
    private var currentInput: AVCaptureDeviceInput?
    @Published var currentCameraPosition: AVCaptureDevice.Position = .back
    private var isFlashOn: Bool = false
    private var photoOutput: AVCapturePhotoOutput?
    
    var isFrontCamera: Bool {
        return currentCameraPosition == .front
    }
    
    // MARK: - Permissions and Session Management
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
    
    func startSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.configureSession()
            self.session.startRunning()
            DispatchQueue.main.async {
                self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
                self.previewLayer?.videoGravity = .resizeAspectFill
                if let connection = self.previewLayer?.connection {
                    connection.videoOrientation = .portrait
                }
                print("Session is running: \(self.session.isRunning)")
            }
        }
    }
    
    private func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .photo
        
        // Remove existing inputs.
        for input in session.inputs {
            session.removeInput(input)
        }
        
        // Video input.
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
        
        // Audio input.
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
        
        // Photo output.
        let photoOutput = AVCapturePhotoOutput()
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            self.photoOutput = photoOutput
            print("Photo output added.")
        } else {
            print("Cannot add photo output.")
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
    
    // MARK: - Photo Capture
    func capturePhoto() {
        guard let photoOutput = photoOutput else { return }
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    // MARK: - Zoom Control
    func setZoomFactor(_ factor: CGFloat) {
        guard let device = currentInput?.device else { return }
        do {
            try device.lockForConfiguration()
            // Clamp the factor between 1.0 and device's max zoom.
            let newFactor = max(1.0, min(factor, device.activeFormat.videoMaxZoomFactor))
            device.videoZoomFactor = newFactor
            device.unlockForConfiguration()
            print("Zoom set to: \(newFactor)")
        } catch {
            print("Error setting zoom factor: \(error)")
        }
    }
    
    func currentZoomFactor() -> CGFloat {
        return currentInput?.device.videoZoomFactor ?? 1.0
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("Could not get image data")
            return
        }
        DispatchQueue.main.async {
            self.capturedImage = image
        }
    }
}
