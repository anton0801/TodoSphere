import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var taskManager: TaskManager
    @State private var currentPage = 0
    @State private var isActive = false
    
    var body: some View {
        ZStack {
            if isActive {
                ContentView()
                    .environmentObject(taskManager)
                    .transition(.opacity)
            } else {
                StarfieldBackground()
                
                TabView(selection: $currentPage) {
                    OnboardingPage(
                        title: "Welcome to TodoSphere",
                        description: "Organize your tasks in a cosmic universe where every to-do is a glowing sphere!",
                        image: "globe"
                    )
                    .tag(0)
                    
                    OnboardingPage(
                        title: "Orbit Your Tasks",
                        description: "Tasks orbit the core based on priority—swipe to complete and watch them sparkle!",
                        image: "chart.bubble"
                    )
                    .tag(1)
                    
                    OnboardingPage(
                        title: "Track Your Progress",
                        description: "See your achievements in a stunning bubble chart and build your streak!",
                        image: "person.circle"
                    )
                    .tag(2)
                }
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
                VStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut) {
                            isActive = true
                        }
                    }) {
                        Text(currentPage == 2 ? "Get Started" : "Next")
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
                    .padding()
                }
            }
        }
        .ignoresSafeArea()
    }
}

struct OnboardingPage: View {
    let title: String
    let description: String
    let image: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(Color(hex: "#FF4FBF"))
                .shadow(color: Color(hex: "#7A4FFF").opacity(0.6), radius: 10)
            
            Text(title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: Color(hex: "#FF4FBF").opacity(0.6), radius: 8)
            
            Text(description)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(TaskManager())
    }
}
