import SwiftUI

struct HabitListView: View {
    @ObservedObject private var viewModel = HabitViewModel()

    var body: some View {
        NavigationView {
            VStack {
                Text("나의 습관")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)

                if viewModel.habits.isEmpty {
                    Text("저장된 습관이 없습니다.")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.habits, id: \..self) { habit in
                            HabitRowView(habit: habit) {
                                viewModel.toggleCompletion(for: habit)
                            }
                        }
                        .onDelete(perform: viewModel.deleteItems)
                    }
                    .toolbar {
                        EditButton() // ✅ 에딧 버튼 다시 추가함!
                    }
                }
            }
            .padding(.bottom, 20)
            .navigationTitle("나의 습관")
        }
    }
}

// ✅ 개별 습관 Row 뷰 분리
struct HabitRowView: View {
    let habit: HabitEntity
    let onToggleCompletion: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(habit.habitName ?? "이름 없음")
                    .font(.headline)
                Text("카테고리: \(categoryToString(habit.category))")
                    .font(.subheadline)
                Text("시간: \(formattedTime(habit.time))")
                    .font(.subheadline)
            }
            Spacer()
            Button(action: onToggleCompletion) {
                Image(systemName: habit.completion != 0 ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(habit.completion != 0 ? .green : .gray)
                    .font(.title2)
            }
        }
        .padding()
//        .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.systemGray5)))
        .padding(.horizontal)
    }
}

// ✅ 시간 포맷 변환 함수
func formattedTime(_ date: Date?) -> String {
    guard let date = date else { return "시간 없음" }
    let formatter = DateFormatter()
    formatter.dateFormat = "hh:mm a"
    return formatter.string(from: date)
}
