// DislikedCollegesService.swift

import FirebaseFirestore
import FirebaseAuth

struct DislikedCollegesService {
    /// Appends the given collegeId to the user's dislikedColleges array in Firestore.
    static func addCollegeToDisliked(userId: String, collegeId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).updateData([
            "dislikedColleges": FieldValue.arrayUnion([collegeId])
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
