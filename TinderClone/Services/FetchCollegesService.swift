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
        print("No current user; returning empty array.")
        completion([])
        return
    }
    
    let db = Firestore.firestore()
    
    // First fetch seen colleges
    fetchSeenColleges(userId: userId) { seenCollegeIds in
        print("\n=== DEBUG: Seen College IDs ===\n\(seenCollegeIds)\n")
        
        // Then fetch all colleges and filter
        db.collection("colleges").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching colleges: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let snapshot = snapshot else {
                print("No snapshot available")
                completion([])
                return
            }
            
            print("\n=== DEBUG: All Colleges in Database ===")
            for doc in snapshot.documents {
                let data = doc.data()
                print("College ID: \(doc.documentID)")
                print("Data: \(data)\n")
            }
            print("===================================\n")
            
            // Filter out seen colleges and decode remaining ones
            let cards: [Card] = snapshot.documents
                .filter { !seenCollegeIds.contains($0.documentID) }
                .compactMap { doc in
                    do {
                        let card = try doc.data(as: Card.self)
                        print("Successfully decoded college: \(doc.documentID)")
                        return card
                    } catch {
                        print("Failed to decode college \(doc.documentID): \(error)")
                        return nil
                    }
                }
            
            print("\n=== DEBUG: Returning \(cards.count) cards ===\n")
            completion(cards)
        }
    }
}
