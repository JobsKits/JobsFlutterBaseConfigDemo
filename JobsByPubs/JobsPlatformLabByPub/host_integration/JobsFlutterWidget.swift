//
//  JobsFlutterWidget.swift
//  JobsFlutterWidget
//
//  Created by Jobs on 2026年11月14日，星期六.
//

import SwiftUI
import WidgetKit

private let widgetKind = "JobsFlutterLabWidget"

struct JobsFlutterEntry: TimelineEntry {
    let date: Date
    let text: String
}

struct JobsFlutterProvider: TimelineProvider {
    func placeholder(in context: Context) -> JobsFlutterEntry {
        JobsFlutterEntry(date: Date(), text: "Jobs Flutter")
    }
    func getSnapshot(in context: Context, completion: @escaping (JobsFlutterEntry) -> Void) {
        completion(entry())
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<JobsFlutterEntry>) -> Void) {
        completion(Timeline(entries: [entry()], policy: .after(Date().addingTimeInterval(900))))
    }
    private func entry() -> JobsFlutterEntry {
        let group = Bundle.main.object(forInfoDictionaryKey: "JobsWidgetAppGroup") as? String ?? "group.com.example.jobsFlutterBaseConfigDemo"
        let store = UserDefaults(suiteName: group)
        return JobsFlutterEntry(date: Date(), text: store?.string(forKey: "jobs.widget.text") ?? "Jobs Flutter")
    }
}

struct JobsFlutterWidgetContent: View {
    let entry: JobsFlutterEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Jobs Flutter").font(.headline)
            Text(entry.text).font(.body).lineLimit(5)
            Text(entry.date, style: .time).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding()
        .widgetURL(URL(string: "jobsflutter:///widget"))
    }
}

@main
struct JobsFlutterWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: widgetKind, provider: JobsFlutterProvider()) { entry in
            if #available(iOSApplicationExtension 17.0, *) {
                JobsFlutterWidgetContent(entry: entry).containerBackground(.background, for: .widget)
            } else {
                JobsFlutterWidgetContent(entry: entry)
            }
        }
        .configurationDisplayName("Jobs Flutter")
        .description("Shared demo data from the Flutter app")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
