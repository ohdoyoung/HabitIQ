import SwiftUI
import UserNotifications

@main
struct HabitIQApp: App {
    let notificationDelegate = HabitNotificationDelegate()

    init() {
        requestNotificationPermission() // 🔥 알림 권한 요청
        registerNotificationCategories() // 🔥 "완료" 버튼이 포함된 알림 설정
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }

    var body: some Scene {
        WindowGroup {
            TabView {
                HabitEntryView()
                    .tabItem {
                        Label("습관 기록", systemImage: "pencil")
                    }
                HabitRecommendationView()
                    .tabItem {
                        Label("추천 받기", systemImage: "star")
                    }
                HabitListView()
                    .tabItem {
                        Label("습관 리스트", systemImage: "slider.horizontal.3")
                    }
            }
            .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)

        }
    }
}
