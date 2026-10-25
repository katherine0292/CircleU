import SwiftUI
import UIKit

/// One of the 21 Pingu avatars from the brand collection.
struct GuestAvatar: Identifiable, Equatable {
    /// The asset name, also what's stored as the choice.
    let id: String
    /// What VoiceOver says, e.g. "Pingu with a warm drink".
    let name: String
}

/// The avatar collection (Codex brand artwork, Collection 01 and Activities/Expansion poses), and
/// the person's choice, kept on this iPhone only. Mascot poses, never moods or rewards.
enum GuestAvatars {
    static let all: [GuestAvatar] = [
        GuestAvatar(id: "GuestPinguJournal", name: "Pingu holding a journal"),
        GuestAvatar(id: "GuestPinguWelcome", name: "Pingu waving hello"),
        GuestAvatar(id: "GuestPinguThoughtful", name: "Pingu thinking"),
        GuestAvatar(id: "GuestPinguListening", name: "Pingu listening"),
        GuestAvatar(id: "GuestPinguWriting", name: "Pingu writing"),
        GuestAvatar(id: "GuestPinguReading", name: "Pingu reading"),
        GuestAvatar(id: "GuestPinguPractising", name: "Pingu practising what to say"),
        GuestAvatar(id: "GuestPinguStretching", name: "Pingu stretching"),
        GuestAvatar(id: "GuestPinguQuietBreath", name: "Pingu taking a quiet breath"),
        GuestAvatar(id: "GuestPinguHeart", name: "Pingu holding a heart"),
        GuestAvatar(id: "GuestPinguIceCream", name: "Pingu with an ice cream"),
        GuestAvatar(id: "GuestPinguBackpack", name: "Pingu with a backpack"),
        GuestAvatar(id: "GuestPinguThumbsUp", name: "Pingu giving a thumbs up"),
        GuestAvatar(id: "GuestPinguExplorer", name: "Pingu exploring"),
        GuestAvatar(id: "GuestPinguRunning", name: "Pingu on the move"),
        GuestAvatar(id: "GuestPinguMusic", name: "Pingu listening to music"),
        GuestAvatar(id: "GuestPinguLaptop", name: "Pingu at a laptop"),
        GuestAvatar(id: "GuestPinguGardening", name: "Pingu gardening"),
        GuestAvatar(id: "GuestPinguWarmDrink", name: "Pingu with a warm drink"),
        GuestAvatar(id: "GuestPinguSleeping", name: "Pingu sleeping"),
        GuestAvatar(id: "GuestPinguPillowHug", name: "Pingu hugging a pillow"),
    ]

    static let defaultID = "GuestPinguJournal"
    /// A new key, separate from every legacy UserDefaults key. Delete all resets it.
    static let storageKey = "circleu.guest.avatar.v1"

    static func avatar(id: String) -> GuestAvatar {
        all.first { $0.id == id } ?? all[0]
    }

    static func reset(defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: storageKey)
    }
}

/// A decorative Pingu: hidden from VoiceOver and left out at the largest text sizes, where the
/// space is better used for words.
struct GuestPinguDecoration: View {
    let asset: String
    var height: CGFloat = 140
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        if !typeSize.isAccessibilitySize {
            Image(asset).resizable().scaledToFit()
                .frame(maxWidth: .infinity).frame(height: height)
                .accessibilityHidden(true)
        }
    }
}

/// An illustrated brand icon at icon size, for labels that already say what it means.
struct GuestBrandIcon: View {
    let asset: String
    var size: CGFloat = 26

    var body: some View {
        Image(asset).renderingMode(.original).resizable().scaledToFit()
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

/// A Pingu with a short line, for empty and no-results states.
struct GuestPinguMessage: View {
    let asset: String
    let text: String
    var height: CGFloat = 130

    var body: some View {
        VStack(spacing: 12) {
            GuestPinguDecoration(asset: asset, height: height)
            Text(text).multilineTextAlignment(.center).foregroundStyle(GuestBrand.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}

/// A brief "Saved" moment with a small Pingu; announced for VoiceOver, then it goes. The default
/// pose is a neutral wave, so it never reads as approval of what was written.
struct GuestSuccessBanner: View {
    let text: String
    var asset = "GuestPinguWelcome"
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        HStack(spacing: 12) {
            if !typeSize.isAccessibilitySize {
                Image(asset).resizable().scaledToFit().frame(width: 44, height: 44).accessibilityHidden(true)
            }
            Text(text).font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(GuestBrand.ink)
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(.white, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: GuestBrand.ink.opacity(0.08), radius: 8, y: 2)
        .accessibilityElement(children: .combine)
        .onAppear { UIAccessibility.post(notification: .announcement, argument: text) }
    }
}

/// The avatar shown on Today and in Settings; tapping it opens the picker.
struct GuestAvatarButton: View {
    @AppStorage(GuestAvatars.storageKey) private var avatarID = GuestAvatars.defaultID
    var size: CGFloat = 180
    @State private var picking = false
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        let avatar = GuestAvatars.avatar(id: avatarID)
        Button { picking = true } label: {
            Image(avatar.id).resizable().scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: typeSize.isAccessibilitySize ? min(size, 96) : size)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Your Pingu: \(avatar.name)")
        .accessibilityHint("Choose a different Pingu.")
        .sheet(isPresented: $picking) { GuestAvatarPicker(selection: $avatarID) }
    }
}

struct GuestAvatarPicker: View {
    @Binding var selection: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 12)], spacing: 12) {
                    ForEach(GuestAvatars.all) { avatar in
                        let isSelected = avatar.id == selection
                        Button {
                            selection = avatar.id
                        } label: {
                            Image(avatar.id).resizable().scaledToFit()
                                .padding(8)
                                .frame(maxWidth: .infinity).frame(height: 104)
                                .background(.white, in: RoundedRectangle(cornerRadius: 18))
                                .overlay(RoundedRectangle(cornerRadius: 18)
                                    .stroke(isSelected ? GuestBrand.blue : .clear, lineWidth: 3))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(avatar.name)
                        .accessibilityAddTraits(isSelected ? .isSelected : [])
                    }
                }
                .padding(20)
            }
            .background(GuestBrand.ice.ignoresSafeArea())
            .navigationTitle("Choose your Pingu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
    }
}

// MARK: - Copy helpers (docs/design/screen-content-guidelines.md)

/// A collapsed "Learn more" for detail that honesty needs but the screen doesn't. Smaller
/// secondary text that still scales with Dynamic Type.
struct GuestLearnMore<Content: View>: View {
    var title = "Learn more"
    @ViewBuilder let content: () -> Content
    @State private var isOpen = false

    var body: some View {
        DisclosureGroup(isExpanded: $isOpen) {
            VStack(alignment: .leading, spacing: 6) { content() }
                .font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
        } label: {
            Text(title).font(GuestBrand.font(.footnote, .semibold)).foregroundStyle(GuestBrand.blue)
        }
        .tint(GuestBrand.blue)
    }
}

/// The one-line summary under a section heading: smaller, secondary, Dynamic Type.
struct GuestSummary: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text).font(GuestBrand.font(.subheadline)).foregroundStyle(GuestBrand.muted)
    }
}
