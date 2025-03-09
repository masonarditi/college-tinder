import FirebaseFirestoreSwift

struct Card: Identifiable, Codable {
    @DocumentID var id: String?  // Firestore doc ID

    let name: String
    let year: Int
    let desc: String
    let imageURL: String
    
    // new info
    
    let athletics: Int
    let diningRating: Int
    let greekLife: Int
    let institutionType: String
    let location: String
    let overall: Int
    let ranking: Int
    let studentPopulation: Int
    let topMajors: [String]
    let website: String
}
