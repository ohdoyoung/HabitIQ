import SwiftUI

struct HabitRecommendationView: View {
    @State private var recommendedHabit: String = ""
    @State private var habits: [HabitEntity] = []
    @State private var feedbackMessage: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("✨ 오늘의 맞춤 습관 ✨")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.top, 20)
                .tracking(1.2)
            
            VStack(alignment: .leading, spacing: 12) {
                Text(feedbackMessage)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
                
                Text(recommendedHabit)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.blue.opacity(0.4)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .cornerRadius(16)
                    .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.white).shadow(radius: 10))
            .padding(.horizontal)
            
            Button(action: {
                if let firstHabit = habits.first {
                    let completionValue = firstHabit.completion != 0 ? 1 : 0
                    if let habit = getPersonalizedRecommendation(
                        category: Int(firstHabit.category),
                        timeOfDay: Int(firstHabit.timeOfDay),
                        frequency: Int(firstHabit.frequency),
                        durationWeeks: Int(firstHabit.durationWeeks),
                        completion: completionValue
                    ) {
                        recommendedHabit = "🌟 추천 습관: \(habit) 🌟"
                    } else {
                        recommendedHabit = "추천할 데이터가 부족해요!"
                    }
                } else {
                    recommendedHabit = "저장된 습관이 없습니다."
                }
                feedbackMessage = generateHabitFeedback(habits: habits)
            }) {
                HStack {
                    Image(systemName: "sparkles")
                        .font(.headline)
                    Text("새로운 추천 받기")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing)
                )
                .foregroundColor(.white)
                .cornerRadius(16)
                .shadow(color: Color.purple.opacity(0.4), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [Color(UIColor.systemBackground), Color.blue.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
        )
        .onAppear {
            habits = HabitDataManager.shared.fetchAllHabits()
            feedbackMessage = generateHabitFeedback(habits: habits)
        }
    }
}
