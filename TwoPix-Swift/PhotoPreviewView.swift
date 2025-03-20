import SwiftUI

struct PhotoPreviewView: View {
    let image: UIImage
    let onCancel: () -> Void
    let onSend: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                Spacer()
            }
            
            HStack {
                // Cancel button.
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .padding()
                        .background(Circle().fill(Color.black.opacity(0.5)))
                }
                .padding(.leading, 20)
                
                Spacer()
                
                // Send button.
                Button(action: onSend) {
                    Text("Send")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Capsule().fill(Color.blue))
                }
                .padding(.trailing, 20)
            }
            .padding(.top, 40)
        }
    }
}

struct PhotoPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoPreviewView(image: UIImage(systemName: "photo")!, onCancel: {
            print("Cancel tapped")
        }, onSend: {
            print("Send tapped")
        })
    }
}
