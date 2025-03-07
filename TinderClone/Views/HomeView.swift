

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

// If you have a separate file for fetchColleges, remove this function here.
func fetchColleges(completion: @escaping ([Card]) -> Void) {
    let db = Firestore.firestore()
    db.collection("colleges").getDocuments { snapshot, error in
        if let error = error {
            print("Error fetching colleges: \(error.localizedDescription)")
            completion([])
            return
        }
        guard let docs = snapshot?.documents else {
            completion([])
            return
        }
        let fetchedCards: [Card] = docs.compactMap { doc in
            try? doc.data(as: Card.self)
        }
        completion(fetchedCards)
    }
}

struct HomeView: View {
    @State private var cards: [Card] = []
    
    // Buttons: reload, dislike, like
    private let buttons: [ActionButton] = [
        ActionButton(id: 0,
                     image: "arrow.counterclockwise",
                     color: Color(UIColor(red: 247/255, green: 181/255, blue: 50/255, alpha: 1)),
                     height: 47),
        ActionButton(id: 1,
                     image: "xmark",
                     color: Color(UIColor(red: 250/255, green: 73/255, blue: 95/255, alpha: 1)),
                     height: 55),
        ActionButton(id: 3,
                     image: "suit.heart.fill",
                     color: Color(UIColor(red: 60/255, green: 229/255, blue: 184/255, alpha: 1)),
                     height: 55)
    ]
    
    // We store forced swipe offsets in a dictionary keyed by array indices
    @State private var forcedSwipeValues: [Int: CGFloat?] = [:]
    
    var body: some View {
        VStack {
            ZStack {
                // Show each card in the array
                ForEach(cards.indices, id: \.self) { index in
                    let isTopCard = (index == cards.count - 1)
                    
                    CardView(
                        card: cards[index],
                        forcedSwipe: isTopCard ? swipeBinding(for: index) : .constant(nil),
                        onSwiped: {
                            guard index >= 0 && index < cards.count else { return }
                            cards.remove(at: index)
                        }
                    )
                    .shadow(radius: 5)
                }
            }
            Spacer()
            
            // The bottom button bar
            HStack {
                Spacer()
                ForEach(buttons, id: \.id) { button in
                    Button(action: {
                        handleButtonTap(button.id)
                    }) {
                        Image(systemName: button.image)
                            .font(.system(size: 23, weight: .heavy))
                            .foregroundColor(button.color)
                            .frame(width: button.height, height: button.height)
                            // If you have these modifiers in your project, uncomment:
                            .modifier(ButtonBG())
                            .cornerRadius(button.height / 2)
                            .modifier(ThemeShadow())
                    }
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 5)
        }
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .onAppear {
            reloadCards()
        }
    }
    
    private func handleButtonTap(_ id: Int) {
        guard !cards.isEmpty || id == 0 else { return }
        
        switch id {
        case 0:
            // Reload => fetch from Firestore again
            reloadCards()
            
        case 1: // Dislike => forcibly swipe left
            if let topIndex = cards.indices.last {
                // 1) Firestore call to dislikedColleges
                if let userId = Auth.auth().currentUser?.uid,
                   let docId = cards[topIndex].id {
                    DislikedCollegesService.addCollegeToDisliked(userId: userId, collegeId: docId) { result in
                        switch result {
                        case .success():
                            print("Disliked doc: \(docId)")
                        case .failure(let error):
                            print("Error disliking doc: \(error.localizedDescription)")
                        }
                    }
                }
                
                // 2) Forcibly swipe left
                setSwipeValue(for: topIndex, to: -500)
            }
            
        case 3: // Like => forcibly swipe right
            if let topIndex = cards.indices.last {
                // 1) Firestore call to likedColleges
                if let userId = Auth.auth().currentUser?.uid,
                   let docId = cards[topIndex].id {
                    LikedCollegesService.addCollegeToLiked(userId: userId, collegeId: docId) { result in
                        switch result {
                        case .success():
                            print("Liked doc: \(docId)")
                        case .failure(let error):
                            print("Error liking doc: \(error.localizedDescription)")
                        }
                    }
                }
                
                // 2) Forcibly swipe right
                setSwipeValue(for: topIndex, to: 500)
            }
            
        default:
            break
        }
    }

    // MARK: - Force a card to swipe
    private func setSwipeValue(for index: Int, to value: CGFloat) {
        forcedSwipeValues[index] = value
    }
    
    private func swipeBinding(for index: Int) -> Binding<CGFloat?> {
        Binding<CGFloat?>(
            get: { forcedSwipeValues[index] ?? nil },
            set: { newValue in forcedSwipeValues[index] = newValue }
        )
    }
    
    // MARK: - Reload / Fetch from Firestore
    private func reloadCards() {
        fetchColleges { fetched in
            self.cards = fetched
        }
    }
}

// A minimal ActionButton struct:
struct ActionButton {
    let id: Int
    let image: String
    let color: Color
    let height: CGFloat
}
