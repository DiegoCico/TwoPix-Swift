import Foundation
import FirebaseFirestore

struct ChatMessage: Identifiable {
    let id: String
    let text: String?
    let photoURL: String?
    let messageType: String   // "text", "normal", "spicy", "FitCheck", etc.
    let timestamp: Date
    let sender: String
    let seen: Bool

    init?(document: DocumentSnapshot) {
        guard
            let data = document.data(),
            let ts = data["timestamp"] as? Timestamp,
            let sender = data["sender"] as? String,
            let messageType = data["messageType"] as? String
        else { return nil }

        self.id          = document.documentID
        self.text        = data["text"] as? String
        self.photoURL    = data["photoURL"] as? String
        self.timestamp   = ts.dateValue()
        self.sender      = sender
        self.messageType = messageType
        self.seen        = data["seen"] as? Bool ?? false
    }
}
