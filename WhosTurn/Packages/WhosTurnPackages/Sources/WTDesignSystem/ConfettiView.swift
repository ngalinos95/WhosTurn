import SwiftUI

public struct ConfettiView: View {
    let isActive: Bool
    @State private var startTime: Date?
    @State private var particles: [Particle] = []

    private struct Particle {
        let x: CGFloat
        let wobble: CGFloat
        let speed: CGFloat
        let color: Color
        let size: CGFloat
        let rotation: Double
        let rotationSpeed: Double
    }

    private static let colors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple, .pink, .mint
    ]

    public init(isActive: Bool) {
        self.isActive = isActive
    }

    public var body: some View {
        Group {
            if startTime != nil {
                TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
                    Canvas { context, size in
                        guard let startTime else { return }
                        let elapsed = timeline.date.timeIntervalSince(startTime)
                        guard elapsed < 4.0 else { return }

                        for particle in particles {
                            let y = particle.speed * CGFloat(elapsed) * size.height - 20
                            let x = particle.x * size.width
                                + sin(CGFloat(elapsed) * 3 + particle.wobble) * 30
                            let opacity = max(0, 1 - elapsed / 3.5)

                            guard opacity > 0, y < size.height + 20 else { continue }

                            var ctx = context
                            ctx.opacity = opacity
                            ctx.translateBy(x: x, y: y)
                            ctx.rotate(
                                by: .degrees(particle.rotation + particle.rotationSpeed * elapsed))

                            let rect = CGRect(
                                x: -particle.size / 2, y: -particle.size / 2,
                                width: particle.size, height: particle.size * 0.6
                            )
                            ctx.fill(
                                Path(roundedRect: rect, cornerRadius: 2),
                                with: .color(particle.color))
                        }
                    }
                }
            }
        }
        .allowsHitTesting(false)
        .onChange(of: isActive) { _, active in
            if active {
                spawnParticles()
                startTime = .now
            } else {
                startTime = nil
                particles = []
            }
        }
    }

    private func spawnParticles() {
        particles = (0..<60).map { _ in
            Particle(
                x: CGFloat.random(in: 0...1),
                wobble: CGFloat.random(in: -2...2),
                speed: CGFloat.random(in: 0.15...0.45),
                color: Self.colors.randomElement()!,
                size: CGFloat.random(in: 6...12),
                rotation: Double.random(in: 0...360),
                rotationSpeed: Double.random(in: 100...400)
            )
        }
    }
}
