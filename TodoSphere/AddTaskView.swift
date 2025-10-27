import SwiftUI

struct AddTaskView: View {
    @EnvironmentObject private var taskManager: TaskManager
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var deadline = Date()
    @State private var priority: Task.Priority = .medium
    
    var body: some View {
        ZStack {
            CosmicBackground()
            
            VStack(spacing: 20) {
                // Header with glowing effect
                Text("Add New Task")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: Color(hex: "#7A4FFF").opacity(0.5), radius: 5)
                    .padding(.top, 40)
                
                // Title input with cosmic styling
                TextField("Task Title", text: $title)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#2B0D4F").opacity(0.8),
                                    Color(hex: "#1A0D2E").opacity(0.8)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .shadow(color: Color(hex: "#FF4FBF").opacity(0.3), radius: 5)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color(hex: "#7A4FFF").opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal)
                
                // Description input with cosmic styling
                ZStack(alignment: .topLeading) {
                    if description.isEmpty {
                        Text("Description")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                    }
                    TextEditor(text: $description)
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "#2B0D4F").opacity(0.8),
                                        Color(hex: "#1A0D2E").opacity(0.8)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .shadow(color: Color(hex: "#FF4FBF").opacity(0.3), radius: 5)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color(hex: "#7A4FFF").opacity(0.3), lineWidth: 1)
                        )
                        .frame(height: 120)
                }
                .padding(.horizontal)
                
                // Deadline picker with cosmic styling
                DatePicker("Deadline", selection: $deadline, displayedComponents: [.date, .hourAndMinute])
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.white)
                    .accentColor(Color(hex: "#FF4FBF"))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#2B0D4F").opacity(0.8),
                                    Color(hex: "#1A0D2E").opacity(0.8)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .shadow(color: Color(hex: "#FF4FBF").opacity(0.3), radius: 5)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color(hex: "#7A4FFF").opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal)
                
                // Priority picker with cosmic styling
                Picker("Priority", selection: $priority) {
                    ForEach(Task.Priority.allCases, id: \.self) { priority in
                        Text(priority.rawValue.capitalized).tag(priority)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .colorScheme(.dark)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#2B0D4F").opacity(0.8),
                                Color(hex: "#1A0D2E").opacity(0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .shadow(color: Color(hex: "#FF4FBF").opacity(0.3), radius: 5)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color(hex: "#7A4FFF").opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal)
                
                // Save button as a glowing sphere
                Button(action: {
                    let task = Task(title: title, description: description, deadline: deadline, priority: priority)
                    withAnimation(.spring()) {
                        taskManager.addTask(task)
                        dismiss()
                    }
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
                        .frame(width: 70, height: 70)
                        .overlay(
                            Text("Save")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        )
                        .shadow(color: Color(hex: "#7A4FFF").opacity(0.5), radius: 10)
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .padding(.vertical)
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView()
            .environmentObject(TaskManager())
            .preferredColorScheme(.dark)
    }
}
