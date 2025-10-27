import Foundation
import SwiftUI
import UserNotifications

class TaskManager: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var categories: [Category] = [
        Category(name: "Work", color: [CodableColor(hex: "#FF4FBF"), CodableColor(hex: "#B84FFF")]),
        Category(name: "Personal", color: [CodableColor(hex: "#4FFF7A"), CodableColor(hex: "#7AFFB8")]),
        Category(name: "Urgent", color: [CodableColor(hex: "#FF4F4F"), CodableColor(hex: "#FF7A7A")])
    ]
    private let defaults = UserDefaults.standard
    private let tasksKey = "tasks"
    private let categoriesKey = "categories"
    
    init() {
        loadTasks()
        loadCategories()
    }
    
    func addTask(_ task: Task) {
        tasks.append(task)
        saveTasks()
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveTasks()
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])
        saveTasks()
    }
    
    func completeTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted = true
            tasks[index].completedDate = Date()
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])
            saveTasks()
        }
    }
    
    func scheduleNotification(for task: Task) {
        guard !task.isCompleted else { return }
        
        let content = UNMutableNotificationContent()
        content.title = task.title
        content.body = task.description.isEmpty ? "This task is due soon!" : task.description
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: task.deadline)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification scheduling error: \(error)")
            }
        }
    }
    
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            defaults.set(encoded, forKey: tasksKey)
        }
    }
    
    private func loadTasks() {
        if let data = defaults.data(forKey: tasksKey),
           let decoded = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decoded
        }
    }
    
    private func saveCategories() {
        if let encoded = try? JSONEncoder().encode(categories) {
            defaults.set(encoded, forKey: categoriesKey)
        }
    }
    
    private func loadCategories() {
        if let data = defaults.data(forKey: categoriesKey),
           let decoded = try? JSONDecoder().decode([Category].self, from: data) {
            categories = decoded
        }
    }
    
    func completedTasksCount(viewMode: StatisticsView.ViewMode = .weekly) -> Int {
        let calendar = Calendar.current
        let startDate = viewMode == .weekly ?
            calendar.date(byAdding: .day, value: -7, to: Date())! :
            calendar.date(byAdding: .month, value: -1, to: Date())!
        
        return tasks.filter { $0.isCompleted && $0.completedDate != nil && $0.completedDate! >= startDate }.count
    }
    
    func averageDailyTasks() -> Double {
        let completed = tasks.filter { $0.isCompleted && $0.completedDate != nil }
        guard !completed.isEmpty else { return 0 }
        let days = Set(completed.map { Calendar.current.startOfDay(for: $0.completedDate!) })
        return Double(completed.count) / Double(days.count)
    }
    
    func completionStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        while true {
            let tasksToday = tasks.filter {
                guard let completedDate = $0.completedDate else { return false }
                return calendar.isDate(completedDate, equalTo: currentDate, toGranularity: .day)
            }
            if tasksToday.isEmpty { break }
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }
        
        return streak
    }
}

struct Task: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var deadline: Date
    var priority: Priority
    var isCompleted: Bool
    var completedDate: Date?
    var category: Category?
    var subtasks: [String]
    
    enum Priority: String, Codable, CaseIterable {
        case low, medium, high
    }
    
    init(id: UUID = UUID(), title: String, description: String, deadline: Date, priority: Priority, category: Category? = nil, subtasks: [String] = [], isCompleted: Bool = false, completedDate: Date? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.deadline = deadline
        self.priority = priority
        self.category = category
        self.subtasks = subtasks
        self.isCompleted = isCompleted
        self.completedDate = completedDate
    }
}

struct Category: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let name: String
    let color: [CodableColor]
    
    init(name: String, color: [CodableColor]) {
        self.id = UUID()
        self.name = name
        self.color = color
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, color
    }
    
    static func ==(l: Category, r: Category) -> Bool {
        return l.id == r.id
    }
}

struct CodableColor: Codable, Hashable {
    let hex: String
    
    init(hex: String) {
        self.hex = hex
    }
    
    init(color: Color) {
        self.hex = color.toHex()
    }
    
    var color: Color {
        Color(hex: hex)
    }
}

extension Color {
    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return "#000000"
        }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
