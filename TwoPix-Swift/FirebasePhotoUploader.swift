import Foundation
import FirebaseStorage
import FirebaseFirestore
import UIKit

class FirebasePhotoUploader {
    static let shared = FirebasePhotoUploader()
    
    private let storage = Storage.storage()
    private let firestore = Firestore.firestore()
    
    func uploadPhoto(image: UIImage, pixCode: String, photoTag: String, completion: @escaping (String?, Error?) -> Void) {
        // Convert the image to JPEG data.
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil, NSError(domain: "ImageConversion", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to convert image to JPEG."]))
            return
        }
        
        // Create a unique photo ID.
        let photoID = UUID().uuidString
        
        // Create a reference in Firebase Storage.
        let storageRef = storage.reference().child("images/\(photoID).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // Upload the image data.
        storageRef.putData(imageData, metadata: metadata) { (_, error) in
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
                
                // Print out the photo URL for debugging.
                print("Photo URL: \(downloadURL.absoluteString)")
                
                // Prepare the photo metadata using "photoURL" as key to match ChatMessage.
                let photoData: [String: Any] = [
                    "pixCode": pixCode,
                    "photoTag": photoTag,
                    "photoURL": downloadURL.absoluteString,
                    "timestamp": Date().timeIntervalSince1970,
                    "date": DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
                ]
                
                // Save the metadata in Firestore under the top-level "photos" collection.
                self.firestore.collection("photos").document(photoID).setData(photoData) { error in
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
