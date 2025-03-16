import SwiftUI

struct AnimatedBackgroundView: View {
    // How many circles to display
    let circleCount: Int = 6

    // Colors to choose from
    let colors: [Color] = [.red, .blue, .green, .purple, .orange, .pink, .yellow]
    
    // Tracks if the circles are in their "animated" state
    @State private var animate = false
    
    // Store random properties for each circle so they don’t recalculate every frame
    @State private var circles: [CircleData] = []

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<circleCount, id: \.self) { i in
                    let circle = circles[i]
                    
                    Circle()
                        .fill(circle.color)
                        .frame(width: circle.size, height: circle.size)
                        .position(x: circle.xPosition * geo.size.width,
                                  y: circle.yPosition * geo.size.height)
                        .opacity(0.3)
                        .scaleEffect(animate ? circle.scale : 1.0)
                }
            }
            .onAppear {
                // Initialize the random data once
                if circles.isEmpty {
                    circles = (0..<circleCount).map { _ in
                        CircleData(
                            color: colors.randomElement() ?? .red,
                            xPosition: .random(in: 0.0...1.0),
                            yPosition: .random(in: 0.0...1.0),
                            size: CGFloat.random(in: 100...200),
                            scale: CGFloat.random(in: 0.5...1.5)
                        )
                    }
                }
                
                // Animate the circles continuously
                withAnimation(Animation.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                    animate = true
                }
            }
        }
        .ignoresSafeArea()
    }
}

// Simple struct to store each circle’s properties
struct CircleData {
    let color: Color
    let xPosition: CGFloat
    let yPosition: CGFloat
    let size: CGFloat
    let scale: CGFloat
}
