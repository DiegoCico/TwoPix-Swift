import SwiftUI

struct PhotoPreviewOverlay: View {
    let capturedImage: UIImage
    let onCancel: () -> Void
    let onSend: () -> Void

    var body: some View {
        ZStack {
            // Display the captured image full-screen.
            Image(uiImage: capturedImage)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Top right cancel (X) button.
                HStack {
                    Spacer()  // Pushes the button to the right.
                    Button(action: onCancel) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                    }
                    .padding()
                }
                
                Spacer()
                
                // Bottom right send button.
                HStack {
                    Spacer()  // Pushes the button to the right.
                    Button(action: onSend) {
                        Text("Send")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
        }
    }
}
