import SwiftUI
import UIKit

struct JournalEntryDetailView: View {
    let entry: JournalReflectionEntry
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var journalStore: ReflectionJournalStore
    @EnvironmentObject private var aiSessionStore: AIReflectionSessionStore
    @EnvironmentObject private var questStore: QuestStore
    @EnvironmentObject private var circleStore: CircleStore
    @State private var didCopy = false
    @State private var showCircleShareSheet = false

    var body: some View {
        ZStack {
            PinguScreenBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(entry.result.title)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(PinguDesign.ink)

                        HStack(spacing: 10) {
                            Text(entry.result.emotion)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(PinguDesign.blue)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 7)
                                .background(PinguDesign.lightBlue.opacity(0.66))
                                .clipShape(Capsule())

                            Text(entry.engineName)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(PinguDesign.muted)
                        }
                    }

                    detailCard(title: "Summary", body: entry.result.summary, icon: "text.alignleft")
                    detailCard(title: "Insight", body: entry.result.insight, icon: "heart.fill")
                    detailCard(title: "Expression moment", body: entry.result.expressionMoment, icon: "waveform")
                    detailCard(title: "Suggested quest", body: entry.result.suggestedQuest, icon: "flag.fill")
                    practiceActionsCard

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Transcript")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(PinguDesign.ink)

                        Text(entry.transcript)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundStyle(PinguDesign.body)
                            .lineSpacing(5)
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

                    Text(entry.createdAt.formatted(date: .complete, time: .shortened))
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(PinguDesign.muted)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, PinguDesign.screenSidePadding)
                .padding(.top, 20)
                .padding(.bottom, 34)
            }
        }
        .navigationTitle("Reflection")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        UIPasteboard.general.string = journalStore.shareText(for: entry)
                        didCopy = true
                    } label: {
                        Label(didCopy ? "Copied reflection" : "Copy reflection", systemImage: "doc.on.doc")
                    }

                    ShareLink(item: journalStore.shareText(for: entry)) {
                        Label("Share reflection", systemImage: "square.and.arrow.up")
                    }

                    Button(role: .destructive) {
                        deleteEntry()
                        dismiss()
                    } label: {
                        Label("Delete reflection", systemImage: "trash.fill")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showCircleShareSheet) {
            JournalCircleShareSheet(entry: entry)
                .environmentObject(circleStore)
                .presentationDetents([.medium, .large])
        }
    }

    private func detailCard(title: String, body: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundStyle(PinguDesign.blue)
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(PinguDesign.ink)
            }

            Text(body)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(PinguDesign.body)
                .lineSpacing(4)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: PinguDesign.deepBlue.opacity(0.04), radius: 12, y: 6)
    }

    private var practiceActionsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "checklist.checked")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(PinguDesign.blue)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily practice")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(PinguDesign.ink)

                    Text(questStatusText)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(PinguDesign.muted)
                }

                Spacer()
            }

            Text(entry.result.suggestedQuest)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(PinguDesign.body)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            questActionButtons

            Divider()
                .overlay(PinguDesign.border.opacity(0.6))

            Button {
                showCircleShareSheet = true
            } label: {
                Label("Save insight to a private circle", systemImage: "person.2.wave.2.fill")
            }
            .buttonStyle(PinguSecondaryButtonStyle())
            .disabled(circleStore.circles.isEmpty)
            .opacity(circleStore.circles.isEmpty ? 0.55 : 1)

            if circleStore.circles.isEmpty {
                Text("Create a private circle from the Circles tab before saving this reflection into a support space.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(PinguDesign.muted)
                    .lineSpacing(3)
            } else if circleStore.circles.allSatisfy({ circleStore.hasShared(entry: entry, to: $0) }) {
                Text("This reflection is already saved in every private circle.")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(PinguDesign.blue)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: PinguDesign.deepBlue.opacity(0.04), radius: 12, y: 6)
    }

    @ViewBuilder
    private var questActionButtons: some View {
        if let quest = questStore.quest(for: entry) {
            switch quest.status {
            case .active:
                HStack(spacing: 10) {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.84)) {
                            questStore.complete(quest)
                        }
                    } label: {
                        Label("Complete", systemImage: "checkmark")
                    }
                    .buttonStyle(PinguPrimaryButtonStyle())

                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.84)) {
                            questStore.skip(quest)
                        }
                    } label: {
                        Label("Skip", systemImage: "forward.fill")
                    }
                    .buttonStyle(PinguSecondaryButtonStyle())
                }

            case .completed:
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.84)) {
                        _ = questStore.activateSuggestedQuest(from: entry)
                    }
                } label: {
                    Label("Practice again", systemImage: "arrow.clockwise")
                }
                .buttonStyle(PinguSecondaryButtonStyle())

            case .skipped:
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.84)) {
                        _ = questStore.activateSuggestedQuest(from: entry)
                    }
                } label: {
                    Label("Make active again", systemImage: "flag.fill")
                }
                .buttonStyle(PinguPrimaryButtonStyle())
            }
        } else {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.84)) {
                    _ = questStore.activateSuggestedQuest(from: entry)
                }
            } label: {
                Label("Add to next actions", systemImage: "flag.fill")
            }
            .buttonStyle(PinguPrimaryButtonStyle())
        }
    }

    private var questStatusText: String {
        guard let quest = questStore.quest(for: entry) else {
            return "Not added to next actions"
        }

        switch quest.status {
        case .active:
            return "Active next action"
        case .completed:
            return "Completed"
        case .skipped:
            return "Skipped"
        }
    }

    private func deleteEntry() {
        journalStore.delete(entry, aiSessionStore: aiSessionStore)
    }
}

#Preview {
    NavigationStack {
        JournalEntryDetailView(entry: .preview)
    }
    .environmentObject(ReflectionJournalStore())
    .environmentObject(AIReflectionSessionStore())
    .environmentObject(QuestStore())
    .environmentObject(CircleStore())
}
