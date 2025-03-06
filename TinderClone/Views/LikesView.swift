import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct LikesView: View {
    @State private var selected = 0
    
    var body: some View {
        VStack {
            // Tab-like UI
            HStack {
                Spacer()
                Text("0 Likes")
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
    }
}

// MARK: - Previews
struct LikesView_Previews: PreviewProvider {
    static var previews: some View {
        LikesView()
    }
}

// MARK: - LikesSegmentView
struct LikesSegmentView: View {
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            Image(systemName: "suit.heart.fill")
                .font(.system(size: 60))
                .foregroundColor(Color.gray.opacity(0.3))
            Text("Upgrade to Gold to see people who already liked you.")
                .frame(width: 230)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            Spacer()
        }
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
                        // Display each card in a grid cell
                        VStack(spacing: 8) {
                            // Use AsyncImage to load card.imageURL
                            AsyncImage(url: URL(string: card.imageURL)) { phase in
                                switch phase {
                                case .empty:
                                    Color.gray
                                case .success(let image):
                                    image.resizable()
                                         .aspectRatio(contentMode: .fill)
                                case .failure(_):
                                    Color.red
                                @unknown default:
                                    Color.gray
                                }
                            }
                            .frame(width: (geo.size.width - 24)/2, height: 250)
                            .cornerRadius(15)
                            .shadow(radius: 3)
                            
                            Text(card.name)
                                .font(.headline)
                            Text("Year: \(card.year)")
                                .font(.subheadline)
                            Text(card.desc)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
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
