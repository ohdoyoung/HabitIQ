//
//  HabitListView.swift
//  HabitIQ
//
//  Created by 오도영 on 2/21/25.
//

import SwiftUI

// ✅ 사용자가 저장한 습관을 보는 뷰
struct HabitListView: View {
    @State private var habits: [HabitEntity] = HabitDataManager.shared.fetchAllHabits()
    
    var body: some View {
        VStack {
            Text("나의 습관 목록")
                .font(.title)
                .padding()
            
            List {
                ForEach(habits, id: \..self) { habit in
                    HStack {
                        Text("카테고리: \(habit.category)")
                        Spacer()
                        Button(action: {
                            HabitDataManager.shared.toggleCompletion(for: habit)
                            habits = HabitDataManager.shared.fetchAllHabits()
                        }) {
                            Image(systemName: habit.completion != 0 ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(habit.completion != 0 ? .green : .gray)
                        }
                    }
                }
            }
        }
        .onAppear {
            habits = HabitDataManager.shared.fetchAllHabits()
        }
    }
}
