import UIKit
import AVFoundation

// Custom UIView subclass whose main layer is AVCaptureVideoPreviewLayer.
class CameraPreviewUIView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        return self.layer as! AVCaptureVideoPreviewLayer
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // For debugging, show a green border so you know the view is visible.
        self.layer.borderColor = UIColor.green.cgColor
        self.layer.borderWidth = 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
