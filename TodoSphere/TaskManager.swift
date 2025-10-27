import Foundation
import SwiftUI

class TaskManager: ObservableObject {
    @Published var tasks: [Task] = []
    private let defaults = UserDefaults.standard
    private let tasksKey = "tasks"
    
    init() {
        loadTasks()
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
        saveTasks()
    }
    
    func completeTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted = true
            tasks[index].completedDate = Date()
            saveTasks()
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
    
    func completedTasksCount() -> Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    func averageDailyTasks() -> Double {
        let completed = tasks.filter { $0.isCompleted && $0.completedDate != nil }
        guard !completed.isEmpty else { return 0 }
        let days = Set(completed.map { Calendar.current.startOfDay(for: $0.completedDate!) })
        return Double(completed.count) / Double(days.count)
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
    
    enum Priority: String, Codable, CaseIterable {
        case low, medium, high
    }
    
    init(id: UUID = UUID(), title: String, description: String, deadline: Date, priority: Priority, isCompleted: Bool = false, completedDate: Date? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.deadline = deadline
        self.priority = priority
        self.isCompleted = isCompleted
        self.completedDate = completedDate
    }
}
