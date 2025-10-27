import SwiftUI
import AudioToolbox

struct AddTaskView: View {
    @EnvironmentObject private var taskManager: TaskManager
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var deadline = Date()
    @State private var priority: Task.Priority = .medium
    @State private var category: Category? = nil
    @State private var rotation: Double = 0
    @State private var subtaskTitle = ""
    @State private var subtasks: [String] = []
    
    var body: some View {
        ZStack {
            StarfieldBackground()
            
            VStack(spacing: 20) {
                Text("Add New Task")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: Color(hex: "#FF4FBF").opacity(0.6), radius: 10)
                    .padding(.top, 40)
                
                TextField("Task Title", text: $title)
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
                    .padding(.horizontal)
                
                ZStack(alignment: .topLeading) {
                    if description.isEmpty {
                        Text("Description")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                    }
                    TextEditor(text: $description)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
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
                        .frame(height: 120)
                }
                .padding(.horizontal)
                
                DatePicker("Deadline", selection: $deadline, displayedComponents: [.date, .hourAndMinute])
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.white)
                    .accentColor(Color(hex: "#FF4FBF"))
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
                    .padding(.horizontal)
                
                Picker("Priority", selection: $priority) {
                    ForEach(Task.Priority.allCases, id: \.self) { priority in
                        Text(priority.rawValue.capitalized).tag(priority)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .colorScheme(.dark)
                .padding(.horizontal)
                
                Picker("Category", selection: $category) {
                    Text("None").tag(nil as Category?)
                    ForEach(taskManager.categories, id: \.self) { category in
                        Text(category.name).tag(category as Category?)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .colorScheme(.dark)
                .padding(.horizontal)
                
                VStack(alignment: .leading) {
                    Text("Subtasks")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    ForEach(subtasks.indices, id: \.self) { index in
                        HStack {
                            Text(subtasks[index])
                                .foregroundColor(.gray)
                            Spacer()
                            Button(action: {
                                subtasks.remove(at: index)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    HStack {
                        TextField("New Subtask", text: $subtaskTitle)
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
                            if !subtaskTitle.isEmpty {
                                subtasks.append(subtaskTitle)
                                subtaskTitle = ""
                                AudioServicesPlaySystemSound(1104)
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(Color(hex: "#FF4FBF"))
                        }
                    }
                }
                .padding(.horizontal)
                
                Button(action: {
                    let task = Task(
                        title: title,
                        description: description,
                        deadline: deadline,
                        priority: priority,
                        category: category,
                        subtasks: subtasks
                    )
                    taskManager.addTask(task)
                    taskManager.scheduleNotification(for: task)
                    AudioServicesPlaySystemSound(1104)
                    dismiss()
                }) {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#FF4FBF"),
                                Color(hex: "#B84FFF")
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Text("Save")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        )
                        .shadow(color: Color(hex: "#7A4FFF").opacity(0.6), radius: 15)
                        .rotationEffect(.degrees(rotation))
                        .animation(Animation.linear(duration: 10).repeatForever(autoreverses: false), value: rotation)
                }
                .padding(.top, 20)
                .onAppear {
                    rotation = 360
                }
                
                Spacer()
            }
            .padding(.vertical)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: "#2B0D4F").opacity(0.7))
                    .shadow(color: Color(hex: "#FF4FBF").opacity(0.4), radius: 15)
            )
            .padding()
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView()
            .environmentObject(TaskManager())
    }
}
