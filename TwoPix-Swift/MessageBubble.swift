import SwiftUI
import FirebaseAuth

struct MessageBubble: View {
    let message: ChatMessage
    var onPhotoTap: (() -> Void)?

    @State private var showTimestamp = false
    @State private var isImageBlurred = true
    @State private var reloadTrigger = UUID()

    private var isCurrent: Bool {
        message.sender == Auth.auth().currentUser?.uid
    }

    var body: some View {
        HStack {
            if isCurrent { Spacer() }

            bubbleContent
                .background(isCurrent ? Color.blue : Color(.systemGray5))
                .foregroundColor(isCurrent ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .onTapGesture { withAnimation { showTimestamp.toggle() } }
                .padding(isCurrent ? .leading : .trailing, 60)

            if !isCurrent { Spacer() }
        }
        .overlay(
            timestampView
                .offset(y: showTimestamp ? -30 : -10)
                .opacity(showTimestamp ? 1 : 0),
            alignment: isCurrent ? .topTrailing : .topLeading
        )
    }

    @ViewBuilder
    private var bubbleContent: some View {
        if message.messageType.lowercased() == "text" {
            Text(message.text ?? "")
                .padding(12)
        } else {
            AsyncImage(url: URL(string: message.photoURL ?? "")) { phase in
                if let image = phase.image {
                    contentImage(image: image)
                }
                else if phase.error != nil {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray5))
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: 220, maxHeight: 220)
                    .onTapGesture { reloadTrigger = UUID() }
                }
                else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray5))
                        ProgressView()
                    }
                    .frame(maxWidth: 220, maxHeight: 220)
                }
            }
            .id(reloadTrigger)
        }
    }

    private func contentImage(image: Image) -> some View {
        let type = message.messageType.lowercased()
        return Group {
            if type == "spicy" {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: 220, maxHeight: 220)
                    .blur(radius: isImageBlurred ? 10 : 0)
                    .overlay(
                        Text(isImageBlurred ? "Tap to reveal" : "")
                            .font(.caption2).bold()
                            .padding(6)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(8)
                            .padding(8),
                        alignment: .bottom
                    )
                    .onTapGesture { withAnimation { isImageBlurred.toggle() } }
            } else {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: 220, maxHeight: 220)
                    .onTapGesture { onPhotoTap?() }
            }
        }
        .frame(maxWidth: 220, maxHeight: 220)
        .clipped()
    }

    private var timestampView: some View {
        HStack(spacing: 4) {
            Text(message.timestamp, style: .time)
                .font(.caption2)
                .foregroundColor(.gray)
            if isCurrent {
                Image(systemName: message.seen ? "checkmark.circle.fill" : "checkmark.circle")
                    .font(.caption2)
                    .foregroundColor(message.seen ? .green : .gray)
            }
        }
        .padding(6)
        .background(Color(.systemBackground).opacity(0.8))
        .cornerRadius(8)
    }
}
