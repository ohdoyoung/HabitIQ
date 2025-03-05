import SwiftUI

struct HabitListView: View {
    @ObservedObject private var viewModel = HabitViewModel()

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.habits.isEmpty {
                    VStack {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                            .padding(.bottom, 10)
                        Text("저장된 습관이 없습니다.")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(viewModel.habits, id: \.objectID) { habit in
                            HabitRowView(habit: habit) {
                                viewModel.toggleCompletion(for: habit)
                            }
                            .listRowSeparator(.hidden)
                        }
                        .onDelete(perform: viewModel.deleteItems)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .padding(.bottom, 20)
            .onAppear { // ✅ 뷰가 나타날 때 습관 목록 갱신
                viewModel.fetchHabits()
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("HabitUpdated"))) { _ in
                viewModel.fetchHabits() // ✅ 푸시 알림을 통해 습관이 완료되면 자동 반영
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("나의 루틴")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
    }
}


// ✅ 개별 습관 Row 뷰
struct HabitRowView: View {
    let habit: HabitEntity
    let onToggleCompletion: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(habit.habitName ?? "이름 없음")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("카테고리: \(habit.category)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("🕒 \(formattedTime(habit.time))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            
            Button(action: onToggleCompletion) {
                Image(systemName: habit.completion != 0 ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(habit.completion != 0 ? .green : .gray)
                    .font(.title2)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
        )
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


