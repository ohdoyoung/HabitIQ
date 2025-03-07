//
//  AbitWidgetLiveActivity.swift
//  AbitWidget
//
//  Created by 오도영 on 3/5/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct AbitWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct AbitWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AbitWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension AbitWidgetAttributes {
    fileprivate static var preview: AbitWidgetAttributes {
        AbitWidgetAttributes(name: "World")
    }
}

extension AbitWidgetAttributes.ContentState {
    fileprivate static var smiley: AbitWidgetAttributes.ContentState {
        AbitWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: AbitWidgetAttributes.ContentState {
         AbitWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: AbitWidgetAttributes.preview) {
   AbitWidgetLiveActivity()
} contentStates: {
    AbitWidgetAttributes.ContentState.smiley
    AbitWidgetAttributes.ContentState.starEyes
}
