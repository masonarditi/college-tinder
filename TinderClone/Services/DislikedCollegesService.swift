// DislikedCollegesService.swift

import FirebaseFirestore
import FirebaseAuth

struct DislikedCollegesService {
    /// Appends the given collegeDocId to the user's `dislikedColleges` array in Firestore.
    static func addCollegeToDisliked(userId: String, collegeDocId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).updateData([
            "dislikedColleges": FieldValue.arrayUnion([collegeDocId])
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
