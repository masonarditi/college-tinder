// LikedCollegesService.swift

import FirebaseFirestore
import FirebaseAuth

struct LikedCollegesService {
    /// Appends the given collegeDocId to the user's `likedColleges` array in Firestore.
    static func addCollegeToLiked(userId: String, collegeDocId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).updateData([
            "likedColleges": FieldValue.arrayUnion([collegeDocId])
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
