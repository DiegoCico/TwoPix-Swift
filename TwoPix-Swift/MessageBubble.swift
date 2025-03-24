import SwiftUI
import FirebaseAuth

struct MessageBubble: View {
    let message: ChatMessage
    var onPhotoTap: (() -> Void)? = nil
    @State private var showTimestamp = false

    var isCurrentUser: Bool {
        message.sender == Auth.auth().currentUser?.uid
    }

    var body: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
            HStack {
                if isCurrentUser { Spacer() }

                Group {
                    if message.messageType == "text" {
                        Text(message.text ?? "")
                            .padding(12)
                            .background(isCurrentUser ? Color.blue : Color(.systemGray5))
                            .foregroundColor(isCurrentUser ? .white : .primary)
                    } else if message.messageType == "photo",
                              let photoURL = message.photoURL,
                              let url = URL(string: photoURL) {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: 220, maxHeight: 220)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .onTapGesture { onPhotoTap?() }
                            } else if phase.error != nil {
                                Text("⚠️")
                                    .padding(12)
                                    .background(Color.red.opacity(0.2))
                            } else {
                                ProgressView()
                                    .frame(width: 80, height: 80)
                            }
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .onTapGesture {
                    withAnimation { showTimestamp.toggle() }
                }

                if !isCurrentUser { Spacer() }
            }

            if showTimestamp {
                HStack(spacing: 4) {
                    if isCurrentUser { Spacer() }

                    Text(message.timestamp.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption2)
                        .foregroundColor(.gray)

                    if isCurrentUser {
                        Image(systemName: message.seen ? "checkmark.circle.fill" : "checkmark.circle")
                            .font(.caption)
                            .foregroundColor(message.seen ? .green : .gray)
                    }

                    if !isCurrentUser { Spacer() }
                }
                .padding(.horizontal, 10)
                .transition(.opacity)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 4)
        .id(message.id)
    }
}
