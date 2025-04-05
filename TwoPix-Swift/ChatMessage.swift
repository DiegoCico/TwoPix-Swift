import FirebaseFirestore

struct ChatMessage: Identifiable {
    var id: String
    var text: String?
    var photoURL: String?
    /// messageType can be "text", "photo", "normal", "spicy", or "FitCheck"
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
