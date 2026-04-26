import SwiftUI
import WidgetKit

struct OpenCodeRecentSessionsWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: OpenCodeWidgetKind.recentSessions,
            provider: OpenCodeSessionsTimelineProvider(source: .recent)
        ) { entry in
            OpenCodeSessionsWidgetView(entry: entry)
        }
        .configurationDisplayName("Recent Sessions")
        .description("Monitor the latest OpenClient sessions across projects.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
