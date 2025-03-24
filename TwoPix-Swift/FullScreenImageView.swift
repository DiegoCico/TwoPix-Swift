import SwiftUI

struct FullScreenImageView: View {
    let photoURL: String
    @Binding var isPresented: Bool

    @State private var image: UIImage? = nil
    @State private var isLoading = true

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
                Text("Failed to load image")
                    .foregroundColor(.white)
            }
        }
        .onAppear(perform: loadImage)
        .onTapGesture { isPresented = false }
    }
    
    private func loadImage() {
        guard let url = URL(string: photoURL) else {
            print("Invalid URL: \(photoURL)")
            isLoading = false
            return
        }
        print("Attempting to load image from URL: \(url)")
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    print("Error loading image: \(error.localizedDescription)")
                }
                if let data = data {
                    print("Received image data: \(data.count) bytes")
                    if let uiImage = UIImage(data: data) {
                        print("Image successfully loaded")
                        self.image = uiImage
                    } else {
                        print("Failed to convert data to UIImage")
                    }
                } else {
                    print("No image data received from URL: \(url)")
                }
            }
        }.resume()
    }
}
