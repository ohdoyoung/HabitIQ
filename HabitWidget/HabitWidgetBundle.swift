//
//  HabitWidgetBundle.swift
//  HabitWidget
//
//  Created by 오도영 on 3/5/25.
//

import WidgetKit
import SwiftUI

@main
struct HabitWidgetBundle: WidgetBundle {
    var body: some Widget {
        HabitWidget()
        HabitWidgetControl()
        HabitWidgetLiveActivity()
    }
}
