// FetchLikedColleges.swift

import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

func fetchLikedColleges(completion: @escaping ([Card]) -> Void) {
    // 1) Check if user is signed in
    guard let userId = Auth.auth().currentUser?.uid else {
        print("No current user; returning empty array.")
        completion([])
        return
    }
    
    let db = Firestore.firestore()
    let userDocRef = db.collection("users").document(userId)
    
    // 2) Fetch the user's document to get the likedColleges array
    userDocRef.getDocument { snapshot, error in
        if let error = error {
            print("Error fetching user doc: \(error.localizedDescription)")
            completion([])
            return
        }
        
        guard
            let data = snapshot?.data(),
            let likedIDs = data["likedColleges"] as? [String],
            !likedIDs.isEmpty
        else {
            print("No likedColleges array found or it's empty.")
            completion([])
            return
        }
        
        // 3) For each doc ID in likedIDs, fetch the doc from 'colleges' collection
        var fetchedCards: [Card] = []
        
        // We'll use a DispatchGroup to wait for all fetches
        let group = DispatchGroup()
        
        for docID in likedIDs {
            group.enter()
            db.collection("colleges").document(docID).getDocument { collegeSnap, err in
                defer { group.leave() }
                
                if let err = err {
                    print("Error fetching college doc \(docID): \(err.localizedDescription)")
                    return
                }
                
                guard let collegeSnap = collegeSnap, collegeSnap.exists else {
                    print("College doc \(docID) not found.")
                    return
                }
                
                // 4) Decode into Card
                do {
                    if let card = try? collegeSnap.data(as: Card.self) {
                        fetchedCards.append(card)
                    } else {
                        print("Decode error for doc: \(docID)")
                    }
                }
            }
        }
        
        // 5) Once all fetches are done, call completion
        group.notify(queue: .main) {
            completion(fetchedCards)
        }
    }
}
