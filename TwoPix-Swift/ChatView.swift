import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// Updated ChatMessage model to include photoURL, messageType, timestamp, and sender.
struct ChatMessage: Identifiable {
    var id: String
    var text: String?
    var photoURL: String?
    var messageType: String  // "text" or "photo"
    var timestamp: Date
    var sender: String
    
    init?(document: DocumentSnapshot) {
        let data = document.data()
        guard let timestamp = data?["timestamp"] as? Timestamp,
              let sender = data?["sender"] as? String,
              let messageType = data?["messageType"] as? String else {
            return nil
        }
        self.id = document.documentID
        self.text = data?["text"] as? String
        self.photoURL = data?["photoURL"] as? String
        self.timestamp = timestamp.dateValue()
        self.sender = sender
        self.messageType = messageType
    }
}

struct ChatView: View {
    let pixCode: String  // Unique pix code for this chat session.
    
    @State private var messages: [ChatMessage] = []
    @State private var newMessage: String = ""
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        NavigationView {
            VStack {
                // Display chat messages.
                List(messages) { message in
                    HStack(alignment: .top) {
                        if message.messageType == "photo", let photoURL = message.photoURL, let url = URL(string: photoURL) {
                            AsyncImage(url: url) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: 200, maxHeight: 200)
                                } else if phase.error != nil {
                                    Text("Error loading image")
                                } else {
                                    ProgressView()
                                }
                            }
                        } else if message.messageType == "text", let text = message.text {
                            Text(text)
                                .padding(8)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                        Spacer()
                    }
                }
                .listStyle(PlainListStyle())
                .onAppear(perform: loadMessages)
                
                // Chat input area.
                HStack {
                    TextField("Enter message", text: $newMessage)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: sendTextMessage) {
                        Text("Send")
                    }
                    
                    // Button to attach a photo.
                    Button(action: {
                        showImagePicker = true
                    }) {
                        Image(systemName: "photo")
                    }
                }
                .padding()
            }
            .navigationTitle("Chat")
            .sheet(isPresented: $showImagePicker, onDismiss: {
                if let image = selectedImage {
                    sendPhotoMessage(image: image)
                }
            }) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
    }
    
    // Listen to real-time updates on the chats subcollection.
    private func loadMessages() {
        let db = Firestore.firestore()
        db.collection("pixcodes")
            .document(pixCode)
            .collection("chats")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching messages: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                messages = documents.compactMap { ChatMessage(document: $0) }
            }
    }
    
    // Send a text message.
    private func sendTextMessage() {
        guard !newMessage.isEmpty else { return }
        let db = Firestore.firestore()
        let data: [String: Any] = [
            "text": newMessage,
            "timestamp": Timestamp(date: Date()),
            "sender": Auth.auth().currentUser?.uid ?? "unknown",
            "messageType": "text"
        ]
        db.collection("pixcodes")
            .document(pixCode)
            .collection("chats")
            .addDocument(data: data) { error in
                if let error = error {
                    print("Error sending message: \(error.localizedDescription)")
                }
            }
        newMessage = ""
    }
    
    // Upload the photo and then create a chat message with the photo URL.
    private func sendPhotoMessage(image: UIImage) {
        FirebasePhotoUploader.shared.uploadPhoto(image: image, pixCode: pixCode, photoTag: "ChatPhoto") { urlString, error in
            if let error = error {
                print("Error uploading photo: \(error.localizedDescription)")
                return
            }
            guard let photoURL = urlString else { return }
            let db = Firestore.firestore()
            let data: [String: Any] = [
                "photoURL": photoURL,
                "timestamp": Timestamp(date: Date()),
                "sender": Auth.auth().currentUser?.uid ?? "unknown",
                "messageType": "photo"
            ]
            db.collection("pixcodes")
                .document(pixCode)
                .collection("chats")
                .addDocument(data: data) { error in
                    if let error = error {
                        print("Error sending photo message: \(error.localizedDescription)")
                    }
                }
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(pixCode: "TEST_PIXCODE")
    }
}
