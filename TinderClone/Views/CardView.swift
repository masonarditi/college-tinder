import SwiftUI
import FirebaseAuth
import FirebaseFirestoreSwift

struct CardView: View {
    var card: Card
    
    // The usual drag-based translation
    @State private var translation: CGSize = .zero
    
    // (1) A binding so the parent can force a swipe
    @Binding var forcedSwipe: CGFloat?
    
    // (2) Called after we finish swiping off screen
    var onSwiped: () -> Void
    
    // Image caching
    @State private var loadedImage: UIImage? = nil
    
    // Track which "page" we are on (1, 2, or 3)
    @State private var currentPage = 1
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // ---------------------------------------
                // Background image, possibly blurred
                // ---------------------------------------
                if let image = loadedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width - 32)
                        .clipped()
                        .cornerRadius(15)
                        .modifier(ThemeShadow())
                        // Blur if we're on page 2 or 3
                        .blur(radius: currentPage == 1 ? 0 : 10)
                } else {
                    // Loading placeholder
                    Color.gray
                        .frame(width: geo.size.width - 32)
                        .cornerRadius(15)
                        .modifier(ThemeShadow())
                        .onAppear {
                            loadImage()
                        }
                }
                
                // ---------------------------------------
                // Overlays depending on currentPage
                // ---------------------------------------
                if currentPage == 1 {
                    pageOneOverlay()
                } else if currentPage == 2 {
                    pageTwoOverlay()
                } else {
                    pageThreeOverlay()
                }
            }
            .offset(x: translation.width, y: 0)
            .rotationEffect(.degrees(Double(translation.width / geo.size.width) * 25), anchor: .bottom)
            
            // ---------------------------------------
            // Gesture for swiping (like/dislike)
            // ---------------------------------------
            .gesture(
                DragGesture()
                    .onChanged { value in
                        self.translation = value.translation
                    }
                    .onEnded { _ in
                        withAnimation(.easeInOut) {
                            if translation.width > 150 {
                                // user dragged right => "like"
                                if let user = Auth.auth().currentUser,
                                   let docId = card.id {
                                    LikedCollegesService.addCollegeToLiked(userId: user.uid, collegeDocId: docId) { result in
                                        switch result {
                                        case .success():
                                            print("Doc ID liked: \(docId)")
                                        case .failure(let error):
                                            print("Error liking doc: \(error.localizedDescription)")
                                        }
                                    }
                                }
                                translation.width = 500
                                removeAfterDelay(0.4)
                            } else if translation.width < -150 {
                                // user dragged left => "dislike"
                                if let user = Auth.auth().currentUser,
                                   let docId = card.id {
                                    DislikedCollegesService.addCollegeToDisliked(userId: user.uid, collegeDocId: docId) { result in
                                        switch result {
                                        case .success():
                                            print("Doc ID disliked: \(docId)")
                                        case .failure(let error):
                                            print("Error disliking doc: \(error.localizedDescription)")
                                        }
                                    }
                                }
                                translation.width = -500
                                removeAfterDelay(0.4)
                            } else {
                                // Not enough drag => reset
                                translation = .zero
                            }
                        }
                    }
            )
            
            // ---------------------------------------
            // Tap gesture to cycle pages 1 -> 2 -> 3
            // ---------------------------------------
            .onTapGesture {
                cyclePage()
            }
            .cornerRadius(15)
            .padding()
            // (3) Listen for forced swipes from the parent
            .onChange(of: forcedSwipe) { newValue in
                guard let val = newValue else { return }
                withAnimation(.easeInOut(duration: 0.4)) {
                    translation.width = val
                }
                removeAfterDelay(0.4)
            }
        }
    }
    
    // MARK: - Page Overlays
    
    private func pageOneOverlay() -> some View {
        // Minimal text overlay on unblurred image
        VStack {
            Spacer()
            VStack(spacing: 5) {
                Text("\(card.name), \(card.year)")
                    .font(.title2)
                    .fontWeight(.heavy)
                Text(card.desc)
                    .font(.subheadline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
        }
        .padding(.bottom, 20)
    }
    
    private func pageTwoOverlay() -> some View {
        // Blurred background + partial fields
        VStack(alignment: .leading, spacing: 16) {
            Spacer()
            VStack(alignment: .leading, spacing: 12) {
                // Star fields with emojis
                HStack {
                    Text("🏈 Athletics:")
                        .font(.title3).bold()
                    starRating(card.athletics)
                }
                
                HStack {
                    Text("🍽 Dining:")
                        .font(.title3).bold()
                    starRating(card.diningRating)
                }
                
                HStack {
                    Text("🏛 Greek Life:")
                        .font(.title3).bold()
                    starRating(card.greekLife)
                }
                
                // Plain text
                Text("🏫 Type: \(card.institutionType)")
                    .font(.title3).bold()
                Text("📍 Location: \(card.location)")
                    .font(.title3).bold()
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 20)
    }
    
    private func pageThreeOverlay() -> some View {
        // Blurred background + rest of fields
        VStack(alignment: .leading, spacing: 16) {
            Spacer()
            VStack(alignment: .leading, spacing: 12) {
                // Another star field
                HStack {
                    Text("🌟 Overall:")
                        .font(.title3).bold()
                    starRating(card.overall)
                }
                
                // Plain text fields with emojis
                Text("🏅 Ranking: #\(card.ranking)")
                    .font(.title3).bold()
                Text("🧑‍🎓 Student Population: \(card.studentPopulation)")
                    .font(.title3).bold()
                
                // topMajors array
                Text("📚 Top Majors: \(card.topMajors.joined(separator: ", "))")
                    .font(.title3).bold()
                
                Text("🔗 Website: \(card.website)")
                    .font(.title3).bold()
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Tap to cycle pages
    private func cyclePage() {
        if currentPage < 3 {
            currentPage += 1
        } else {
            currentPage = 1
        }
    }
    
    // MARK: - Image Loading
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
    
    // MARK: - Remove after delay
    private func removeAfterDelay(_ delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            onSwiped()
        }
    }
}

// MARK: - Star Rating helper
private func starRating(_ rating: Int) -> some View {
    HStack(spacing: 2) {
        ForEach(0..<5, id: \.self) { index in
            Image(systemName: index < rating ? "star.fill" : "star")
                .font(.title3) // bigger star icons
                .foregroundColor(.yellow)
        }
    }
}

// MARK: - ImageCache for caching
class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {
        // Set cache limits if desired
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    func get(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func set(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}
