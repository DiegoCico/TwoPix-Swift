import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// ChatMessage model with text, photoURL, messageType, timestamp, and sender.
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
    
    // For full screen photo viewing.
    @State private var fullScreenPhotoURL: String? = nil
    @State private var isFullScreenPresented: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollViewReader { scrollViewProxy in
                    List(messages) { message in
                        MessageBubble(message: message, onPhotoTap: message.messageType == "photo" ? {
                            if let url = message.photoURL {
                                fullScreenPhotoURL = url
                                isFullScreenPresented = true
                            }
                        } : nil)
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(PlainListStyle())
                    .onChange(of: messages.count) { _ in
                        if let lastMessage = messages.last {
                            withAnimation {
                                scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                    .onAppear(perform: loadMessages)
                }
                
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
            // Full screen cover for the tapped photo.
            .fullScreenCover(isPresented: $isFullScreenPresented, onDismiss: {
                fullScreenPhotoURL = nil
            }) {
                if let url = fullScreenPhotoURL {
                    FullScreenImageView(photoURL: url, isPresented: $isFullScreenPresented)
                }
            }
        }
    }
    
    // Load messages from Firestore in real time.
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
    
    // Upload photo and add it as a chat message.
    private func sendPhotoMessage(image: UIImage) {
        FirebasePhotoUploader.shared.uploadPhoto(image: image, pixCode: pixCode, photoTag: "ChatPhoto") { urlString, error in
            if let error = error {
                print("Error uploading photo: \(error.localizedDescription)")
            } else if let photoURL = urlString {
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
                            print("Error adding photo message to chat: \(error.localizedDescription)")
                        } else {
                            print("Photo message added to chat successfully")
                        }
                    }
                DispatchQueue.main.async {
                    selectedImage = nil
                }
            }
        }
    }
}

// Chat bubble view for individual messages.
struct MessageBubble: View {
    let message: ChatMessage
    var onPhotoTap: (() -> Void)? = nil
    var isCurrentUser: Bool {
        message.sender == Auth.auth().currentUser?.uid
    }
    
    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer()
                bubbleContent
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
            } else {
                bubbleContent
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.black)
                    .cornerRadius(12)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                Spacer()
            }
        }
        .id(message.id)
    }
    
    @ViewBuilder
    var bubbleContent: some View {
        if message.messageType == "text" {
            Text(message.text ?? "")
                .padding(10)
        } else if message.messageType == "photo",
                  let photoURL = message.photoURL,
                  let url = URL(string: photoURL) {
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 200, maxHeight: 200)
                        .onTapGesture {
                            onPhotoTap?()
                        }
                } else if phase.error != nil {
                    Text("Error loading image")
                        .padding(10)
                } else {
                    ProgressView()
                        .padding(10)
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
