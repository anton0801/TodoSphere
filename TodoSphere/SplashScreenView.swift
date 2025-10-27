import SwiftUI
import AppTrackingTransparency

struct SplashScreenView: View {
    @StateObject private var taskManager = TaskManager()
    @State private var isActive = false
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.0
    @State private var particles: [Particle] = []
    
    var body: some View {
        ZStack {
            if isActive {
                OnboardingView()
                    .environmentObject(taskManager)
                    .transition(.opacity)
            } else {
                ZStack {
                    // Cosmic background
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#0D0D1A"),
                            Color(hex: "#1A0D2E"),
                            Color(hex: "#2B0D4F")
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                    
                    // Particle effect
                    Canvas { context, size in
                        for particle in particles {
                            context.opacity = particle.opacity
                            let path = Circle().path(in: CGRect(
                                x: particle.x - particle.size / 2,
                                y: particle.y - particle.size / 2,
                                width: particle.size,
                                height: particle.size
                            ))
                            context.fill(path, with: .color(particle.color))
                        }
                    }
                    
                    // Central pulsating sphere
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#FF4FBF"),
                                Color(hex: "#B84FFF")
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        .frame(width: 100 * scale, height: 100 * scale)
                        .shadow(color: Color(hex: "#7A4FFF").opacity(0.5), radius: 20)
                        .overlay(
                            Circle()
                                .stroke(Color(hex: "#FFD84F").opacity(0.3), lineWidth: 2)
                                .frame(width: 120 * scale, height: 120 * scale)
                        )
                    
                    // App name with fade effect
                    Text("TodoSphere")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: Color(hex: "#FF4FBF").opacity(0.5), radius: 10)
                        .opacity(opacity)
                        .offset(y: 150)
                }
                .onAppear {
                    // Initialize particles
                    for _ in 0..<20 {
                        particles.append(Particle(
                            x: UIScreen.main.bounds.width / 2,
                            y: UIScreen.main.bounds.height / 2,
                            size: CGFloat.random(in: 5...10),
                            angle: CGFloat.random(in: 0...360),
                            distance: CGFloat.random(in: 50...150),
                            opacity: CGFloat.random(in: 0.2...0.6),
                            color: [Color(hex: "#FF4FBF"), Color(hex: "#B84FFF"), Color(hex: "#FFD84F")].randomElement()!
                        ))
                    }
                    
                    // Pulsating sphere animation
                    withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        scale = 1.2
                    }
                    
                    // Text fade-in and fade-out
                    withAnimation(Animation.easeIn(duration: 2).delay(0.5)) {
                        opacity = 1.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation(Animation.easeOut(duration: 2)) {
                            opacity = 0.0
                        }
                    }
                    
                    // Particle orbit animation
                    withAnimation(Animation.linear(duration: 5).repeatForever(autoreverses: false)) {
                        for i in 0..<particles.count {
                            particles[i].angle += 360
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        withAnimation {
                            isActive = true
                        }
                    }
                }
            }
        }
    }
    
    struct Particle {
        var x: CGFloat
        var y: CGFloat
        let size: CGFloat
        var angle: CGFloat
        let distance: CGFloat
        let opacity: CGFloat
        let color: Color
        
        mutating func updatePosition() {
            let radian = angle * .pi / 180
            x = UIScreen.main.bounds.width / 2 + cos(radian) * distance
            y = UIScreen.main.bounds.height / 2 + sin(radian) * distance
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
