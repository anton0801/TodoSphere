import SwiftUI

struct TaskDetailView: View {
    @EnvironmentObject private var taskManager: TaskManager
    @Environment(\.dismiss) private var dismiss
    @State private var task: Task
    @State private var isEditing = false
    @State private var newSubtaskTitle = ""
    
    init(task: Task) {
        self._task = State(initialValue: task)
    }
    
    var body: some View {
        ZStack {
            StarfieldBackground()
            
            VStack(spacing: 20) {
                Circle()
                    .fill(RadialGradient(
                        gradient: Gradient(colors: task.category?.color.map { $0.color } ?? [
                            Color(hex: "#FF4FBF"),
                            Color(hex: "#B84FFF"),
                            Color(hex: "#FF4FBF").opacity(0.5)
                        ]),
                        center: .center,
                        startRadius: 10,
                        endRadius: 50
                    ))
                    .frame(width: 120, height: 120)
                    .shadow(color: Color(hex: "#7A4FFF").opacity(0.6), radius: 15)
                    .overlay(
                        ForEach(task.subtasks.indices, id: \.self) { index in
                            Circle()
                                .fill(Color(hex: "#FFD84F").opacity(0.7))
                                .frame(width: 20, height: 20)
                                .offset(x: cos(Double(index) * 2 * .pi / Double(task.subtasks.count)) * 80,
                                        y: sin(Double(index) * 2 * .pi / Double(task.subtasks.count)) * 80)
                        }
                    )
                
                if isEditing {
                    TextField("Title", text: $task.title)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "#2B0D4F").opacity(0.9),
                                        Color(hex: "#1A0D2E").opacity(0.9)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .shadow(color: Color(hex: "#FF4FBF").opacity(0.4), radius: 8)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color(hex: "#7A4FFF").opacity(0.4), lineWidth: 1)
                        )
                    
                    TextEditor(text: $task.description)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.gray)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "#2B0D4F").opacity(0.9),
                                        Color(hex: "#1A0D2E").opacity(0.9)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .shadow(color: Color(hex: "#FF4FBF").opacity(0.4), radius: 8)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color(hex: "#7A4FFF").opacity(0.4), lineWidth: 1)
                        )
                        .frame(height: 100)
                    
                    DatePicker("Deadline", selection: $task.deadline, displayedComponents: [.date, .hourAndMinute])
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.white)
                        .accentColor(Color(hex: "#FF4FBF"))
                    
                    Picker("Priority", selection: $task.priority) {
                        ForEach(Task.Priority.allCases, id: \.self) { priority in
                            Text(priority.rawValue.capitalized).tag(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .colorScheme(.dark)
                    
                    Picker("Category", selection: $task.category) {
                        Text("None").tag(nil as Category?)
                        ForEach(taskManager.categories, id: \.self) { category in
                            Text(category.name).tag(category as Category?)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .colorScheme(.dark)
                    
                    VStack(alignment: .leading) {
                        Text("Subtasks")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        ForEach(task.subtasks.indices, id: \.self) { index in
                            HStack {
                                Text(task.subtasks[index])
                                    .foregroundColor(.gray)
                                Spacer()
                                Button(action: {
                                    task.subtasks.remove(at: index)
                                    taskManager.updateTask(task)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        
                        HStack {
                            TextField("New Subtask", text: $newSubtaskTitle)
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(hex: "#2B0D4F").opacity(0.9))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(hex: "#7A4FFF").opacity(0.4), lineWidth: 1)
                                )
                            
                            Button(action: {
                                if !newSubtaskTitle.isEmpty {
                                    task.subtasks.append(newSubtaskTitle)
                                    taskManager.updateTask(task)
                                    newSubtaskTitle = ""
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(Color(hex: "#FF4FBF"))
                            }
                        }
                    }
                    .padding(.vertical)
                } else {
                    Text(task.title)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: Color(hex: "#FF4FBF").opacity(0.4), radius: 8)
                    
                    Text(task.description)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.gray)
                        .padding()
                    
                    Text("Deadline: \(task.deadline, style: .date) \(task.deadline, style: .time)")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Priority: \(task.priority.rawValue.capitalized)")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Category: \(task.category?.name ?? "None")")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading) {
                        Text("Subtasks")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        ForEach(task.subtasks, id: \.self) { subtask in
                            Text("• \(subtask)")
                                .foregroundColor(.gray)
                                .padding(.vertical, 2)
                        }
                    }
                }
                
                HStack(spacing: 20) {
                    Button(action: {
                        taskManager.completeTask(task)
                        dismiss()
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(hex: "#FFD84F"))
                            .frame(width: 40, height: 40)
                    }
                    
                    Button(action: { isEditing.toggle() }) {
                        Image(systemName: isEditing ? "xmark.circle.fill" : "pencil.circle.fill")
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                    }
                    
                    Button(action: {
                        taskManager.deleteTask(task)
                        dismiss()
                    }) {
                        Image(systemName: "trash.circle.fill")
                            .foregroundColor(.red)
                            .frame(width: 40, height: 40)
                    }
                }
                .padding()
                
                if isEditing {
                    Button(action: {
                        taskManager.updateTask(task)
                        isEditing = false
                    }) {
                        Text("Save")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "#FF4FBF"),
                                        Color(hex: "#B84FFF")
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(15)
                            .shadow(color: Color(hex: "#7A4FFF").opacity(0.6), radius: 10)
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: "#2B0D4F").opacity(0.7))
                    .shadow(color: Color(hex: "#FF4FBF").opacity(0.4), radius: 15)
            )
            .padding()
        }
    }
}

struct TaskDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TaskDetailView(task: Task(
            title: "Sample",
            description: "Description",
            deadline: Date(),
            priority: .medium,
            category: Category(name: "Work", color: [CodableColor(hex: "#FF4FBF"), CodableColor(hex: "#B84FFF")])
        ))
            .environmentObject(TaskManager())
    }
}
