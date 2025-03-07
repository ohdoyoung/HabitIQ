//
//  AppIntent.swift
//  HabitWidget
//
//  Created by 오도영 on 3/5/25.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "This is an example widget." }

    // An example configurable parameter.
    @Parameter(title: "Favorite Emoji", default: "😃")
    var favoriteEmoji: String
    
//    static func toggleCompletionIntent(habitName: String, habitTime: String) -> ToggleHabitCompletionIntent {
//            var intent = ToggleHabitCompletionIntent()
//            intent.habitName = habitName
//            intent.habitTime = habitTime
//            return intent
//        }
}
//
