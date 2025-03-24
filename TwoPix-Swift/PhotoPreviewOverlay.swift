import SwiftUI
import AVFoundation
import FirebaseFirestore
import FirebaseAuth

// MARK: - UIImage Extension for Unmirroring
extension UIImage {
    /// Returns a new image that is flipped horizontally (unmirrored).
    func unmirror() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        // Move the origin to the right edge, then flip horizontally.
        context.translateBy(x: self.size.width, y: 0)
        context.scaleBy(x: -1, y: 1)
        self.draw(in: CGRect(origin: .zero, size: self.size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()
        return newImage
    }
}

// MARK: - PhotoPreviewOverlay
struct PhotoPreviewOverlay: View {
    let capturedImage: UIImage
    let onCancel: () -> Void
    let onSend: () -> Void

    @State private var dragOffset: CGSize = .zero
    @State private var showSaveConfirmation = false

    // Adjust this threshold value to control how far the user must swipe.
    private let swipeThreshold: CGFloat = 100

    var body: some View {
        ZStack {
            // Display the captured image with drag and double-tap gestures.
            Image(uiImage: capturedImage)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .offset(x: dragOffset.width)
                .animation(.spring(), value: dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation
                        }
                        .onEnded { value in
                            if value.translation.width < -swipeThreshold {
                                // Left swipe: animate off-screen and call onCancel.
                                withAnimation(.easeOut(duration: 0.3)) {
                                    dragOffset = CGSize(width: -1000, height: 0)
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onCancel()
                                }
                            } else if value.translation.width > swipeThreshold {
                                // Right swipe: animate off-screen and call onSend.
                                withAnimation(.easeOut(duration: 0.3)) {
                                    dragOffset = CGSize(width: 1000, height: 0)
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onSend()
                                }
                            } else {
                                // Not far enough: reset the drag offset.
                                withAnimation(.spring()) {
                                    dragOffset = .zero
                                }
                            }
                        }
                )
                .onTapGesture(count: 2) {
                    // Double-tap to save the photo to Camera Roll.
                    UIImageWriteToSavedPhotosAlbum(capturedImage, nil, nil, nil)
                    withAnimation(.easeOut(duration: 0.3)) {
                        showSaveConfirmation = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation(.easeIn(duration: 0.3)) {
                            showSaveConfirmation = false
                        }
                    }
                }

            // Visual feedback: gradient overlay based on swipe direction.
            if dragOffset.width < 0 {
                // Left swipe: red overlay.
                LinearGradient(
                    gradient: Gradient(colors: [Color.red.opacity(0.3), Color.red.opacity(0.7)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .opacity(min(1, -dragOffset.width / 150))
                .animation(.easeIn, value: dragOffset)
            } else if dragOffset.width > 0 {
                // Right swipe: blue overlay.
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.7)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .opacity(min(1, dragOffset.width / 150))
                .animation(.easeIn, value: dragOffset)
            }

            // Save confirmation message when the image is saved via double-tap.
            if showSaveConfirmation {
                Text("Saved to Camera Roll")
                    .font(.headline)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .transition(.opacity.combined(with: .scale))
                    .zIndex(1)
            }
        }
    }
}

struct PhotoPreviewOverlay_Previews: PreviewProvider {
    static var previews: some View {
        PhotoPreviewOverlay(
            capturedImage: UIImage(systemName: "photo")!,
            onCancel: { print("Photo deleted") },
            onSend: { print("Photo sent") }
        )
    }
}
