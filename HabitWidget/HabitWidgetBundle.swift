//
//  HabitWidgetBundle.swift
//  HabitWidget
//
//  Created by 오도영 on 3/5/25.
//

import WidgetKit
import SwiftUI
import AppIntents

@main
struct HabitWidgetBundle: WidgetBundle {
    var body: some Widget {
        HabitWidget()
        HabitWidgetControl()
        HabitWidgetLiveActivity()
    }
    @AppShortcutsBuilder
    static var appShortcuts: [AppShortcut] {
           AppShortcut(
               intent: ToggleHabitCompletionIntent(),
               phrases: ["Toggle habit completion"]
           )
       }
}
