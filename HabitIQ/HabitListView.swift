import SwiftUI

struct HabitListView: View {
    @State private var habits: [HabitEntity] = []
    @State private var refreshTrigger = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("나의 습관")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                if habits.isEmpty {
                    Text("저장된 습관이 없습니다.")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(habits, id: \..self) { habit in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(habit.habitName)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Text("카테고리: \(categoryToString(habit.category))")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text("시간: \(formattedTime(habit.time))")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Button(action: {
                                        HabitDataManager.shared.toggleCompletion(for: habit)
                                        refreshTrigger.toggle() // ✅ UI 업데이트 트리거
                                    }) {
                                        Image(systemName: habit.completion != 0 ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(habit.completion != 0 ? .green : .gray)
                                            .font(.title2)
                                    }
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.systemGray5)))
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 10)
                    }
                }
            }
            .padding(.bottom, 20)
            .onAppear {
                habits = HabitDataManager.shared.fetchAllHabits()
            }
            .id(refreshTrigger) // ✅ UI 강제 리프레시
        }
    }
}

// ✅ 시간 포맷 변환 함수
func formattedTime(_ date: Date?) -> String {
    guard let date = date else { return "시간 없음" }
    let formatter = DateFormatter()
    formatter.dateFormat = "hh:mm a"
    return formatter.string(from: date)
}
