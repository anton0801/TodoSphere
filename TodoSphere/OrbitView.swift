import SwiftUI

struct OrbitView: View {
    @EnvironmentObject private var taskManager: TaskManager
    @State private var showAddTask = false
    @State private var selectedTask: Task?
    
    var body: some View {
        NavigationView {
            ZStack {
                CosmicBackground()
                
                if taskManager.tasks.isEmpty {
                    Text("No tasks yet — Tap + to add your first sphere")
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    ZStack {
                        ForEach(taskManager.tasks) { task in
                            if !task.isCompleted {
                                TaskSphere(task: task, selectedTask: $selectedTask)
                                    .position(orbitPosition(for: task))
                                    .animation(.spring(), value: task.priority)
                            }
                        }
                        CoreSphere()
                    }
                }
                
                VStack {
                    Text("My TodoSphere")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 50)
                    
                    Spacer()
                    
                    Button(action: { showAddTask = true }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundStyle(LinearGradient(gradient: Gradient(colors: [
                                Color(hex: "#FF4FBF"),
                                Color(hex: "#B84FFF")
                            ]), startPoint: .top, endPoint: .bottom))
                            .shadow(radius: 10)
                    }
                    .padding(.bottom, 30)
                }
            }
            .sheet(isPresented: $showAddTask) {
                AddTaskView()
                    .environmentObject(taskManager)
            }
            .sheet(item: $selectedTask) { task in
                TaskDetailView(task: task)
                    .environmentObject(taskManager)
            }
        }
    }
    
    private func orbitPosition(for task: Task) -> CGPoint {
        let radius: CGFloat
        switch task.priority {
        case .high: radius = 100
        case .medium: radius = 150
        case .low: radius = 200
        }
        
        let angle = Double(task.id.hashValue % 360) * .pi / 180
        let x = cos(angle) * Double(radius)
        let y = sin(angle) * Double(radius)
        return CGPoint(x: x + UIScreen.main.bounds.width / 2, y: y + UIScreen.main.bounds.height / 2)
    }
}

struct CoreSphere: View {
    var body: some View {
        Circle()
            .fill(LinearGradient(gradient: Gradient(colors: [
                Color(hex: "#FF4FBF"),
                Color(hex: "#B84FFF")
            ]), startPoint: .top, endPoint: .bottom))
            .frame(width: 50, height: 50)
            .shadow(color: Color(hex: "#7A4FFF").opacity(0.3), radius: 20)
            .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
    }
}

struct TaskSphere: View {
    let task: Task
    @Binding var selectedTask: Task?
    @EnvironmentObject private var taskManager: TaskManager
    @State private var isCompleted = false
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(hex: "#7A4FFF").opacity(0.3), lineWidth: 1)
                .frame(width: orbitRadius * 2)
            
            Circle()
                .fill(sphereGradient)
                .frame(width: sphereSize)
                .shadow(color: Color(hex: "#7A4FFF").opacity(0.3), radius: 10)
                .overlay(
                    Text(task.title)
                        .foregroundColor(.white)
                        .font(.caption)
                        .padding(4)
                        .lineLimit(1)
                )
                .onTapGesture { selectedTask = task }
                .gesture(
                    DragGesture(minimumDistance: 50)
                        .onEnded { _ in
                            if !task.isCompleted {
                                isCompleted = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    taskManager.completeTask(task)
                                }
                            }
                        }
                )
                .scaleEffect(isCompleted ? 1.5 : 1)
                .opacity(isCompleted ? 0 : 1)
                .animation(.easeInOut(duration: 0.5), value: isCompleted)
        }
    }
    
    private var sphereSize: CGFloat {
        switch task.priority {
        case .high: return 40
        case .medium: return 30
        case .low: return 20
        }
    }
    
    private var orbitRadius: CGFloat {
        switch task.priority {
        case .high: return 100
        case .medium: return 150
        case .low: return 200
        }
    }
    
    private var sphereGradient: LinearGradient {
        let colors = task.priority == .low ?
            [Color(hex: "#FF4FBF").opacity(0.6), Color(hex: "#B84FFF").opacity(0.6)] :
            [Color(hex: "#FF4FBF"), Color(hex: "#B84FFF")]
        return LinearGradient(gradient: Gradient(colors: colors), startPoint: .top, endPoint: .bottom)
    }
}

struct CosmicBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [
                Color(hex: "#0D0D1A"),
                Color(hex: "#1A0D2E"),
                Color(hex: "#2B0D4F")
            ]), startPoint: .top, endPoint: .bottom)
            
            ParticleEffect()
        }
        .ignoresSafeArea()
    }
}

struct ParticleEffect: View {
    @State private var particles: [Particle] = []
    
    var body: some View {
        Canvas { context, size in
            for particle in particles {
                context.opacity = particle.opacity
                context.fill(
                    Circle().path(in: CGRect(x: particle.x, y: particle.y, width: 2, height: 2)),
                    with: .color(.white)
                )
            }
        }
        .onAppear {
            for _ in 0..<50 {
                particles.append(Particle(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: CGFloat.random(in: 0...UIScreen.main.bounds.height),
                    opacity: CGFloat.random(in: 0.1...0.5)
                ))
            }
        }
    }
    
    struct Particle {
        let x: CGFloat
        let y: CGFloat
        let opacity: CGFloat
    }
}

struct OrbitView_Previews: PreviewProvider {
    static var previews: some View {
        OrbitView()
            .environmentObject(TaskManager())
    }
}
