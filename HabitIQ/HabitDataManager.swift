import Foundation
import CoreData
import CoreML
import UserNotifications


// ✅ 카테고리 매핑 함수 추가
func categoryToString(_ category: Int16) -> String {
    switch category {
    case 0: return "운동"
    case 1: return "독서"
    case 2: return "명상"
    case 3: return "식단"
    case 4: return "공부"
    case 5: return "취미"
    default: return "기타"
    }
}

// ✅ 습관 피드백 메시지 생성
func generateHabitFeedback(habits: [HabitEntity]) -> String {
    if habits.isEmpty {
        return "새로운 습관을 추천해줄게요! 도전해보실래요?"
    }
    
    let habitCounts = Dictionary(grouping: habits, by: { $0.category }).mapValues { $0.count }
    if let mostCommonCategory = habitCounts.max(by: { $0.value < $1.value })?.key {
        return "최근에 \(categoryToString(mostCommonCategory))을 많이 하셨네요! 새로운 방법으로 도전해보는 건 어떨까요?"
    }
    
    return "지금까지의 습관을 분석해 맞춤 추천을 해드릴게요!"
}

// ✅ Core Data 관리 (습관 저장 및 불러오기)
class HabitDataManager {
    static let shared = HabitDataManager()
    let context = PersistenceController.shared.container.viewContext
    
    func saveHabit(category: Int, habitName: String, timeOfDay: Date, frequency: Int, durationWeeks: Int) {
        let newHabit = HabitEntity(context: context)
        newHabit.category = Int16(category)
        newHabit.habitName = habitName // ✅ 습관 이름 추가
        newHabit.timeOfDay = Int16(Calendar.current.component(.hour, from: timeOfDay) * 60 + Calendar.current.component(.minute, from: timeOfDay)) // ✅ Date → 분(Int) 변환
        newHabit.time = timeOfDay // ✅ 원본 시간 저장
        newHabit.frequency = Int16(frequency)
        newHabit.durationWeeks = Int16(durationWeeks)
        newHabit.completion = 0 // ✅ 처음 저장 시 completion은 0 (미완료 상태)
        newHabit.date = Date()
        
        do {
            try context.save()
            print("✅ 새로운 습관 저장 완료!")
        } catch {
            print("❌ 습관 저장 오류: \(error.localizedDescription)")
        }
    }
    
    func fetchAllHabits() -> [HabitEntity] {
        let request: NSFetchRequest<HabitEntity> = HabitEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("❌ 데이터 가져오기 오류: \(error.localizedDescription)")
            return []
        }
    }
    
    func toggleCompletion(for habit: HabitEntity) {
        habit.completion = habit.completion != 0 ? 0 : 1 // ✅ 완료 여부 토글 (0 → 1 또는 1 → 0)
        do {
            try context.save()
            print("✅ 습관 완료 상태 변경됨!")
        } catch {
            print("❌ 완료 상태 변경 오류: \(error.localizedDescription)")
        }
    }
}

func getPersonalizedRecommendation(category: Int, timeOfDay: Int, frequency: Int, durationWeeks: Int, completion: Int) -> String? {
    do {
        let model = try habit_recommendation(configuration: MLModelConfiguration())
        
        // ✅ 입력 데이터를 MultiArray 형식으로 변환
        let inputArray = try MLMultiArray(shape: [5], dataType: .double)
        inputArray[0] = NSNumber(value: category)
        inputArray[1] = NSNumber(value: timeOfDay)
        inputArray[2] = NSNumber(value: frequency)
        inputArray[3] = NSNumber(value: durationWeeks)
        inputArray[4] = NSNumber(value: completion)
        
        // ✅ 입력 객체 생성
        let input = habit_recommendationInput(input: inputArray)
        
        // ✅ 예측 실행
        let prediction = try model.prediction(input: input)
        return categoryToString(Int16(prediction.classLabel)) // ✅ 카테고리를 문자열로 변환
        
    } catch {
        print("❌ 예측 실패: \(error.localizedDescription)")
        return nil
    }
}

func updateMLModel() {
    guard let modelURL = Bundle.main.url(forResource: "habit_recommendation", withExtension: "mlmodelc") else {
        print("❌ 모델 로드 실패")
        return
    }

    do {
        // ✅ 'try'를 사용하여 오류 처리
        let updateTask = try MLUpdateTask(forModelAt: modelURL, trainingData: getTrainingData(), completionHandler: { (context) in
            print("✅ 모델 업데이트 완료!")
        })
        updateTask.resume()
        
    } catch {
        print("❌ 모델 업데이트 실패: \(error.localizedDescription)")
    }
}

func getTrainingData() -> MLBatchProvider {
    let recentHabits = HabitDataManager.shared.fetchAllHabits()
    var featureArray: [MLFeatureProvider] = []
    
    for habit in recentHabits {
        let featureDict: [String: MLFeatureValue] = [
            "category": MLFeatureValue(int64: Int64(habit.category)),
            "timeOfDay": MLFeatureValue(int64: Int64(habit.timeOfDay)),
            "frequency": MLFeatureValue(int64: Int64(habit.frequency)),
            "durationWeeks": MLFeatureValue(int64: Int64(habit.durationWeeks)),
            "completion": MLFeatureValue(int64: Int64(habit.completion))
        ]
        featureArray.append(try! MLDictionaryFeatureProvider(dictionary: featureDict))
    }
    return MLArrayBatchProvider(array: featureArray)
}

func scheduleHabitNotification(for habit: HabitEntity) {
    guard let habitTime = habit.time else { return }
    let notificationCenter = UNUserNotificationCenter.current()
    
    let content = UNMutableNotificationContent()
    content.title = "⏳ 습관 알림"
    content.body = "\(habit.habitName) 시작할 시간이 다가와요! 준비되셨나요?"
    content.sound = .default
    
    let calendar = Calendar.current
    if let triggerTime = calendar.date(byAdding: .minute, value: -20, to: habitTime) {
        let triggerComponents = calendar.dateComponents([.hour, .minute], from: triggerTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        notificationCenter.add(request) { error in
            if let error = error {
                print("❌ 알림 등록 오류: \(error.localizedDescription)")
            } else {
                print("✅ 알림이 성공적으로 예약되었습니다: \(habit.habitName)")
            }
        }
    }
}

func requestNotificationPermission() {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if let error = error {
            print("❌ 알림 권한 요청 오류: \(error.localizedDescription)")
        } else {
            print(granted ? "✅ 알림 권한 허용됨" : "🚫 알림 권한 거부됨")
        }
    }
}
