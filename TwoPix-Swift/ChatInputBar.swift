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

            TextField("Message...", text: $message)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(16)

            Button(action: onSend) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 22))
                    .rotationEffect(.degrees(45))
            }
            .disabled(message.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
