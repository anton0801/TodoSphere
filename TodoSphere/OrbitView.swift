import SwiftUI
import AudioToolbox

struct OrbitView: View {
    @EnvironmentObject private var taskManager: TaskManager
    @State private var showAddTask = false
    @State private var selectedTask: Task?
    
    var body: some View {
        ZStack {
            StarfieldBackground()
            
            if taskManager.tasks.isEmpty {
                Text("No tasks yet — Tap + to add your first sphere")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color(hex: "#2B0D4F").opacity(0.8))
                    .cornerRadius(15)
                    .shadow(color: Color(hex: "#FF4FBF").opacity(0.4), radius: 10)
            } else {
                ZStack {
                    ForEach(taskManager.tasks) { task in
                        if !task.isCompleted {
                            TaskSphere(task: task, selectedTask: $selectedTask)
                                .position(orbitPosition(for: task))
                                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: task.priority)
                        }
                    }
                    CoreSphere()
                }
            }
            
            VStack {
                Text("My TodoSphere")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: Color(hex: "#FF4FBF").opacity(0.6), radius: 10)
                    .padding(.top, 50)
                
                Spacer()
                
                Button(action: { showAddTask = true }) {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#FF4FBF"),
                                Color(hex: "#B84FFF")
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        .frame(width: 70, height: 70)
                        .overlay(Image(systemName: "plus").foregroundColor(.white))
                        .shadow(color: Color(hex: "#7A4FFF").opacity(0.6), radius: 15)
                }
                .padding(.bottom, 30)
                
                Spacer().frame(height: 50)
            }
        }
        .sheet(isPresented: $showAddTask) {
            AddTaskView()
                .environmentObject(taskManager)
                .transition(.opacity)
        }
        .sheet(item: $selectedTask) { task in
            TaskDetailView(task: task)
                .environmentObject(taskManager)
                .transition(.opacity)
        }
        .ignoresSafeArea()
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
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#FF4FBF"),
                        Color(hex: "#B84FFF"),
                        Color(hex: "#FF4FBF").opacity(0.5)
                    ]),
                    center: .center,
                    startRadius: 10,
                    endRadius: 25
                ))
                .frame(width: 60, height: 60)
                .shadow(color: Color(hex: "#7A4FFF").opacity(0.6), radius: 15)
                .rotationEffect(.degrees(rotation))
                .animation(Animation.linear(duration: 10).repeatForever(autoreverses: false), value: rotation)
                .onAppear {
                    rotation = 360
                }
            
            Circle()
                .stroke(Color(hex: "#FFD84F").opacity(0.4), lineWidth: 2)
                .frame(width: 80, height: 80)
        }
        .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
    }
}

struct TaskSphere: View {
    let task: Task
    @Binding var selectedTask: Task?
    @EnvironmentObject private var taskManager: TaskManager
    @State private var isCompleted = false
    @State private var scale: CGFloat = 0.0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(hex: "#7A4FFF").opacity(0.3), lineWidth: 1)
                .frame(width: orbitRadius * 2)
                .overlay(
                    Circle()
                        .trim(from: 0, to: 0.3)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#7A4FFF"),
                                    Color(hex: "#7A4FFF").opacity(0)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: orbitRadius * 2)
                        .rotationEffect(.degrees(Double(task.id.hashValue % 360)))
                )
            
            Circle()
                .fill(sphereGradient)
                .frame(width: sphereSize, height: sphereSize)
                .shadow(color: Color(hex: "#7A4FFF").opacity(0.6), radius: 10)
                .overlay(
                    Text(task.title)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .padding(4)
                )
                .scaleEffect(scale)
                .scaleEffect(isCompleted ? 1.5 : 1)
                .opacity(isCompleted ? 0 : 1)
                .onTapGesture { selectedTask = task }
                .gesture(
                    DragGesture(minimumDistance: 50)
                        .onEnded { _ in
                            if !task.isCompleted {
                                isCompleted = true
                                AudioServicesPlaySystemSound(1104)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    taskManager.completeTask(task)
                                }
                            }
                        }
                )
                .onAppear {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        scale = 1.0
                    }
                }
        }
    }
    
    private var sphereSize: CGFloat {
        switch task.priority {
        case .high: return 50
        case .medium: return 35
        case .low: return 25
        }
    }
    
    private var orbitRadius: CGFloat {
        switch task.priority {
        case .high: return 100
        case .medium: return 150
        case .low: return 200
        }
    }
    
    private var sphereGradient: RadialGradient {
        let baseColors = task.category?.color.map { $0.color } ?? [Color(hex: "#FF4FBF"), Color(hex: "#B84FFF")]
        let colors = task.priority == .low ?
            baseColors.map { $0.opacity(0.6) } :
            baseColors
        return RadialGradient(
            gradient: Gradient(colors: colors + [colors.first!.opacity(0.5)]),
            center: .center,
            startRadius: 5,
            endRadius: sphereSize / 2
        )
    }
}

struct StarfieldBackground: View {
    @State private var stars: [Star] = []
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#0D0D1A"),
                    Color(hex: "#1A0D2E"),
                    Color(hex: "#2B0D4F")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            Canvas { context, size in
                for star in stars {
                    context.opacity = star.opacity
                    context.fill(
                        Circle().path(in: CGRect(x: star.x, y: star.y, width: 2, height: 2)),
                        with: .color(.white)
                    )
                }
            }
            .ignoresSafeArea()
            .onAppear {
                for _ in 0..<100 {
                    stars.append(Star(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height),
                        opacity: CGFloat.random(in: 0.2...0.8)
                    ))
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let offset = value.translation
                        for i in 0..<stars.count {
                            stars[i].x += offset.width * 0.02
                            stars[i].y += offset.height * 0.02
                        }
                    }
            )
        }
    }
    
    struct Star {
        var x: CGFloat
        var y: CGFloat
        var opacity: CGFloat
    }
}

struct OrbitView_Previews: PreviewProvider {
    static var previews: some View {
        OrbitView()
            .environmentObject(TaskManager())
    }
}
