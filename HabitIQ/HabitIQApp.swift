import SwiftUI

@main
struct HabitIQApp: App {
    init() {
            requestNotificationPermission()
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
                    .tabItem{
                        Label("습관 리스트", systemImage: "slider.horizontal.3")
                    }
            }
        }
    }
}
