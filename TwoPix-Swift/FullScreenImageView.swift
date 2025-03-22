import SwiftUI

struct FullScreenImageView: View {
    let photoURL: String
    @Binding var isPresented: Bool
    @State private var dragOffset = CGSize.zero
    private let dismissThreshold: CGFloat = 150

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            AsyncImage(url: URL(string: photoURL)) { phase in
                switch phase {
                case .empty:
                    VStack {
                        ProgressView("Loading...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        Text("Loading image from: \(photoURL)")
                            .foregroundColor(.white)
                            .font(.caption)
                            .padding(.top, 8)
                    }
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .offset(y: dragOffset.height)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    dragOffset = value.translation
                                }
                                .onEnded { _ in
                                    if dragOffset.height > dismissThreshold {
                                        withAnimation {
                                            isPresented = false
                                        }
                                    } else {
                                        withAnimation {
                                            dragOffset = .zero
                                        }
                                    }
                                }
                        )
                case .failure(let error):
                    VStack {
                        Text("Failed to load image.")
                            .foregroundColor(.white)
                        Text(error.localizedDescription)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                        Text("URL: \(photoURL)")
                            .foregroundColor(.white)
                            .font(.caption)
                    }
                @unknown default:
                    EmptyView()
                }
            }
        }
        .transition(.move(edge: .bottom))
        .onAppear {
            print("FullScreenImageView loading URL: \(photoURL)")
        }
    }
}

struct FullScreenImageView_Previews: PreviewProvider {
    @State static var isPresented = true
    static var previews: some View {
        FullScreenImageView(photoURL: "https://via.placeholder.com/300", isPresented: $isPresented)
    }
}
