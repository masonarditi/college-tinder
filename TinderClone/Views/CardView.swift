//CardView

import SwiftUI

struct CardView: View {
    var card: Card
    
    // The usual drag-based translation
    @State private var translation: CGSize = .zero
    
    // (1) A binding so the parent can force a swipe
    @Binding var forcedSwipe: CGFloat?
    
    // (2) Called after we finish swiping off screen
    var onSwiped: () -> Void
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Load image from card.imageURL
                AsyncImage(url: URL(string: card.imageURL)) { phase in
                    switch phase {
                    case .empty:
                        // Placeholder while loading
                        Color.gray
                            .frame(width: geo.size.width - 32)
                            .cornerRadius(15)
                            .modifier(ThemeShadow())
                        
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.size.width - 32)
                            .clipped()
                            .cornerRadius(15)
                            .modifier(ThemeShadow())
                        
                    case .failure(_):
                        // If there's an error, show a fallback
                        Color.red
                            .frame(width: geo.size.width - 32)
                            .cornerRadius(15)
                            .modifier(ThemeShadow())
                        
                    @unknown default:
                        // Future cases
                        Color.gray
                            .frame(width: geo.size.width - 32)
                            .cornerRadius(15)
                            .modifier(ThemeShadow())
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
                    }.onEnded { value in
                        withAnimation(.easeInOut) {
                            if translation.width > 150 {
                                // user dragged right
                                translation.width = 500
                                removeAfterDelay(0.4)
                            } else if translation.width < -150 {
                                // user dragged left
                                translation.width = -500
                                removeAfterDelay(0.4)
                            } else {
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
