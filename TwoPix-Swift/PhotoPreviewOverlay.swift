import SwiftUI

struct PhotoPreviewOverlay: View {
    let capturedImage: UIImage
    let onCancel: () -> Void   // Delete action
    let onSend: () -> Void     // Send action

    // Track the current drag offset.
    @State private var dragOffset: CGSize = .zero

    // Threshold for triggering an action.
    private let swipeThreshold: CGFloat = 100

    var body: some View {
        ZStack {
            // Display the photo full-screen and move it based on drag.
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
                                // Left swipe: animate off screen then send.
                                withAnimation(.easeOut(duration: 0.3)) {
                                    dragOffset = CGSize(width: -1000, height: 0)
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onSend()
                                }
                            } else if value.translation.width > swipeThreshold {
                                // Right swipe: animate off screen then delete.
                                withAnimation(.easeOut(duration: 0.3)) {
                                    dragOffset = CGSize(width: 1000, height: 0)
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onCancel()
                                }
                            } else {
                                // Not enough swipe: reset to center.
                                withAnimation(.spring()) {
                                    dragOffset = .zero
                                }
                            }
                        }
                )
            
            // Gradient overlay for feedback.
            if dragOffset.width < 0 {
                // Blue gradient for sending (swipe left).
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.7)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .opacity(min(1, -dragOffset.width / 150))
                .animation(.easeIn, value: dragOffset)
            } else if dragOffset.width > 0 {
                // Red gradient for deletion (swipe right).
                LinearGradient(
                    gradient: Gradient(colors: [Color.red.opacity(0.3), Color.red.opacity(0.7)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .opacity(min(1, dragOffset.width / 150))
                .animation(.easeIn, value: dragOffset)
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
