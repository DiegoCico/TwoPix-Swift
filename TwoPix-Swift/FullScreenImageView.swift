import SwiftUI

struct FullScreenImageView: View {
    let photoURL: String
    @Environment(\.dismiss) var dismiss

    // State variables to track zoom scale and panning offset.
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var dragOffset: CGSize = .zero

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
                            // Apply zoom and pan effects.
                            .scaleEffect(scale)
                            .offset(x: offset.width + dragOffset.width,
                                    y: offset.height + dragOffset.height)
                            // Allow pinch-to-zoom.
                            .gesture(magnificationGesture())
                            // Allow panning the zoomed image.
                            .gesture(panGesture())
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
        // Attach a swipe down gesture to dismiss the view.
        .gesture(swipeDownToDismiss())
        .onAppear {
            print("FullScreenImageView initialized with photoURL: \(photoURL)")
        }
    }

    // MARK: - Gestures

    // Magnification (pinch) gesture for zooming.
    private func magnificationGesture() -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = lastScale * value
            }
            .onEnded { _ in
                lastScale = scale
            }
    }

    // Drag gesture for panning the image.
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

    // Drag gesture for swiping down to dismiss.
    private func swipeDownToDismiss() -> some Gesture {
        DragGesture(minimumDistance: 30)
            .onEnded { value in
                // Check if the gesture is predominantly a downward swipe.
                if abs(value.translation.width) < 50 && value.translation.height > 100 {
                    print("Swipe down detected. Dismissing view.")
                    dismiss()
                }
            }
    }
}
