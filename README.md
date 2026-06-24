# 🌌 CircleU — Privacy-First Reflection & Support Circles

[![Swift Version](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![iOS Version](https://img.shields.io/badge/iOS-17.0%2B-blue.svg)](https://developer.apple.com/ios)
[![Platform](https://img.shields.io/badge/Platform-iPhone-lightgrey.svg)](https://apple.com)
[![Firebase](https://img.shields.io/badge/Backend-Firebase-yellow.svg)](https://firebase.google.com)

> **Transforming raw thoughts into actionable insights. Securely. Collaborative. Private.**

**CircleU** is a premium, privacy-first iOS journaling and reflection companion. Designed to bridge the gap between daily emotional check-ins and personal growth, it allows users to record spoken reflections, receive real-time AI-assisted emotional analysis, commit to active wellbeing challenges, and safely share support updates within trusted spaces ("Circles"). 

---

## 📸 App Experience

| 🎤 Reflect | 🧠 Insight | 📔 Private Journal |
| :---: | :---: | :---: |
| ![Reflect](docs/product/snapshots/app-store/01-reflect-in-your-own-voice.png) | ![Insight](docs/product/snapshots/app-store/02-turn-check-ins-into-insight.png) | ![Journal](docs/product/snapshots/app-store/03-save-your-private-journal.png) |
| *Speak your mind with microphone-integrated voice check-ins and speech-to-text fallbacks.* | *Translate transcriptions into actionable emotional summaries, quotes, and quests.* | *Curate your local journal entries with tags, emotions, and personal annotations.* |

| 🎯 Growth Quests | 👥 Secure Circles |
| :---: | :---: |
| ![Quests](docs/product/snapshots/app-store/04-practice-one-small-step.png) | ![Circles](docs/product/snapshots/app-store/05-share-support-with-circles.png) |
| *Practice relationship-focused tips with real-time coaching feedback.* | *Share selected support posts securely inside firewalled Firestore-backed group circles.* |

---

## ✨ Core Pillars & Features

### 🎙️ 1. Ambient Voice Reflection
* **Speech-to-Text Integration**: Leveraging Apple's native `Speech` framework for instant local transcription, paired with a reliable typed keyboard fallback.
* **Low-Signal Resilience**: Built-in fallback engines to gracefully process fragmented speech or rough inputs, providing comforting local responses under offline or network-limited states.

### 🧠 2. AI Emotional Insights
* **Cognitive Extraction**: Distills spoken streams into primary emotions, summary cards, and inspirational quotes using standard LLM schemas and Apple Intelligence frameworks.
* **Suggested Quests**: Dynamically generates bite-sized daily relationship and communication challenges based on the user's reflection transcript.

### 👥 3. Secure Support Circles
* **Privacy-First Design**: Users have full control over what leaves their device. Insights are kept local unless explicitly shared with a circle.
* **Collaborative Spaces**: Share, like, bookmark, and reply to posts in shared circles. All circle memberships are gated via secure, identity-aware Firestore database rules.

### 🔒 4. Local-First Synchronization
* **Automatic Cloud Sync**: Fully authenticated data model backups across devices using Firebase Authentication and encrypted Firestore synchronization.
* **Data Sovereignty**: Complete "Delete Account" flow that purges the entire Firebase Authentication record, resets local device stores, and purges all Firestore backup collections.

---

## 🛠️ Technical Stack & Architecture

```text
Circleu/
├── App/                 # App initialization, main coordinators, dependency injection
├── Assets.xcassets/     # Styling assets, color tokens, and app icon assets
├── Components/          # Reusable UI elements, premium button configurations, haptics
├── Design/              # Global spacing, layout tokens, and typography definitions
├── Engines/             # Core business rules, reflection logic, local fallback logic
├── Features/            # Workflows grouped by domain (Journal, Profile, Onboarding, Circles)
├── Models/              # Codable domain structures, persistence-friendly schemas
├── Services/            # Device API boundaries (Firebase Auth, Firestore, Speech)
└── Stores/              # ObservableObject state managers holding local cache bindings
```

* **Frontend Framework**: SwiftUI
* **Database & Auth**: Firebase Authentication & Cloud Firestore (NoSQL)
* **Media & Processing**: `AVFoundation` for low-latency recording & `Speech` for speech-to-text transcription
* **Concurrency Model**: Modern Swift Concurrency (`async/await`) with `@MainActor` thread-safe UI bounds

---

## 🚀 Getting Started

### Prerequisites
* macOS Sonoma or later
* Xcode 15.0+ (iOS 17.0+ SDK)
* Cocoapods or Swift Package Manager (dependencies resolve automatically in Xcode)

### Setup & Run
1. Clone the repository:
   ```bash
   git clone git@github.com:tuannm3812/CircleU.git
   ```
2. Open `Circleu.xcodeproj` in Xcode.
3. Configure the active target:
   * Target Scheme: `Circleu`
   * Target Device: `iPhone 17 Pro` Simulator (or a physical test device running iOS 17+)
4. Click **Run** (`⌘R`).

> [!NOTE]
> The application uses a local fallback mode if a valid `GoogleService-Info.plist` is not found, allowing offline testing of all local journaling, speech-to-text, and AI insight modules. For cloud-synced test runs, place your team's `GoogleService-Info.plist` into the `Circleu/App/` folder.

---

## 🧪 Unit Testing

We maintain high coverage across auth stores, persistence syncing, and local fallback engines. To run the test suite:

```bash
xcodebuild test \
  -project Circleu.xcodeproj \
  -scheme Circleu \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

---

## 📜 License & Project Direction
CircleU is developed as a production-grade beta application for the UTS Tech Festival. 

For inquiries regarding the tech stack or demo details, contact [feitconnect@uts.edu.au](mailto:feitconnect@uts.edu.au).
