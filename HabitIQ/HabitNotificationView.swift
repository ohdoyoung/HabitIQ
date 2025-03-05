import SwiftUI

struct HabitNotificationView: View {
    @ObservedObject var notificationManager = HabitNotificationManager.shared

    var body: some View {
        if let habit = notificationManager.activeHabit {
            VStack {
                Spacer()
                HStack {
                    VStack(alignment: .leading) {
                        Text("⏳ 습관 알림")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("\(habit.habitName ?? "습관") 완료하셨나요?")
                            .foregroundColor(.white.opacity(0.9))
                            .font(.subheadline)
                    }
                    Spacer()
                    if !notificationManager.isHabitCompleted {
                        Button(action: {
                            HabitDataManager.shared.markHabitAsCompleted(habitID: habit.objectID.uriRepresentation().absoluteString)
                            notificationManager.markHabitAsCompleted()
                        }) {
                            Text("완료 ✅")
                                .foregroundColor(.blue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.white)
                                .cornerRadius(8)
                        }
                    } else {
                        Text("✅ 완료됨")
                            .foregroundColor(.green)
                            .bold()
                    }
                }
                .padding()
                .background(Color.black.opacity(0.9))
                .cornerRadius(12)
                .shadow(radius: 10)
                .padding(.horizontal, 20)
                .transition(.move(edge: .bottom))
                .animation(.easeOut)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}
