import SwiftUI

struct HabitEntryView: View {
    @State private var category: Int = 0
    @State private var habitName: String = ""
    @State private var selectedTime = Date()
    @State private var frequency: Int = 1
    @State private var durationWeeks: Int = 1
    @State private var showConfirmation = false
    
    let categories = ["🏋️ 운동", "📚 독서", "🧘 명상", "🍽️ 식단", "✏️ 공부", "🎨 취미"]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("새로운 습관 추가")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.top, 20)
            
            VStack(spacing: 15) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(0..<categories.count, id: \..self) { index in
                            Text(categories[index])
                                .font(.headline)
                                .padding()
                                .background(category == index ? Color.blue.opacity(0.8) : Color(UIColor.systemGray6))
                                .foregroundColor(category == index ? .white : .primary)
                                .cornerRadius(12)
                                .onTapGesture {
                                    category = index
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                
                TextField("습관 이름 입력 (예: 아침 조깅)", text: $habitName)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.systemGray6)))
                    .padding(.horizontal)
                
                VStack(spacing: 10) {
                    HStack {
                        Text("시간 설정")
                            .font(.headline)
                        Spacer()
                        DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.systemGray6)))
                
                    HStack {
                        Text("주간 빈도")
                            .font(.headline)
                        Spacer()
                        Stepper(value: $frequency, in: 1...7) {
                            Text("\(frequency)회")
                                .font(.headline)
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.systemGray6)))
                
                    HStack {
                        Text("지속 기간")
                            .font(.headline)
                        Spacer()
                        Stepper(value: $durationWeeks, in: 1...12) {
                            Text("\(durationWeeks)주")
                                .font(.headline)
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.systemGray6)))
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.white).shadow(radius: 5))
                .padding(.horizontal)
            }
            
            Button(action: {
                HabitDataManager.shared.saveHabit(
                    category: category,
                    habitName: habitName, // ✅ 습관 이름 전달
                    timeOfDay: selectedTime, // ✅ Date 값 그대로 전달 (변환은 내부에서 처리)
                    frequency: frequency,
                    durationWeeks: durationWeeks
                )
                showConfirmation = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.headline)
                    Text("습관 저장하기")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]), startPoint: .leading, endPoint: .trailing))
                .foregroundColor(.white)
                .cornerRadius(16)
                .shadow(color: Color.blue.opacity(0.4), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal)
            .alert(isPresented: $showConfirmation) {
                Alert(title: Text("저장 완료!"), message: Text("새로운 습관이 추가되었습니다."), dismissButton: .default(Text("확인")))
            }
            
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [Color(UIColor.systemBackground), Color.green.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
        )
    }
}
