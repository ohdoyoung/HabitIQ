import UserNotifications
import WidgetKit

class HabitNotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = HabitNotificationManager()
    @Published var activeHabit: HabitEntity? // 현재 푸시 알림과 연동되는 습관 정보
    @Published var isHabitCompleted: Bool = false // ✅ 알림의 완료 상태를 실시간으로 반영
    @Published var lastUpdatedHabitID: String? // ✅ 푸시 알림을 통해 변경된 습관 ID


    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("❌ 알림 권한 요청 오류: \(error.localizedDescription)")
            } else {
                print(granted ? "✅ 알림 권한 허용됨" : "🚫 알림 권한 거부됨")
            }
        }
        center.delegate = self
    }

//     ✅ 알림에서 "완료" 버튼을 눌렀을 때 실행
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "COMPLETE_HABIT_ACTION" {
            let habitID = response.notification.request.identifier
            HabitDataManager.shared.markHabitAsCompleted(habitID: habitID)
            WidgetCenter.shared.reloadAllTimelines() // ✅ 위젯 자동 업데이트
        }
        completionHandler()
    }
    
    func updateHabitStatus(for habit: HabitEntity) {
        DispatchQueue.main.async {
            self.activeHabit = habit
            self.isHabitCompleted = habit.completion == 1
        }
    }

    func markHabitAsCompleted() {
        DispatchQueue.main.async {
            self.isHabitCompleted = true
            self.activeHabit = nil // 알림 닫기
        }
    }
    
}

func scheduleCompletionReminder(for habit: HabitEntity) {
    guard let habitTime = habit.time else { return }
    let notificationCenter = UNUserNotificationCenter.current()

    let content = UNMutableNotificationContent()
    content.title = "⏳ 실시간 습관 체크"
    content.body = "\(habit.habitName ?? "습관") 완료하셨나요?"
    content.sound = .default
    content.categoryIdentifier = "HABIT_CHECK_CATEGORY"

    if let triggerTime = Calendar.current.date(byAdding: .minute, value: 1, to: habitTime) {
        let triggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)

        let request = UNNotificationRequest(identifier: habit.objectID.uriRepresentation().absoluteString, content: content, trigger: trigger)
        notificationCenter.add(request) { error in
            if let error = error {
                print("❌ 습관 체크 알림 등록 오류: \(error.localizedDescription)")
            } else {
                print("✅ 실시간 습관 체크 알림 예약됨: \(habit.habitName ?? "습관")")
//                LiveActivityManager.shared.startLiveActivity(for: habit) // 🔥 라이브 액티비티 시작
            }
        }
    }
}

func registerNotificationCategories() {
    let center = UNUserNotificationCenter.current()

    let completeAction = UNNotificationAction(
        identifier: "COMPLETE_HABIT_ACTION",
        title: "완료 ✅",
        options: [.foreground] // ✅ 버튼 클릭 시 앱 실행 없이 바로 동작
    )

    let category = UNNotificationCategory(
        identifier: "HABIT_CHECK_CATEGORY",
        actions: [completeAction],
        intentIdentifiers: [],
        options: [.customDismissAction] // ✅ 버튼이 배너에서도 보이도록 설정
    )

    center.setNotificationCategories([category])
    print("✅ 알림 카테고리 등록 완료")
}
