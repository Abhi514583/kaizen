import SwiftUI

struct RainDrop: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var length: CGFloat
    var speed: CGFloat
    var opacity: Double
}

struct RainSplash: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var scale: CGFloat = 0.0
    var opacity: Double = 1.0
}

struct RainAtmosphere: View {
    @State private var drops: [RainDrop] = []
    @State private var splashes: [RainSplash] = []
    
    let dropCount = 40
    let windAngle: CGFloat = 5.0 // Degrees
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                // Update and draw raindrops
                for index in drops.indices {
                    let drop = drops[index]
                    
                    // Draw raindrop
                    var path = Path()
                    path.move(to: CGPoint(x: drop.x, y: drop.y))
                    path.addLine(to: CGPoint(x: drop.x + windAngle, y: drop.y + drop.length))
                    
                    context.stroke(
                        path,
                        with: .color(Color.kaizenWhite.opacity(drop.opacity)),
                        lineWidth: 1
                    )
                }
                
                // Draw splashes (Anime-style sparks)
                for splash in splashes {
                    context.stroke(
                        Path(ellipseIn: CGRect(x: splash.x - (10 * splash.scale), y: splash.y - (2 * splash.scale), width: 20 * splash.scale, height: 4 * splash.scale)),
                        with: .color(Color.kaizenSage.opacity(splash.opacity)),
                        lineWidth: 0.5
                    )
                }
            }
            .onChange(of: timeline.date) { _ in
                updateParticles(in: UIScreen.main.bounds.size)
            }
        }
        .onAppear {
            setupInitialDrops(in: UIScreen.main.bounds.size)
        }
        .allowsHitTesting(false) // Purely decorative
    }
    
    private func setupInitialDrops(in size: CGSize) {
        drops = (0..<dropCount).map { _ in
            createDrop(in: size, randomizeY: true)
        }
    }
    
    private func createDrop(in size: CGSize, randomizeY: Bool = false) -> RainDrop {
        RainDrop(
            x: CGFloat.random(in: -50...size.width + 50),
            y: randomizeY ? CGFloat.random(in: -size.height...0) : -20,
            length: CGFloat.random(in: 10...30),
            speed: CGFloat.random(in: 15...25),
            opacity: Double.random(in: 0.1...0.3)
        )
    }
    
    private func updateParticles(in size: CGSize) {
        // Update drops
        for i in drops.indices {
            drops[i].y += drops[i].speed
            drops[i].x += windAngle * (drops[i].speed / 20.0)
            
            // If drop hits bottom, trigger splash
            if drops[i].y > size.height - 20 {
                if Double.random(in: 0...1) > 0.7 { // Randomly splash
                    splashes.append(RainSplash(x: drops[i].x, y: size.height - 10))
                }
                drops[i] = createDrop(in: size)
            }
        }
        
        // Update splashes
        for i in splashes.indices.reversed() {
            splashes[i].scale += 0.1
            splashes[i].opacity -= 0.1
            
            if splashes[i].opacity <= 0 {
                splashes.remove(at: i)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.kaizenShadow.ignoresSafeArea()
        RainAtmosphere()
    }
}
