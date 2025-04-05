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
                    if message.messageType.lowercased() == "text" {
                        Text(message.text ?? "")
                            .padding(12)
                            .background(isCurrentUser ? Color.blue : Color(.systemGray5))
                            .foregroundColor(isCurrentUser ? .white : .primary)
                    } else if let photoURL = message.photoURL,
                              let url = URL(string: photoURL) {
                        // Use AsyncImage to load the image.
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                // Determine how to display based on the messageType.
                                let type = message.messageType.lowercased()
                                Group {
                                    if type == "spicy" {
                                        // Spicy images are blurred.
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(maxWidth: 220, maxHeight: 220)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                            .blur(radius: 10)
                                    } else if type == "fitcheck" {
                                        // FitCheck images get an overlay label.
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(maxWidth: 220, maxHeight: 220)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                            .overlay(
                                                Text("Fit Check")
                                                    .font(.caption)
                                                    .padding(4)
                                                    .background(Color.black.opacity(0.5))
                                                    .foregroundColor(.white)
                                                    .cornerRadius(8),
                                                alignment: .bottomTrailing
                                            )
                                    } else {
                                        // For "photo" and "normal" types.
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(maxWidth: 220, maxHeight: 220)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                    }
                                }
                                .onTapGesture { onPhotoTap?() }
                            } else if let error = phase.error {
                                // Display error indicator and log the error.
                                Text("⚠️")
                                    .padding(12)
                                    .background(Color.red.opacity(0.2))
                                    .onAppear {
                                        print("AsyncImage error in MessageBubble: \(error.localizedDescription)")
                                    }
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
