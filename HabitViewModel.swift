//
//  HabitViewModel.swift
//  HabitIQ
//
//  Created by 오도영 on 2/25/25.
//

import Foundation
// ✅ ViewModel 추가 (데이터 관리)
class HabitViewModel: ObservableObject {
    @Published var habits: [HabitEntity] = []

    init() {
        fetchHabits()
    }

    func fetchHabits() {
        habits = HabitDataManager.shared.fetchAllHabits()
    }

    func toggleCompletion(for habit: HabitEntity) {
        HabitDataManager.shared.toggleCompletion(for: habit)
        fetchHabits()
    }

    func deleteItems(at offsets: IndexSet) {
        let habitsToDelete = offsets.map { habits[$0] }
        habitsToDelete.forEach { HabitDataManager.shared.deleteHabit($0) }
        fetchHabits() // ✅ 삭제 후 다시 로드하여 최신 데이터 유지
    }
}
