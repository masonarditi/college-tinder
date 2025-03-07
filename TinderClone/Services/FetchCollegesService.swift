//
//  FetchCollegesService.swift
//  TinderClone
//
//  Created by Mason on 3/6/25.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

private func fetchSeenColleges(userId: String, completion: @escaping ([String]) -> Void) {
    let db = Firestore.firestore()
    db.collection("users").document(userId).getDocument { snapshot, error in
        if let error = error {
            print("Error fetching user doc: \(error.localizedDescription)")
            completion([])
            return
        }
        
        guard let data = snapshot?.data() else {
            completion([])
            return
        }
        
        let likedColleges = data["likedColleges"] as? [String] ?? []
        let dislikedColleges = data["dislikedColleges"] as? [String] ?? []
        
        completion(likedColleges + dislikedColleges)
    }
}

func fetchColleges(completion: @escaping ([Card]) -> Void) {
    guard let userId = Auth.auth().currentUser?.uid else {
        completion([])
        return
    }
    
    let db = Firestore.firestore()
    
    // First fetch seen colleges
    fetchSeenColleges(userId: userId) { seenCollegeIds in
        // Then fetch all colleges and filter
        db.collection("colleges").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching colleges: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let snapshot = snapshot else {
                completion([])
                return
            }
            
            // Filter out seen colleges and decode remaining ones
            let cards: [Card] = snapshot.documents
                .filter { !seenCollegeIds.contains($0.documentID) }
                .compactMap { doc in
                    try? doc.data(as: Card.self)
                }
            
            completion(cards)
        }
    }
}
