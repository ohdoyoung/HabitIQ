import SwiftUI
import CoreData

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
                        Text("저장된 루틴이 없습니다.")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(viewModel.habits, id: \..objectID) { habit in
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
            .onAppear {
                viewModel.fetchHabits()
                viewModel.resetDailyCompletion() // ✅ 하루마다 달성률 초기화
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("HabitUpdated"))) { _ in
                viewModel.fetchHabits()
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
                
                Text("카테고리: \(categoryToString(habit.category))")
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

extension HabitViewModel {
    func resetDailyCompletion() {
        let request: NSFetchRequest<HabitEntity> = HabitEntity.fetchRequest()
        let context = PersistenceController.shared.container.viewContext
        do {
            let habits = try context.fetch(request)
            for habit in habits {
                habit.completion = 0
            }
            try context.save()
            print("✅ 하루가 지나 달성률이 초기화되었습니다.")
        } catch {
            print("❌ 달성률 초기화 오류: \(error.localizedDescription)")
        }
    }
}
