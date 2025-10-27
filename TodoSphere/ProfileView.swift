import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var taskManager: TaskManager
    @State private var selectedTheme: Theme = .dark
    
    enum Theme: String, CaseIterable {
        case dark, neon, glow
    }
    
    var body: some View {
        ZStack {
            CosmicBackground()
            
            if taskManager.tasks.isEmpty {
                Text("Start adding tasks to build your galaxy")
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                VStack {
                    Circle()
                        .fill(LinearGradient(gradient: Gradient(colors: [
                            Color(hex: "#FF4FBF"),
                            Color(hex: "#B84FFF")
                        ]), startPoint: .top, endPoint: .bottom))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Circle()
                                .stroke(Color(hex: "#7A4FFF").opacity(0.3), lineWidth: 2)
                                .frame(width: 120, height: 120)
                        )
                        .padding(.top, 50)
                    
                    Text("My Profile")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    
                    Text("Completed Tasks: \(taskManager.completedTasksCount())")
                        .foregroundColor(.white)
                        .padding()
                    
                    Text("Average Daily Tasks: \(String(format: "%.1f", taskManager.averageDailyTasks()))")
                        .foregroundColor(.white)
                        .padding()
                    
                    Picker("Theme", selection: $selectedTheme) {
                        ForEach(Theme.allCases, id: \.self) { theme in
                            Text(theme.rawValue.capitalized).tag(theme)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .foregroundColor(.white)
                    .padding()
                    
                    Toggle("Notifications", isOn: .constant(true))
                        .foregroundColor(.white)
                        .padding()
                    
                    Button("Export Tasks") {
                        // Placeholder for export functionality
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color(hex: "#2B0D4F"))
                    .cornerRadius(10)
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(TaskManager())
    }
}
