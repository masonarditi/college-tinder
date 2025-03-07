import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth


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
                if cards.isEmpty {
                    VStack {
                        Spacer()
                        
                        VStack(spacing: 20) {
                            Image(systemName: "heart.slash.fill")
                                .font(.system(size: 70))
                                .foregroundColor(.gray)
                            
                            Text("No More Colleges")
                                .font(.title2)
                                .foregroundColor(.gray)
                            
                            Text("Check back later for more options")
                                .font(.callout)
                                .foregroundColor(.gray.opacity(0.8))
                        }
                        
                        Spacer()
                    }
                } else {
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
            .opacity(cards.isEmpty ? 0.5 : 1)
            .disabled(cards.isEmpty)
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
            
        case 1:
            // Dislike => forcibly swipe left
            if let topIndex = cards.indices.last {
                // 1) Attempt to get user + doc ID
                if let userId = Auth.auth().currentUser?.uid,
                   let docId = cards[topIndex].id {
                    
                    // 2) Call DislikedCollegesService
                    DislikedCollegesService.addCollegeToDisliked(userId: userId, collegeDocId: docId) { result in
                        switch result {
                        case .success():
                            print("Disliked doc ID: \(docId)")
                        case .failure(let error):
                            print("Error disliking doc: \(error.localizedDescription)")
                        }
                    }
                }
                
                // 3) Forcibly swipe left
                setSwipeValue(for: topIndex, to: -500)
            }
            
        case 3:
            // Like => forcibly swipe right
            if let topIndex = cards.indices.last {
                // 1) Attempt to get user + doc ID
                if let userId = Auth.auth().currentUser?.uid,
                   let docId = cards[topIndex].id {
                    
                    // 2) Call LikedCollegesService
                    LikedCollegesService.addCollegeToLiked(userId: userId, collegeDocId: docId) { result in
                        switch result {
                        case .success():
                            print("Liked doc ID: \(docId)")
                        case .failure(let error):
                            print("Error liking doc: \(error.localizedDescription)")
                        }
                    }
                }
                
                // 3) Forcibly swipe right
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
