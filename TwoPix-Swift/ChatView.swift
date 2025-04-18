import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine

// Allow using String? with fullScreenCover(item:)
extension String: Identifiable {
    public var id: String { self }
}

struct ChatView: View {
    let pixCode: String
    @Environment(\.presentationMode) private var presentationMode

    @State private var messages: [ChatMessage] = []
    @State private var newMessage: String = ""
    @State private var showImagePicker: Bool = false
    @State private var selectedImage: UIImage?
    @State private var fullScreenPhotoURL: String? = nil

    // Track keyboard height
    @State private var keyboardHeight: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            // Nav Bar
            HStack {
                Button { presentationMode.wrappedValue.dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }
                Text("Chat")
                    .font(.headline)
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6).opacity(0.8))

            // Messages List
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(messages) { msg in
                            MessageBubble(message: msg) {
                                fullScreenPhotoURL = msg.photoURL
                            }
                            .id(msg.id)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .onChange(of: messages.count) { _ in
                    if let lastID = messages.last?.id {
                        proxy.scrollTo(lastID, anchor: .bottom)
                    }
                }
                .onAppear(perform: loadMessages)
            }

            // Input Bar (moved higher)
            ChatInputBar(
                message: $newMessage,
                onSend: sendTextMessage,
                onImagePicker: { showImagePicker = true }
            )
            .padding(.horizontal, 16)
            .padding(.bottom, keyboardHeight + 24) // ↑ lifted further up
            .background(Color(.systemGray6).opacity(0.8))
            .animation(.easeOut(duration: 0.2), value: keyboardHeight)
        }
        .edgesIgnoringSafeArea(.bottom)
        // MARK: Keyboard Observers
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { note in
            if let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = frame.height
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardHeight = 0
        }
        // Image Picker Sheet
        .sheet(isPresented: $showImagePicker, onDismiss: {
            if let img = selectedImage {
                sendPhotoMessage(image: img)
            }
        }) {
            ImagePicker(selectedImage: $selectedImage)
        }
        // Full‑Screen Photo
        .fullScreenCover(item: $fullScreenPhotoURL) { url in
            FullScreenImageView(photoURL: url)
        }
    }

    // MARK: — Firestore

    private func loadMessages() {
        Firestore.firestore()
            .collection("pixcodes")
            .document(pixCode)
            .collection("chats")
            .order(by: "timestamp")
            .addSnapshotListener { snap, err in
                guard err == nil, let docs = snap?.documents else { return }
                messages = docs.compactMap { ChatMessage(document: $0) }
            }
    }

    private func sendTextMessage() {
        let trimmed = newMessage.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let data: [String: Any] = [
            "text": trimmed,
            "timestamp": Timestamp(date: Date()),
            "sender": Auth.auth().currentUser?.uid ?? "unknown",
            "messageType": "text",
            "seen": false
        ]
        Firestore.firestore()
            .collection("pixcodes")
            .document(pixCode)
            .collection("chats")
            .addDocument(data: data)
        newMessage = ""
    }

    private func sendPhotoMessage(image: UIImage) {
        FirebasePhotoUploader.shared.uploadPhoto(
            image: image,
            pixCode: pixCode,
            photoTag: "normal"
        ) { urlStr, _ in
            guard let url = urlStr else { return }
            let data: [String: Any] = [
                "photoURL": url,
                "messageType": "normal",
                "timestamp": Timestamp(date: Date()),
                "sender": Auth.auth().currentUser?.uid ?? "unknown",
                "seen": false
            ]
            Firestore.firestore()
                .collection("pixcodes")
                .document(pixCode)
                .collection("chats")
                .addDocument(data: data)
        }
    }
}
