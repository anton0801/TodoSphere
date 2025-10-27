import SwiftUI

struct ContentView: View {
    @StateObject private var taskManager = TaskManager()
    
    var body: some View {
        TabView {
            OrbitView()
                .tabItem {
                    Image(systemName: "globe")
                    Text("Orbit")
                }
                .environmentObject(taskManager)
            
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Statistics")
                }
                .environmentObject(taskManager)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
                .environmentObject(taskManager)
        }
        .accentColor(Color(hex: "#FF4FBF"))
        .background(LinearGradient(gradient: Gradient(colors: [
            Color(hex: "#0D0D1A"),
            Color(hex: "#1A0D2E"),
            Color(hex: "#2B0D4F")
        ]), startPoint: .top, endPoint: .bottom))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
