import SwiftUI

public enum JournalCalendarSampleDay: Sendable {
    case saved
    case empty
    case multiple
}

/// October 2026 is an immutable sample month, not calendar/date-filter implementation.
public struct JournalCalendarPreview: View {
    public let day: JournalCalendarSampleDay
    public var emptyDay: Bool { day == .empty }
    private var selectedDay: Int { day == .multiple ? 21 : (emptyDay ? 20 : 24) }
    private let entryDays: Set<Int> = [8, 13, 21, 24]
    private let weekdays = ["M", "T", "W", "T", "F", "S", "S"]

    public init(emptyDay: Bool = false) { self.day = emptyDay ? .empty : .saved }
    public init(day: JournalCalendarSampleDay) { self.day = day }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                BrandWordmark(size: 23)
                Spacer()
                Image(systemName: "slider.horizontal.3").font(.system(size: 20, weight: .medium))
            }
            .padding(.top, 12)

            HStack {
                Text("Journal").font(BrandDemoFont.font(30, .bold)).tracking(-1)
                Spacer()
                Label("Search", systemImage: "magnifyingglass")
                    .font(BrandDemoFont.font(12, .semibold)).foregroundStyle(BrandDemoColor.blue)
            }
            .padding(.top, 18)
            calendar.padding(.top, 18)

            HStack {
                Text(day == .multiple ? "Wednesday, 21 October" : (emptyDay ? "Tuesday, 20 October" : "Saturday, 24 October"))
                    .font(BrandDemoFont.font(15, .semibold))
                Spacer()
                Text(day == .multiple ? "2 entries" : (emptyDay ? "No entries" : "1 entry"))
                    .font(BrandDemoFont.font(11)).foregroundStyle(BrandDemoColor.muted)
            }
            .padding(.top, 20).padding(.bottom, 12)

            if emptyDay {
                VStack(alignment: .leading, spacing: 10) {
                    Text("A little space, just for you.").font(BrandDemoFont.font(17, .semibold))
                    BrandFixture.detail("No saved moments on this day. Browse another date or start a reflection for today.", size: 14)
                }
                .padding(18).frame(maxWidth: .infinity, alignment: .leading)
                .background(.white, in: RoundedRectangle(cornerRadius: 22))
            } else if day == .multiple {
                VStack(alignment: .leading, spacing: 14) {
                    compactEntry("Speaking up in class", subtitle: "9:15 am · Reflection")
                    Rectangle().fill(BrandDemoColor.ice).frame(height: 1)
                    compactEntry("A pause before replying", subtitle: "6:40 pm · My words")
                }
                .padding(18).background(.white, in: RoundedRectangle(cornerRadius: 22))
            } else {
                BrandFixture.card(
                    title: "The group deadline", subtitle: "Reflection · 10:30 am",
                    body: "I need a clear update and a shared plan.", tag: "Linked practice"
                )
            }
            Spacer(minLength: 14)
            BrandFixture.action("New reflection for today").padding(.bottom, 14)
            BrandFixture.tabs(selected: .journal)
        }
        .padding(.horizontal, 24).padding(.bottom, 22)
        .frame(width: 390, height: 844)
        .foregroundStyle(BrandDemoColor.ink).background(BrandDemoColor.ice)
        .clipShape(RoundedRectangle(cornerRadius: 36)).environment(\.colorScheme, .light)
    }

    private func compactEntry(_ title: String, subtitle: String) -> some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 6) {
                Text(subtitle).font(BrandDemoFont.font(11)).foregroundStyle(BrandDemoColor.muted)
                Text(title).font(BrandDemoFont.font(15, .semibold))
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right").font(.system(size: 11, weight: .semibold))
                .foregroundStyle(BrandDemoColor.muted)
        }
    }

    private var calendar: some View {
        VStack(spacing: 9) {
            HStack(spacing: 8) {
                Text("October 2026").font(BrandDemoFont.font(16, .semibold))
                Spacer()
                Image(systemName: "chevron.left")
                    .accessibilityLabel("Previous month, static preview")
                Image(systemName: "chevron.right").padding(.leading, 12)
                    .accessibilityLabel("Next month, static preview")
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(BrandDemoColor.blue)

            HStack(spacing: 0) {
                ForEach(weekdays.indices, id: \.self) { index in
                    Text(weekdays[index]).font(BrandDemoFont.font(10, .semibold))
                        .foregroundStyle(BrandDemoColor.muted).frame(maxWidth: .infinity)
                }
            }
            // Monday-first: October 1, 2026 is Thursday. Three leading blanks, one trailing blank.
            VStack(spacing: 3) {
                ForEach(0..<5, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<7, id: \.self) { column in
                            dayCell(row * 7 + column - 2)
                        }
                    }
                }
            }
            HStack(spacing: 5) {
                Circle().fill(BrandDemoColor.blue).frame(width: 4, height: 4)
                Text("Saved moment").font(BrandDemoFont.font(10))
                Spacer()
                RoundedRectangle(cornerRadius: 3).stroke(BrandDemoColor.orange, lineWidth: 1.5)
                    .frame(width: 9, height: 9)
                Text("Today").font(BrandDemoFont.font(10))
            }
            .foregroundStyle(BrandDemoColor.muted).padding(.top, 2)
        }
        .padding(16).background(.white, in: RoundedRectangle(cornerRadius: 24))
    }

    private func dayCell(_ day: Int) -> some View {
        Group {
            if (1...31).contains(day) {
                VStack(spacing: 2) {
                    Text("\(day)").font(BrandDemoFont.font(12, day == selectedDay ? .bold : .medium))
                    Circle().fill(entryDays.contains(day)
                        ? (day == selectedDay ? .white : BrandDemoColor.blue) : .clear)
                        .frame(width: 3, height: 3)
                }
                .frame(width: 29, height: 29)
                .foregroundStyle(day == selectedDay ? .white : BrandDemoColor.ink)
                .background(day == selectedDay ? BrandDemoColor.blue : BrandDemoColor.ice,
                            in: RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(day == 24 ? BrandDemoColor.orange : .clear, lineWidth: 1.5))
                .accessibilityLabel("October \(day), 2026\(entryDays.contains(day) ? ", saved moment" : ", no entries")\(day == selectedDay ? ", selected" : "")\(day == 24 ? ", today in sample" : "")")
            } else {
                Color.clear.frame(width: 29, height: 29).accessibilityHidden(true)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

public struct JournalCalendarGallery: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            BrandWordmark(size: 30)
            BrandFixture.detail("A gentler way to revisit your days. No streaks, scores or pressure.", size: 15)
            HStack(alignment: .top, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    BrandFixture.eyebrow("A DAY WITH A SAVED MOMENT")
                    JournalCalendarPreview()
                }
                VStack(alignment: .leading, spacing: 12) {
                    BrandFixture.eyebrow("A DAY WITHOUT ENTRIES")
                    JournalCalendarPreview(emptyDay: true)
                }
            }
            BrandFixture.detail("Brand demo 03 · October 2026 fixture · Static dates, search and actions", size: 12)
        }
        .padding(32).foregroundStyle(BrandDemoColor.ink).background(.white)
        .environment(\.colorScheme, .light)
    }
}

#Preview("Journal · calendar", traits: .sizeThatFitsLayout) { JournalCalendarPreview() }
#Preview("Journal · empty day", traits: .sizeThatFitsLayout) { JournalCalendarPreview(emptyDay: true) }
#Preview("Journal · calendar comparison", traits: .sizeThatFitsLayout) { JournalCalendarGallery() }
#Preview("Journal · multiple entries", traits: .sizeThatFitsLayout) { JournalCalendarPreview(day: .multiple) }
