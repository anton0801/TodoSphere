import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject private var taskManager: TaskManager
    @State private var viewMode: ViewMode = .weekly
    
    enum ViewMode: String, CaseIterable {
        case weekly = "Weekly"
        case monthly = "Monthly"
    }
    
    var body: some View {
        ZStack {
            StarfieldBackground()
            
            if taskManager.tasks.isEmpty {
                Text("Your TodoSphere will grow as you complete tasks")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color(hex: "#2B0D4F").opacity(0.8))
                    .cornerRadius(15)
                    .shadow(color: Color(hex: "#FF4FBF").opacity(0.4), radius: 10)
            } else {
                VStack(spacing: 20) {
                    Text("Statistics")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: Color(hex: "#FF4FBF").opacity(0.6), radius: 10)
                        .padding(.top, 50)
                    
                    Picker("View Mode", selection: $viewMode) {
                        ForEach(ViewMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .colorScheme(.dark)
                    .padding(.horizontal)
                    
                    ScrollView {
                        BubbleChartView(tasks: taskManager.tasks, viewMode: viewMode)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(hex: "#2B0D4F").opacity(0.7))
                                    .shadow(color: Color(hex: "#FF4FBF").opacity(0.4), radius: 15)
                            )
                            .padding(.horizontal)
                        
                        Text("You popped \(taskManager.completedTasksCount(viewMode: viewMode)) tasks this \(viewMode.rawValue.lowercased())!")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .padding()
                        
                        Text("Completion Streak: \(taskManager.completionStreak()) days")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .padding()
                        
                        TaskPyramidView(tasks: taskManager.tasks, viewMode: viewMode)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(hex: "#2B0D4F").opacity(0.7))
                                    .shadow(color: Color(hex: "#FF4FBF").opacity(0.4), radius: 15)
                            )
                            .padding(.horizontal)
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}

struct BubbleChartView: View {
    let tasks: [Task]
    let viewMode: StatisticsView.ViewMode
    @State private var scale: CGFloat = 0.0
    
    var body: some View {
        Canvas { context, size in
            let calendar = Calendar.current
            let now = Date()
            let startDate = viewMode == .weekly ?
                calendar.date(byAdding: .day, value: -7, to: now)! :
                calendar.date(byAdding: .month, value: -1, to: now)!
            
            let completed = tasks.filter { $0.isCompleted && $0.completedDate != nil && $0.completedDate! >= startDate }
            let active = tasks.filter { !$0.isCompleted && $0.deadline >= now }
            let overdue = tasks.filter { !$0.isCompleted && $0.deadline < now }
            
            for (index, task) in (completed + active + overdue).enumerated() {
                let x = CGFloat.random(in: 20...(size.width - 20))
                let y = CGFloat.random(in: 20...(size.height - 20))
                let color: Color = task.isCompleted ? Color(hex: "#FFD84F") :
                    task.deadline < now ? .red.opacity(0.5) :
                    task.category?.color.first?.color ?? Color(hex: "#FF4FBF")
                
                context.fill(
                    Circle().path(in: CGRect(x: x, y: y, width: 25 * scale, height: 25 * scale)),
                    with: .color(color)
                )
            }
        }
        .frame(height: 220)
        .scaleEffect(scale)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1.0
            }
        }
    }
}

struct TaskPyramidView: View {
    let tasks: [Task]
    let viewMode: StatisticsView.ViewMode
    
    var body: some View {
        VStack {
            let days = viewMode == .weekly ? 7 : 30
            ForEach(0..<days, id: \.self) { day in
                let count = tasks.filter {
                    guard let completedDate = $0.completedDate else { return false }
                    return Calendar.current.isDate(completedDate, equalTo: Date().addingTimeInterval(TimeInterval(day * -86400)), toGranularity: .day)
                }.count
                
                HStack {
                    ForEach(0..<count, id: \.self) { _ in
                        Circle()
                            .fill(Color(hex: "#FFD84F"))
                            .frame(width: 25, height: 25)
                            .shadow(color: Color(hex: "#7A4FFF").opacity(0.4), radius: 8)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
            .environmentObject(TaskManager())
    }
}
