//
//  HomeView.swift
//  TinderClone
//
//  Created by JD on 20/08/20.
//  Modified to animate like/dislike when tapping buttons
//

import SwiftUI

struct HomeView: View {
    @State private var cards: [Card] = Card.cards
    
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
    
    var body: some View {
        VStack {
            ZStack {
                // Show each card in the array
                ForEach(cards.indices, id: \.self) { index in
                    // Identify if this is the "top" card
                    let isTopCard = (index == cards.count - 1)
                    
                    CardView(
                        card: cards[index],
                        
                        // We only pass a forcedSwipe binding to the top card.
                        // For others, pass nil so they won't animate off screen.
                        forcedSwipe: isTopCard ? swipeBinding(for: index) : .constant(nil),
                        
                        // After the card finishes swiping, remove it from the array
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
    }
    
    // MARK: - Handle Button Taps
    private func handleButtonTap(_ id: Int) {
        guard !cards.isEmpty else { return }
        
        switch id {
        case 0:
            // Reload => reset
            cards = Card.cards
            
        case 1:
            // Dislike => forcibly swipe left
            if let topIndex = cards.indices.last {
                // This sets forcedSwipe to -500 for the top card
                setSwipeValue(for: topIndex, to: -500)
            }
            
        case 3:
            // Like => forcibly swipe right
            if let topIndex = cards.indices.last {
                setSwipeValue(for: topIndex, to: 500)
            }
            
        default:
            break
        }
    }
    
    // MARK: - Force a card to swipe
    // We'll store the forced swipe value in a dictionary so each card can read it.
    @State private var forcedSwipeValues: [Int: CGFloat?] = [:]
    
    private func setSwipeValue(for index: Int, to value: CGFloat) {
        forcedSwipeValues[index] = value
    }
    
    private func swipeBinding(for index: Int) -> Binding<CGFloat?> {
        // Return a binding to forcedSwipeValues[index], defaulting to nil if not set
        return Binding<CGFloat?>(
            get: { forcedSwipeValues[index] ?? nil },
            set: { newValue in forcedSwipeValues[index] = newValue }
        )
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

// MARK: - ActionButton
struct ActionButton {
    let id: Int
    let image: String
    let color: Color
    let height: CGFloat
}
