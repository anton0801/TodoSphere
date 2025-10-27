import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var taskManager: TaskManager
    
    var body: some View {
        TabView {
            OrbitView()
                .tabItem {
                    Image(systemName: "globe")
                        .environment(\.symbolVariants, .none)
                        .overlay(Circle().stroke(Color(hex: "#FF4FBF").opacity(0.5), lineWidth: 2))
                    Text("Orbit")
                }
            
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.bar")
                        .environment(\.symbolVariants, .none)
                        .overlay(Circle().stroke(Color(hex: "#FF4FBF").opacity(0.5), lineWidth: 2))
                    Text("Statistics")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                        .environment(\.symbolVariants, .none)
                        .overlay(Circle().stroke(Color(hex: "#FF4FBF").opacity(0.5), lineWidth: 2))
                    Text("Profile")
                }
        }
        .preferredColorScheme(.dark)
        .accentColor(Color(hex: "#FF4FBF"))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TaskManager())
    }
}
