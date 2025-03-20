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
            
            // Temporary visible background to ensure overlay is present.
            Color.yellow.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
                .zIndex(0)
            
            VStack {
                // Top row with cancel button.
                HStack {
                    Spacer()
                    Button(action: onCancel) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.red)
                            .background(Color.white)
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Color.blue, lineWidth: 4) // Debug border
                            )
                    }
                    .padding(.top, 50)
                    .padding(.trailing, 20)
                }
                
                Spacer()
                
                // Bottom row with send button.
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
                                    .stroke(Color.green, lineWidth: 4) // Debug border
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
