//
//  AbitWidgetBundle.swift
//  AbitWidget
//
//  Created by 오도영 on 3/5/25.
//

import WidgetKit
import SwiftUI

@main
struct AbitWidgetBundle: WidgetBundle {
    var body: some Widget {
        AbitWidget()
        AbitWidgetControl()
        AbitWidgetLiveActivity()
    }
}
