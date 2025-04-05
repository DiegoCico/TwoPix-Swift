import SwiftUI

struct FullScreenImageView: View {
    let photoURL: String
    @Environment(\.dismiss) var dismiss

    // State for pinch-to-zoom and panning.
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
                            .scaleEffect(scale)
                            .offset(x: offset.width + dragOffset.width,
                                    y: offset.height + dragOffset.height)
                            .gesture(magnificationGesture())
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
        // Attach a swipe-down gesture to dismiss.
        .gesture(swipeDownToDismiss())
        .onAppear {
            print("FullScreenImageView initialized with photoURL: \(photoURL)")
        }
    }

    // MARK: - Gestures
    
    private func magnificationGesture() -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = lastScale * value
            }
            .onEnded { _ in
                lastScale = scale
            }
    }
    
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
    
    private func swipeDownToDismiss() -> some Gesture {
        DragGesture(minimumDistance: 30)
            .onEnded { value in
                if abs(value.translation.width) < 50 && value.translation.height > 100 {
                    print("Swipe down detected. Dismissing view.")
                    dismiss()
                }
            }
    }
}
