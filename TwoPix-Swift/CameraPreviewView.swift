import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {
    @ObservedObject var cameraManager: CameraManager
    
    func makeUIView(context: Context) -> UIView {
        let view = CameraPreviewUIView()
        view.previewLayer.session = cameraManager.captureSession
        view.previewLayer.videoGravity = .resizeAspectFill
        print("makeUIView: initial frame: \(view.frame)")
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let previewView = uiView as? CameraPreviewUIView else { return }
        previewView.previewLayer.session = cameraManager.captureSession
        previewView.previewLayer.frame = uiView.bounds
        print("updateUIView: updated frame: \(uiView.bounds)")
    }
}
