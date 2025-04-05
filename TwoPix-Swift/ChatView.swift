import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// Make String conform to Identifiable so we can use it as an item in fullScreenCover.
extension String: Identifiable {
    public var id: String { self }
}

// MARK: - ChatMessage Model
struct ChatMessage: Identifiable {
    var id: String
    var text: String?
    var photoURL: String?
    var messageType: String
    var timestamp: Date
    var sender: String
    var seen: Bool

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
        self.seen = data?["seen"] as? Bool ?? false
    }
}

// MARK: - ChatView
struct ChatView: View {
    let pixCode: String

    @State private var messages: [ChatMessage] = []
    @State private var newMessage = ""
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    // Use an optional String as the item for the fullScreenCover.
    @State private var fullScreenPhotoURL: String? = nil

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    LazyVStack(spacing: 6) {
                        ForEach(messages) { message in
                            MessageBubble(
                                message: message,
                                onPhotoTap: {
                                    print("Tapped photo, URL: \(message.photoURL ?? "nil")")
                                    fullScreenPhotoURL = message.photoURL
                                }
                            )
                            .onAppear {
                                markAsSeen(message)
                            }
                        }
                    }
                    .padding(.top, 12)
                }
                .background(Color(.systemGroupedBackground))
                .onChange(of: messages.count) { _ in
                    if let lastMessage = messages.last {
                        withAnimation {
                            scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onAppear(perform: loadMessages)
            }
            
            ChatInputBar(
                message: $newMessage,
                onSend: sendTextMessage,
                onImagePicker: { showImagePicker = true }
            )
            .background(Color(.systemBackground).ignoresSafeArea(.keyboard))
            .shadow(color: .black.opacity(0.05), radius: 4, y: -2)
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showImagePicker, onDismiss: {
            if let image = selectedImage {
                sendPhotoMessage(image: image)
            }
        }) {
            ImagePicker(selectedImage: $selectedImage)
        }
        // Use the item-based full screen cover. When fullScreenPhotoURL is non-nil, the view is presented.
        .fullScreenCover(item: $fullScreenPhotoURL) { url in
            FullScreenImageView(photoURL: url)
        }
    }
    
    // MARK: - Helper Functions
    private func loadMessages() {
        let db = Firestore.firestore()
        db.collection("pixcodes")
            .document(pixCode)
            .collection("chats")
            .order(by: "timestamp")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching messages: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                messages = documents.compactMap { ChatMessage(document: $0) }
            }
    }
    
    private func sendTextMessage() {
        guard !newMessage.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let db = Firestore.firestore()
        let data: [String: Any] = [
            "text": newMessage,
            "timestamp": Timestamp(date: Date()),
            "sender": Auth.auth().currentUser?.uid ?? "unknown",
            "messageType": "text",
            "seen": false
        ]
        db.collection("pixcodes")
            .document(pixCode)
            .collection("chats")
            .addDocument(data: data)
        newMessage = ""
    }
    
    private func sendPhotoMessage(image: UIImage) {
        FirebasePhotoUploader.shared.uploadPhoto(image: image, pixCode: pixCode, photoTag: "ChatPhoto") { urlString, error in
            if let url = urlString {
                let db = Firestore.firestore()
                let data: [String: Any] = [
                    "photoURL": url,
                    "timestamp": Timestamp(date: Date()),
                    "sender": Auth.auth().currentUser?.uid ?? "unknown",
                    "messageType": "photo",
                    "seen": false
                ]
                db.collection("pixcodes")
                    .document(pixCode)
                    .collection("chats")
                    .addDocument(data: data)
            }
        }
    }
    
    private func markAsSeen(_ message: ChatMessage) {
        guard message.sender != Auth.auth().currentUser?.uid else { return }
        guard !message.seen else { return }
        let db = Firestore.firestore()
        db.collection("pixcodes")
            .document(pixCode)
            .collection("chats")
            .document(message.id)
            .updateData(["seen": true])
    }
}
