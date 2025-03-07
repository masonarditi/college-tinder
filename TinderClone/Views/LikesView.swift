//LikesView

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

struct LikesView: View {
    @State private var selected = 0
    @State private var likedCount = 0  // <-- We'll store the dynamic count here
    
    var body: some View {
        VStack {
            // Tab-like UI
            HStack {
                Spacer()
                Text("\(likedCount) Likes")  // <-- Display the count
                    .font(.title2)
                    .bold()
                    .foregroundColor(selected == 0 ? .gold : .gray)
                    .onTapGesture {
                        selected = 0
                    }
                Spacer()
                Text("10 Top Picks")
                    .font(.title2)
                    .bold()
                    .foregroundColor(selected == 1 ? .gold : .gray)
                    .onTapGesture {
                        selected = 1
                    }
                Spacer()
            }
            .padding(.vertical)
            
            Divider()
            Spacer()
            
            if selected == 0 {
                LikesSegmentView()
            } else {
                TopPicksSegmentView()
            }
        }
        // 1) When this view appears, fetch the count from Firestore
        .onAppear {
            fetchLikedCount { count in
                likedCount = count
            }
        }
    }
}

func fetchLikedCount(completion: @escaping (Int) -> Void) {
    // 1) Check if a user is signed in
    guard let userId = Auth.auth().currentUser?.uid else {
        completion(0)
        return
    }
    let db = Firestore.firestore()
    
    // 2) Fetch the user doc
    db.collection("users").document(userId).getDocument { snapshot, error in
        if let error = error {
            print("Error fetching user doc: \(error.localizedDescription)")
            completion(0)
            return
        }
        
        // 3) Get the array from the doc
        guard let data = snapshot?.data(),
              let likedIDs = data["likedColleges"] as? [String]
        else {
            // If it's missing or empty, return 0
            completion(0)
            return
        }
        
        // 4) Return the count
        completion(likedIDs.count)
    }
}

// MARK: - LikesSegmentView
struct LikesSegmentView: View {
    @State private var likedCards: [Card] = []
    
    var body: some View {
        ScrollView {
            if likedCards.isEmpty {
                // If no liked cards, show a placeholder
                VStack(spacing: 40) {
                    Spacer()
                    Image(systemName: "suit.heart.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color.gray.opacity(0.3))
                    Text("No liked colleges yet.")
                        .frame(width: 230)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                    Spacer()
                }
            } else {
                // Show each liked card in a vertical list
                LazyVStack(spacing: 20) {
                    ForEach(likedCards, id: \.id) { card in
                        LikedCardRow(card: card)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            // Fetch the liked doc IDs -> fetch each doc -> decode into Card
            fetchLikedColleges { fetched in
                self.likedCards = fetched
            }
        }
    }
}

// Add LikedCardRow
struct LikedCardRow: View {
    let card: Card
    @State private var loadedImage: UIImage? = nil
    
    var body: some View {
        HStack {
            if let image = loadedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 80)
                    .cornerRadius(8)
                    .clipped()
            } else {
                Color.gray
                    .frame(width: 100, height: 80)
                    .cornerRadius(8)
                    .onAppear {
                        loadImage()
                    }
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(card.name)
                    .font(.headline)
                Text("Year: \(card.year)")
                    .font(.subheadline)
                Text(card.desc)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
    
    private func loadImage() {
        guard let url = URL(string: card.imageURL) else { return }
        
        // Check NSCache first
        if let cachedImage = ImageCache.shared.get(forKey: url.absoluteString) {
            self.loadedImage = cachedImage
            return
        }
        
        // If not in cache, download it
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async {
                if let image = UIImage(data: data) {
                    self.loadedImage = image
                    ImageCache.shared.set(image, forKey: url.absoluteString)
                }
            }
        }.resume()
    }
}

// MARK: - TopPicksSegmentView
struct TopPicksSegmentView: View {
    @State private var cards: [Card] = []
    private let layout = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                Text("Upgrade to Tinder Gold for more Top Picks!")
                    .font(.title3)
                    .bold()
                    .multilineTextAlignment(.center)
                    .frame(width: 250)
                    .foregroundColor(.gray)
                    .padding(8)
                
                LazyVGrid(columns: layout, spacing: 8) {
                    ForEach(cards, id: \.id) { card in
                        // ...
                    }
                }
                .padding(8)
            }
        }
        .onAppear {
            fetchColleges { fetched in
                self.cards = fetched
            }
        }
    }
}
