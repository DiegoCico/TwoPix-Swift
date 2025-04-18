import SwiftUI

struct ChatInputBar: View {
    @Binding var message: String
    var onSend: () -> Void
    var onImagePicker: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onImagePicker) {
                Image(systemName: "photo.fill")
                    .font(.system(size: 22))
            }

            TextField("Type a message…", text: $message)
                .padding(10)
                .background(Color(.systemGray5))
                .clipShape(Capsule())

            Button(action: onSend) {
                Image(systemName: "paperplane.fill")
                    .rotationEffect(.degrees(45))
                    .opacity(canSend ? 1 : 0.5)
            }
            .disabled(!canSend)
        }
        .padding(.horizontal, 16)
    }

    private var canSend: Bool {
        !message.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
