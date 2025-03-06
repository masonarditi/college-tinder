import FirebaseFirestoreSwift

struct Card: Identifiable, Codable {
    @DocumentID var id: String?  // Firestore doc ID

    let name: String
    let year: Int
    let desc: String
    let imageURL: String
}
