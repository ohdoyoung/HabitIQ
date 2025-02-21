import Foundation
import SwiftUI
import CoreData


struct HabitData {
    var name: String
    var category: String
    var timeOfDay: String
    var frequency: String
}

struct Habit: Identifiable {
    let id = UUID()
    let name: String
    var isCompleted: Bool
    
}

