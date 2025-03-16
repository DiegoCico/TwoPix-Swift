import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// A simple model for chat messages.
struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    // You can extend this model to include photos, timestamps, etc.
}

struct ChatView: View {
    let pixCode: String  // Unique pix code for this chat session.
    
    @State private var messages: [ChatMessage] = []
    @State private var newMessage: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Display chat messages.
                List(messages) { message in
                    Text(message.text)
                        .padding(4)
                }
                .listStyle(PlainListStyle())
                
                // Chat input area.
                HStack {
                    // TextField for entering chat text.
                    TextField("Enter message", text: $newMessage)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    // Button to attach a photo.
                    Button(action: {
                        // TODO: Implement photo attachment functionality.
                        print("Attach Photo tapped")
                    }) {
                        Image(systemName: "photo")
                            .padding(8)
                    }
                    
                    // Button to send the message.
                    Button(action: sendMessage) {
                        Text("Send")
                            .padding(8)
                    }
                }
                .padding()
            }
            .navigationTitle("Chat")
        }
    }
    
    private func sendMessage() {
        guard !newMessage.isEmpty else { return }
        let message = ChatMessage(text: newMessage)
        messages.append(message)
        saveMessage(message)
        newMessage = ""
    }
    
    private func saveMessage(_ message: ChatMessage) {
        let db = Firestore.firestore()
        let data: [String: Any] = [
            "text": message.text,
            "timestamp": Timestamp(date: Date()),
            "sender": Auth.auth().currentUser?.uid ?? "unknown"
        ]
        // Save the message under: pixcodes/[pixCode]/chats
        db.collection("pixcodes")
            .document(pixCode)
            .collection("chats")
            .addDocument(data: data) { error in
                if let error = error {
                    print("Error saving message: \(error.localizedDescription)")
                } else {
                    print("Message saved successfully")
                }
            }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(pixCode: "TEST_PIXCODE")
    }
}
