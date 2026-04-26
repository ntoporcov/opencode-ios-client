import SwiftUI
import WidgetKit

struct OpenCodePinnedSessionsWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: OpenCodeWidgetKind.pinnedSessions,
            provider: OpenCodeSessionsTimelineProvider(source: .pinned)
        ) { entry in
            OpenCodeSessionsWidgetView(entry: entry)
        }
        .configurationDisplayName("Pinned Sessions")
        .description("Keep an eye on pinned OpenClient sessions.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
