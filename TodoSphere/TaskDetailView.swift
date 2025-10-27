import SwiftUI

struct TaskDetailView: View {
    @EnvironmentObject private var taskManager: TaskManager
    @Environment(\.dismiss) private var dismiss
    @State private var task: Task
    @State private var isEditing = false
    
    init(task: Task) {
        self._task = State(initialValue: task)
    }
    
    var body: some View {
        ZStack {
            CosmicBackground()
            
            VStack {
                Circle()
                    .fill(LinearGradient(gradient: Gradient(colors: [
                        Color(hex: "#FF4FBF"),
                        Color(hex: "#B84FFF")
                    ]), startPoint: .top, endPoint: .bottom))
                    .frame(width: 100, height: 100)
                    .shadow(color: Color(hex: "#7A4FFF").opacity(0.3), radius: 20)
                
                if isEditing {
                    TextField("Title", text: $task.title)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color(hex: "#2B0D4F"))
                        .cornerRadius(10)
                    
                    TextEditor(text: $task.description)
                        .foregroundColor(.gray)
                        .padding()
                        .background(Color(hex: "#2B0D4F"))
                        .cornerRadius(10)
                        .frame(height: 100)
                    
                    DatePicker("Deadline", selection: $task.deadline, displayedComponents: [.date, .hourAndMinute])
                        .foregroundColor(.white)
                        .accentColor(Color(hex: "#FF4FBF"))
                    
                    Picker("Priority", selection: $task.priority) {
                        ForEach(Task.Priority.allCases, id: \.self) { priority in
                            Text(priority.rawValue.capitalized).tag(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .foregroundColor(.white)
                } else {
                    Text(task.title)
                        .font(.title)
                        .foregroundColor(.white)
                    
                    Text(task.description)
                        .foregroundColor(.gray)
                        .padding()
                    
                    Text("Deadline: \(task.deadline, style: .date) \(task.deadline, style: .time)")
                        .foregroundColor(.white)
                    
                    Text("Priority: \(task.priority.rawValue.capitalized)")
                        .foregroundColor(.white)
                }
                
                HStack {
                    Button(action: {
                        taskManager.completeTask(task)
                        dismiss()
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(hex: "#FFD84F"))
                    }
                    
                    Button(action: { isEditing.toggle() }) {
                        Image(systemName: isEditing ? "xmark.circle.fill" : "pencil.circle.fill")
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        taskManager.deleteTask(task)
                        dismiss()
                    }) {
                        Image(systemName: "trash.circle.fill")
                            .foregroundColor(.red)
                    }
                }
                .padding()
                
                if isEditing {
                    Button(action: {
                        taskManager.updateTask(task)
                        isEditing = false
                    }) {
                        Text("Save")
                            .foregroundColor(.white)
                            .padding()
                            .background(LinearGradient(gradient: Gradient(colors: [
                                Color(hex: "#FF4FBF"),
                                Color(hex: "#B84FFF")
                            ]), startPoint: .top, endPoint: .bottom))
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
    }
}

struct TaskDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TaskDetailView(task: Task(title: "Sample", description: "Description", deadline: Date(), priority: .medium))
            .environmentObject(TaskManager())
    }
}
