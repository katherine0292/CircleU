import SwiftUI

struct AboutView: View {

    var body: some View {

        ScrollView {

            VStack(spacing: 20) {

                heroCard

                missionCard

                featuresCard

                valuesCard

                acknowledgementsCard

                versionCard
            }
            .padding()
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Components

extension AboutView {

    private var heroCard: some View {

        VStack(spacing: 12) {

            PinguMascot(size: 90, mood: .thumbsUp)

            Text("CircleU")
                .font(.largeTitle.bold())

            Text("Reflect. Grow. Connect.")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(
                "A reflection companion designed to help people build social confidence through reflection, personalised insights, and supportive community experiences."
            )
            .multilineTextAlignment(.center)
            .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private var missionCard: some View {

        InfoCard(
            title: "Our Mission",
            icon: "target",
            content:
            "To help people reflect, grow, and connect with confidence."
        )
    }

    private var featuresCard: some View {

        VStack(alignment: .leading, spacing: 16) {

            Label(
                "What We Offer",
                systemImage: "sparkles"
            )
            .font(.title3.bold())
            .padding(.vertical, 12)
            
            FeatureRow(
                icon: "mic.fill",
                title: "Voice Reflection",
                description:
                "Capture thoughts and experiences naturally through your voice."
            )

            FeatureRow(
                icon: "brain.head.profile",
                title: "AI Insights",
                description:
                "Receive supportive reflections and personalised guidance based on your entries."
            )

            FeatureRow(
                icon: "leaf.fill",
                title: "Growth Tips",
                description:
                "Turn reflection into small, achievable actions."
            )

            FeatureRow(
                icon: "person.3.fill",
                title: "Community Support",
                description:
                "Learn from shared experiences and encourage others in a safe environment."
            )
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private var valuesCard: some View {

        VStack(alignment: .leading, spacing: 14) {

            Label(
                "Our Values",
                systemImage: "heart.fill"
            )
            .font(.title3.bold())
            .padding(.vertical, 12)

            ValueRow(
                emoji: "💙",
                title: "Reflection",
                description:
                "Growth starts with self-awareness."
            )

            ValueRow(
                emoji: "🤝",
                title: "Connection",
                description:
                "Meaningful relationships are built through understanding and empathy."
            )

            ValueRow(
                emoji: "🌱",
                title: "Growth",
                description:
                "Small steps can lead to lasting confidence."
            )

            ValueRow(
                emoji: "🛡",
                title: "Safety",
                description:
                "Users should feel supported, respected, and in control."
            )
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private var acknowledgementsCard: some View {

        VStack(alignment: .leading, spacing: 12) {

            Label(
                "Acknowledgements",
                systemImage: "hands.clap.fill"
            )
            .font(.title3.bold())
            .padding(.vertical, 12)

            Text(
                """
                Developed as part of the Apple Foundation Program at the University of Technology Sydney.

                Special thanks to our mentors, facilitators, testers, and every team member who contributed through design, development, research, testing, and storytelling.
                """
            )
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private var versionCard: some View {

        VStack(spacing: 8) {

            Text("Version 1.0.0")
                .font(.headline)
                .padding(.vertical, 12)

            Text("CircleU")
                .font(.subheadline)

            Text("Apple Foundation Program")
                .foregroundStyle(.secondary)

            Text("University of Technology Sydney")
                .foregroundStyle(.secondary)

            Text("2026")
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

// MARK: - Reusable Components

struct InfoCard: View {

    let title: String
    let icon: String
    let content: String

    var body: some View {

        VStack(alignment: .leading, spacing: 12) {

            Label(
                title,
                systemImage: icon
            )
            .font(.title3.bold())
            .padding()

            Text(content)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

struct FeatureRow: View {

    let icon: String
    let title: String
    let description: String

    var body: some View {

        HStack(alignment: .top, spacing: 12) {

            Image(systemName: icon)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {

                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct ValueRow: View {

    let emoji: String
    let title: String
    let description: String

    var body: some View {

        HStack(alignment: .top, spacing: 12) {

            Text(emoji)

            VStack(alignment: .leading, spacing: 4) {

                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    AboutView()
}
