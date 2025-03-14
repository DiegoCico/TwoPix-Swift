import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Text("Welcome to TwoPix! 🎉")
                .font(.largeTitle)
                .foregroundColor(.white)
        }
    }
}
