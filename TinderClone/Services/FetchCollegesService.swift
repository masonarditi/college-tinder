//
//  FetchCollegesService.swift
//  TinderClone
//
//  Created by Mason on 3/6/25.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

func fetchColleges(completion: @escaping ([Card]) -> Void) {
    let db = Firestore.firestore()
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
        
        // Decode each document into a Card
        let cards: [Card] = snapshot.documents.compactMap { doc in
            try? doc.data(as: Card.self)
        }
        completion(cards)
    }
}
