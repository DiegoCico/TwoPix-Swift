import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {
    @ObservedObject var cameraManager: CameraManager
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        
        // If the preview layer is already set, add it as a sublayer.
        if let previewLayer = cameraManager.previewLayer {
            previewLayer.frame = view.bounds
            view.layer.addSublayer(previewLayer)
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Ensure the preview layer always fits the view bounds.
        if let previewLayer = cameraManager.previewLayer {
            previewLayer.frame = uiView.bounds
        }
    }
}
