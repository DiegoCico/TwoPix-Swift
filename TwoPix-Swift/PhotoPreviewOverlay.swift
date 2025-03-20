import SwiftUI

struct PhotoPreviewOverlay: View {
    let capturedImage: UIImage
    let onCancel: () -> Void
    let onSend: () -> Void

    var body: some View {
        ZStack {
            // Full-screen captured image.
            Image(uiImage: capturedImage)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            // Debug yellow overlay to confirm the overlay is drawn.
            Color.yellow.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Top row: Cancel button.
                HStack {
                    Spacer()
                    Button(action: onCancel) {
                        // Replace the system image with text "X" for debugging.
                        Text("X")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.red)
                            .frame(width: 60, height: 60)
                            .background(Color.white)
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Color.blue, lineWidth: 2)
                            )
                    }
                    .padding(.top, 50)
                    .padding(.trailing, 20)
                }
                
                Spacer()
                
                // Bottom row: Send button.
                HStack {
                    Spacer()
                    Button(action: onSend) {
                        Text("Send")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.green, lineWidth: 2)
                            )
                    }
                    .padding(.bottom, 50)
                    .padding(.trailing, 20)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .zIndex(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
