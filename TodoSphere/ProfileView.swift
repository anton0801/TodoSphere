import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var taskManager: TaskManager
    @State private var selectedTheme: Theme = .dark
    @State private var rotation: Double = 0
    
    enum Theme: String, CaseIterable {
        case dark, neon, glow
    }
    
    var body: some View {
        ZStack {
            StarfieldBackground()
            
            if taskManager.tasks.isEmpty {
                Text("Start adding tasks to build your galaxy")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color(hex: "#2B0D4F").opacity(0.8))
                    .cornerRadius(15)
                    .shadow(color: Color(hex: "#FF4FBF").opacity(0.4), radius: 10)
            } else {
                VStack(spacing: 20) {
                    Circle()
                        .fill(RadialGradient(
                            gradient: Gradient(colors: [
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
                            Circle()
                                .stroke(Color(hex: "#FFD84F").opacity(0.4), lineWidth: 3)
                                .frame(width: 140, height: 140)
                        )
                        .rotationEffect(.degrees(rotation))
                        .animation(Animation.linear(duration: 20).repeatForever(autoreverses: false), value: rotation)
                        .onAppear {
                            rotation = 360
                        }
                        .padding(.top, 50)
                    
                    Text("My Profile")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: Color(hex: "#FF4FBF").opacity(0.6), radius: 10)
                    
                    statCard(title: "Completed Tasks", value: "\(taskManager.completedTasksCount())")
                    statCard(title: "Average Daily Tasks", value: String(format: "%.1f", taskManager.averageDailyTasks()))
                    statCard(title: "Completion Streak", value: "\(taskManager.completionStreak()) days")
                    
                    Picker("Theme", selection: $selectedTheme) {
                        ForEach(Theme.allCases, id: \.self) { theme in
                            Text(theme.rawValue.capitalized).tag(theme)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .colorScheme(.dark)
                    .padding(.horizontal)
                    
                    Toggle("Notifications", isOn: .constant(true))
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    Button("Privacy Policy") {
                        UIApplication.shared.open(URL(string: "https://docs.google.com/document/d/1GfJQoPMrWwCd1SRm-p9Ha24793Rf53PTo1EG2yUcJjw/")!)
                    }
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#2B0D4F"))
                    .cornerRadius(15)
                    .shadow(color: Color(hex: "#FF4FBF").opacity(0.4), radius: 8)
                    
                    Button("Support") {
                        UIApplication.shared.open(URL(string: "https://docs.google.com/document/d/1YHmTP7fObt_SquIuFYMPIjNjsCuyWtPRgAX0dMeAFRo/")!)
                    }
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#2B0D4F"))
                    .cornerRadius(15)
                    .shadow(color: Color(hex: "#FF4FBF").opacity(0.4), radius: 8)
                }
                .padding()
            }
        }
        .ignoresSafeArea()
    }
    
    private func statCard(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.white)
            Spacer()
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#FF4FBF"))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(hex: "#2B0D4F").opacity(0.9))
                .shadow(color: Color(hex: "#FF4FBF").opacity(0.4), radius: 8)
        )
        .padding(.horizontal)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(TaskManager())
    }
}
