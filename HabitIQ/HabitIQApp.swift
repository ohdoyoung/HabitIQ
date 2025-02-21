import SwiftUI

@main
struct HabitIQApp: App {
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
            }
        }
    }
}
