import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject private var taskManager: TaskManager
    
    var body: some View {
        ZStack {
            CosmicBackground()
            
            if taskManager.tasks.isEmpty {
                Text("Your TodoSphere will grow as you complete tasks")
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                VStack {
                    Text("Statistics")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding(.top, 50)
                    
                    ScrollView {
                        BubbleChartView(tasks: taskManager.tasks)
                        
                        Text("You popped \(taskManager.completedTasksCount()) tasks this week!")
                            .foregroundColor(.white)
                            .padding()
                        
                        TaskPyramidView(tasks: taskManager.tasks)
                    }
                }
            }
        }
    }
}

struct BubbleChartView: View {
    let tasks: [Task]
    
    var body: some View {
        Canvas { context, size in
            let completed = tasks.filter { $0.isCompleted }
            let active = tasks.filter { !$0.isCompleted && $0.deadline >= Date() }
            let overdue = tasks.filter { !$0.isCompleted && $0.deadline < Date() }
            
            for (index, task) in (completed + active + overdue).enumerated() {
                let x = CGFloat.random(in: 20...(size.width - 20))
                let y = CGFloat.random(in: 20...(size.height - 20))
                let color: Color = task.isCompleted ? Color(hex: "#FFD84F") :
                    task.deadline < Date() ? .red.opacity(0.5) :
                    Color(hex: "#FF4FBF")
                
                context.fill(
                    Circle().path(in: CGRect(x: x, y: y, width: 20, height: 20)),
                    with: .color(color)
                )
            }
        }
        .frame(height: 200)
        .padding()
    }
}

struct TaskPyramidView: View {
    let tasks: [Task]
    
    var body: some View {
        VStack {
            ForEach(0..<7) { day in
                let count = tasks.filter {
                    guard let completedDate = $0.completedDate else { return false }
                    return Calendar.current.isDate(completedDate, equalTo: Date().addingTimeInterval(TimeInterval(day * -86400)), toGranularity: .day)
                }.count
                
                HStack {
                    ForEach(0..<count, id: \.self) { _ in
                        Circle()
                            .fill(Color(hex: "#FFD84F"))
                            .frame(width: 20, height: 20)
                    }
                }
            }
        }
        .padding()
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
            .environmentObject(TaskManager())
    }
}
