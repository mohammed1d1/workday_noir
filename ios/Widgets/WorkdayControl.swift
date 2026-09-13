import WidgetKit
import SwiftUI
import AppIntents

@available(iOS 18.0, *)
struct WorkdayControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "WorkdayControl") {
            ControlWidgetButton(action: RecordWorkedIntent()) { Label("Worked", systemImage: "checkmark") }
        }
        .displayName("Workday")
        .description("Mark today as worked.")
    }
}
