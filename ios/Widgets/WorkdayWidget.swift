import WidgetKit
import SwiftUI

struct WorkdayEntry: TimelineEntry { let date: Date; let status: String }
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> WorkdayEntry { WorkdayEntry(date: .now, status: "Not recorded") }
    func getSnapshot(in context: Context, completion: @escaping (WorkdayEntry) -> Void) { completion(WorkdayEntry(date: .now, status: sharedStatus())) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<WorkdayEntry>) -> Void) { let entry = WorkdayEntry(date: .now, status: sharedStatus()); completion(Timeline(entries: [entry], policy: .after(Calendar.current.date(byAdding: .minute, value: 15, to: .now)!))) }
    private func sharedStatus() -> String { UserDefaults(suiteName: "group.com.workdaynoir.shared")?.string(forKey: "todayStatus") ?? "Not recorded" }
}
struct WorkdayWidgetView: View {
    let entry: WorkdayEntry
    var body: some View { VStack(alignment: .leading, spacing: 6) { Text("WORKDAY").font(.caption).fontWeight(.bold).tracking(1.4); Spacer(); Text("Today").foregroundStyle(.secondary); Text(entry.status).font(.title3).fontWeight(.semibold) }.containerBackground(.black, for: .widget) }
}
@main struct WorkdayWidgetBundle: WidgetBundle { var body: some Widget { WorkdayWidget() } }
struct WorkdayWidget: Widget {
    let kind = "WorkdayWidget"
    var body: some WidgetConfiguration { StaticConfiguration(kind: kind, provider: Provider()) { WorkdayWidgetView(entry: $0) }.configurationDisplayName("Workday").description("See today's work status.").supportedFamilies([.systemSmall,.systemMedium,.accessoryCircular,.accessoryRectangular]) }
}
