import SwiftUI

struct PracticeView: View {
    @EnvironmentObject private var journalStore: ReflectionJournalStore
    @EnvironmentObject private var questStore: QuestStore
    let onStartRecording: () -> Void
    let onOpenJournalEntry: (JournalReflectionEntry) -> Void

    private var progress: AppProgressSnapshot {
        ProgressEngine.snapshot(entries: journalStore.entries, quests: questStore.quests)
    }

    var body: some View {
        ZStack {
            PinguScreenBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    progressRow

                    if let activeQuest = questStore.latestActiveQuest {
                        activePracticeCard(activeQuest)
                    } else {
                        emptyActivePractice
                    }

                    practiceHistorySection(
                        title: "Completed practice",
                        emptyText: "Completed practices will appear here after you mark one done.",
                        quests: questStore.completedQuests,
                        statusIcon: "checkmark.circle.fill",
                        statusColor: PinguDesign.blue
                    )

                    practiceHistorySection(
                        title: "Skipped practice",
                        emptyText: "Skipped practices stay here so you can restart one when it fits again.",
                        quests: questStore.skippedQuests,
                        statusIcon: "arrow.uturn.backward.circle.fill",
                        statusColor: PinguDesign.orange
                    )
                }
                .padding(.horizontal, PinguDesign.screenSidePadding)
                .padding(.top, 22)
                .padding(.bottom, PinguDesign.bottomBarHeight + 36)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Practice")
                .font(.system(size: 35, weight: .bold, design: .rounded))
                .foregroundStyle(PinguDesign.ink)

            Text("Turn AI reflections into one small action you can actually complete today.")
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundStyle(PinguDesign.muted)
                .lineSpacing(4)
        }
    }

    private var progressRow: some View {
        HStack(spacing: 10) {
            PracticeMetricTile(value: "\(questStore.activeQuests.count)", label: "Active", icon: "flag.fill")
            PracticeMetricTile(value: "\(questStore.completedQuests.count)", label: "Done", icon: "checkmark.seal.fill")
            PracticeMetricTile(value: "LV\(progress.level)", label: "Level", icon: "sparkles")
        }
    }

    private func activePracticeCard(_ quest: Quest) -> some View {
        PinguCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "checklist.checked")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 46, height: 46)
                        .background(PinguDesign.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Today's practice")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(PinguDesign.muted)

                        Text(quest.detail)
                            .font(.system(size: 21, weight: .bold, design: .rounded))
                            .foregroundStyle(PinguDesign.ink)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                if let entry = sourceEntry(for: quest) {
                    Button {
                        onOpenJournalEntry(entry)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(PinguDesign.blue)

                            VStack(alignment: .leading, spacing: 3) {
                                Text("From reflection")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(PinguDesign.muted)

                                Text(entry.displayTitle)
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundStyle(PinguDesign.ink)
                                    .lineLimit(1)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(PinguDesign.muted)
                        }
                        .padding(12)
                        .background(PinguDesign.lightBlue.opacity(0.48))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }

                HStack(spacing: 10) {
                    Button {
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                            questStore.complete(quest)
                        }
                    } label: {
                        Label("Complete", systemImage: "checkmark")
                    }
                    .buttonStyle(PracticeActionButtonStyle(isPrimary: true))

                    Button {
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                            questStore.skip(quest)
                        }
                    } label: {
                        Label("Skip", systemImage: "forward.fill")
                    }
                    .buttonStyle(PracticeActionButtonStyle(isPrimary: false))
                }
            }
        }
    }

    private var emptyActivePractice: some View {
        PinguCard {
            VStack(spacing: 16) {
                Image(systemName: "sparkles.rectangle.stack.fill")
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundStyle(PinguDesign.blue)

                VStack(spacing: 8) {
                    Text("No active practice")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(PinguDesign.ink)

                    Text("Save a reflection and Circleu will turn the AI suggestion into a short practice here.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(PinguDesign.muted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }

                Button {
                    onStartRecording()
                } label: {
                    Label("Create from reflection", systemImage: "mic.fill")
                }
                .buttonStyle(PinguPrimaryButtonStyle())
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func practiceHistorySection(
        title: String,
        emptyText: String,
        quests: [Quest],
        statusIcon: String,
        statusColor: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(PinguDesign.ink)

            if quests.isEmpty {
                Text(emptyText)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(PinguDesign.muted)
                    .lineSpacing(4)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white.opacity(0.76))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            } else {
                VStack(spacing: 10) {
                    ForEach(quests) { quest in
                        PracticeHistoryRow(
                            quest: quest,
                            sourceEntry: sourceEntry(for: quest),
                            statusIcon: statusIcon,
                            statusColor: statusColor,
                            onOpenSource: { entry in
                                onOpenJournalEntry(entry)
                            },
                            onReactivate: {
                                withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                                    questStore.reactivate(quest)
                                }
                            }
                        )
                    }
                }
            }
        }
    }

    private func sourceEntry(for quest: Quest) -> JournalReflectionEntry? {
        guard let sourceEntryID = quest.sourceEntryID else { return nil }
        return journalStore.entry(with: sourceEntryID)
    }
}

private struct PracticeMetricTile: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(PinguDesign.blue)

            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(PinguDesign.ink)
                .minimumScaleFactor(0.76)
                .lineLimit(1)

            Text(label)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(PinguDesign.muted)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 92)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: PinguDesign.deepBlue.opacity(0.04), radius: 12, y: 6)
    }
}

private struct PracticeHistoryRow: View {
    let quest: Quest
    let sourceEntry: JournalReflectionEntry?
    let statusIcon: String
    let statusColor: Color
    let onOpenSource: (JournalReflectionEntry) -> Void
    let onReactivate: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: statusIcon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(statusColor)
                    .frame(width: 38, height: 38)
                    .background(PinguDesign.lightBlue.opacity(0.62))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 5) {
                    Text(quest.detail)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(PinguDesign.ink)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(statusText)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(PinguDesign.muted)
                }
            }

            HStack(spacing: 10) {
                if let sourceEntry {
                    Button {
                        onOpenSource(sourceEntry)
                    } label: {
                        Label("Reflection", systemImage: "book.closed.fill")
                    }
                    .buttonStyle(PracticeSmallButtonStyle())
                }

                Button {
                    onReactivate()
                } label: {
                    Label("Restart", systemImage: "arrow.clockwise")
                }
                .buttonStyle(PracticeSmallButtonStyle())
            }
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: PinguDesign.deepBlue.opacity(0.04), radius: 12, y: 6)
    }

    private var statusText: String {
        switch quest.status {
        case .active:
            "Active"
        case .completed:
            quest.completedAt.map { "Completed \($0.formatted(date: .abbreviated, time: .shortened))" } ?? "Completed"
        case .skipped:
            quest.completedAt.map { "Skipped \($0.formatted(date: .abbreviated, time: .shortened))" } ?? "Skipped"
        }
    }
}

private struct PracticeActionButtonStyle: ButtonStyle {
    let isPrimary: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .foregroundStyle(isPrimary ? .white : PinguDesign.blue)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(isPrimary ? PinguDesign.blue : PinguDesign.lightBlue.opacity(0.78))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

private struct PracticeSmallButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundStyle(PinguDesign.blue)
            .padding(.horizontal, 12)
            .frame(height: 36)
            .background(PinguDesign.lightBlue.opacity(configuration.isPressed ? 0.58 : 0.78))
            .clipShape(Capsule())
    }
}

#Preview {
    PracticeView(onStartRecording: {}, onOpenJournalEntry: { _ in })
        .environmentObject(ReflectionJournalStore())
        .environmentObject(QuestStore())
}
