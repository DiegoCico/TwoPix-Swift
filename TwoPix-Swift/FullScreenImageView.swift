import SwiftUI

struct FullScreenImageView: View {
    let photoURL: String
    @Environment(\.dismiss) var dismiss

    // Pinch-to-zoom state.
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    private let minScale: CGFloat = 1.0

    // Pan state for moving the image.
    @State private var offset: CGSize = .zero
    @State private var dragOffset: CGSize = .zero

    // State for tracking the vertical swipe for dismissal.
    @State private var swipeOffset: CGFloat = 0

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
                .onAppear {
                    print("FullScreenImageView: Background appeared.")
                }

            AsyncImage(url: URL(string: photoURL)) { phase in
                Group {
                    switch phase {
                    case .empty:
                        ProgressView()
                            .onAppear { print("AsyncImage: Loading image...") }
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(scale)
                            .offset(x: offset.width + dragOffset.width,
                                    y: offset.height + dragOffset.height)
                            // Combine pinch-to-zoom and panning gestures.
                            .gesture(
                                magnificationGesture()
                                    .simultaneously(with: panGesture())
                            )
                            .onAppear { print("AsyncImage: Image loaded successfully.") }
                    case .failure(let error):
                        VStack {
                            Text("Failed to load image.")
                                .foregroundColor(.white)
                            Text(error.localizedDescription)
                                .foregroundColor(.white)
                                .font(.caption)
                        }
                        .onAppear {
                            print("AsyncImage: Error loading image: \(error.localizedDescription)")
                        }
                    @unknown default:
                        EmptyView()
                            .onAppear { print("AsyncImage: Unknown phase encountered.") }
                    }
                }
            }
        }
        // Apply the vertical swipe offset for interactive feedback.
        .offset(y: swipeOffset)
        // Attach the swipe-down gesture to the entire view.
        .gesture(swipeDownToDismiss())
        .onAppear {
            print("FullScreenImageView initialized with photoURL: \(photoURL)")
        }
    }

    // MARK: - Gestures

    /// Pinch-to-zoom that prevents zooming out below the original scale.
    private func magnificationGesture() -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let newScale = lastScale * value
                scale = max(newScale, minScale)
            }
            .onEnded { value in
                let newScale = lastScale * value
                lastScale = max(newScale, minScale)
                scale = lastScale
            }
    }
    
    /// Pan gesture to move the image.
    private func panGesture() -> some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation
            }
            .onEnded { value in
                offset.width += value.translation.width
                offset.height += value.translation.height
                dragOffset = .zero
            }
    }
    
    /// Swipe-down gesture that dismisses the view on a short, quick swipe.
    private func swipeDownToDismiss() -> some Gesture {
        DragGesture(minimumDistance: 20)
            .onChanged { value in
                // Only allow a limited vertical drag to give feedback.
                let drag = value.translation.height
                if drag > 0 {
                    // Limit the interactive offset so it doesn't move too far.
                    swipeOffset = min(drag, 80)
                } else {
                    swipeOffset = 0
                }
            }
            .onEnded { value in
                // Use a small threshold (e.g., 30 points) to detect a valid swipe.
                if value.translation.height > 30 {
                    // Animate the view off-screen quickly.
                    withAnimation(.easeOut(duration: 0.3)) {
                        swipeOffset = 600 // This value sends the view off-screen.
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        dismiss()
                    }
                } else {
                    // Otherwise, restore the view to its original position.
                    withAnimation(.easeOut(duration: 0.2)) {
                        swipeOffset = 0
                    }
                }
            }
    }
}

struct FullScreenImageView_Previews: PreviewProvider {
    static var previews: some View {
        FullScreenImageView(photoURL: "https://via.placeholder.com/600")
    }
}
