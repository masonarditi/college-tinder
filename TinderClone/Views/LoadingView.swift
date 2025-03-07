//LoadingView

import SwiftUI

struct LoadingView: View {
    @State private var scale: CGFloat = 0.8
    
    var body: some View {
        ZStack {
            // Tinder flame icon
            Image(systemName: "flame.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
                .foregroundColor(.red)
                .scaleEffect(scale)
        }
        .onAppear {
            // Subtle pulse animation
            withAnimation(
                Animation.easeInOut(duration: 0.8)
                    .repeatForever(autoreverses: true)
            ) {
                scale = 1.0
            }
        }
    }
}

// Preview remains the same
struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
            .preferredColorScheme(.dark)
    }
}
