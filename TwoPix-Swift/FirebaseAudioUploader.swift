import Foundation
import FirebaseStorage
import FirebaseFirestore

class FirebaseAudioUploader {
    static let shared = FirebaseAudioUploader()
    
    private let storage = Storage.storage()
    private let firestore = Firestore.firestore()
    
    func uploadAudio(audioURL: URL, pixCode: String, audioTag: String, completion: @escaping (String?, Error?) -> Void) {
        // Create a unique audio ID.
        let audioID = UUID().uuidString
        
        // Create a reference in Firebase Storage.
        let storageRef = storage.reference().child("audios/\(audioID).m4a")
        
        // Convert the audio file at the provided URL to Data.
        guard let audioData = try? Data(contentsOf: audioURL) else {
            completion(nil, NSError(domain: "AudioConversion", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to convert audio file to data."]))
            return
        }
        
        // Set up metadata for the audio file.
        let metadata = StorageMetadata()
        metadata.contentType = "audio/m4a"
        
        // Upload the audio data.
        storageRef.putData(audioData, metadata: metadata) { (_, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            // Retrieve the download URL.
            storageRef.downloadURL { (url, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                guard let downloadURL = url else {
                    completion(nil, NSError(domain: "DownloadURL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Download URL not available."]))
                    return
                }
                
                // Print out the audio URL for debugging.
                print("Audio URL: \(downloadURL.absoluteString)")
                
                // Prepare the audio metadata using "audioURL" as key.
                let audioData: [String: Any] = [
                    "pixCode": pixCode,
                    "audioTag": audioTag,
                    "audioURL": downloadURL.absoluteString,
                    "timestamp": Date().timeIntervalSince1970,
                    "date": DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
                ]
                
                // Save the metadata in Firestore under the top-level "audios" collection.
                self.firestore.collection("audios").document(audioID).setData(audioData) { error in
                    if let error = error {
                        completion(nil, error)
                    } else {
                        completion(downloadURL.absoluteString, nil)
                    }
                }
            }
        }
    }
}
