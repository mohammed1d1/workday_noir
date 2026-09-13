import AppIntents
import WidgetKit

private let suite = UserDefaults(suiteName: "group.com.workdaynoir.shared")

struct RecordWorkedIntent: AppIntent {
    static var title: LocalizedStringResource = "Record Worked Today"
    func perform() async throws -> some IntentResult { suite?.set("Worked ✓", forKey: "todayStatus"); WidgetCenter.shared.reloadAllTimelines(); return .result() }
}

struct RecordDidNotWorkIntent: AppIntent {
    static var title: LocalizedStringResource = "Record Didn't Work Today"
    func perform() async throws -> some IntentResult { suite?.set("Didn't work ×", forKey: "todayStatus"); WidgetCenter.shared.reloadAllTimelines(); return .result() }
}
