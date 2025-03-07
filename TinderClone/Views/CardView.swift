//CardView

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
    
    // Add image cache
    @State private var loadedImage: UIImage? = nil
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Replace AsyncImage with cached image loading
                if let image = loadedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width - 32)
                        .clipped()
                        .cornerRadius(15)
                        .modifier(ThemeShadow())
                } else {
                    // Show loading placeholder
                    Color.gray
                        .frame(width: geo.size.width - 32)
                        .cornerRadius(15)
                        .modifier(ThemeShadow())
                        .onAppear {
                            loadImage()
                        }
                }
                
                // LIKE / NOPE + card info
                VStack {
                    HStack {
                        if translation.width > 0 {
                            Text("LIKE")
                                .tracking(3)
                                .font(.title)
                                .padding(.horizontal)
                                .foregroundColor(.green)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.green, lineWidth: 3)
                                )
                                .rotationEffect(.degrees(-20))
                            Spacer()
                        } else if translation.width < 0 {
                            Spacer()
                            Text("NOPE")
                                .tracking(3)
                                .font(.title)
                                .padding(.horizontal)
                                .foregroundColor(.red)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.red, lineWidth: 3)
                                )
                                .rotationEffect(.degrees(20))
                        }
                    }
                    .padding(.horizontal, 25)
                    
                    Spacer()
                    CardInfoView(card: card)
                }
                .padding(.top, 40)
            }
            // Combine drag offset + forced swipe offset
            .offset(x: translation.width, y: 0)
            .rotationEffect(.degrees(Double(translation.width / geo.size.width) * 25), anchor: .bottom)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        self.translation = value.translation
                    }.onEnded { _ in
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
    
    // Add image loading function
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
    
    // (4) Remove the card from the stack after a short delay
    private func removeAfterDelay(_ delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            onSwiped()
        }
    }
}

struct CardInfoView: View {
    let card: Card
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .bottom) {
                VStack(spacing: 5) {
                    Text("\(card.name), \(card.year)")  // Replacing age with year
                        .font(.system(size: 30))
                        .fontWeight(.heavy)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Recently active")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(card.desc)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 30))
                    .padding(8)
            }
        }
        .foregroundColor(.white)
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(UIColor.black).opacity(0.9),
                    .clear
                ]),
                startPoint: .bottom,
                endPoint: .top
            )
        )
        .cornerRadius(15)
        .clipped()
    }
}

class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {
        // Set cache limits
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
