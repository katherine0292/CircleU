# Refine the brand using the original app's layout

24 October 2026. **Owner direction:** the original app has the preferred proportions and layout; refinement should focus on color theme, concise content and new branding assets. Treat this as the layout baseline for subsequent design work. The accepted Pingu illustration style, Plus Jakarta Sans and blue/ice palette remain the brand reference. This review makes no app or Figma changes and does not authorize feature implementation.

## What the original teaches us

The original Welcome has been visually checked on the running iPhone 18 Pro/iOS 27.0 Simulator. The Home/Journal/Practice observations below come from source inspection; they have not all received a fresh visual walkthrough. Owner preference is a design decision, not a certification of every screen/device/accessibility state.

| Element | Concrete source evidence | Reuse decision |
| --- | --- | --- |
| Welcome composition | [Onboarding.swift](../../Circleu/Features/Onboarding/Onboarding.swift): one vertical stack with flexible space above/below the illustration/title group; actions form a separate lower group | Preserve the centered hero, breathing room and reachable action group. Size from the phone's available space. |
| Welcome proportions | Mascot frame 172pt, headline 32pt, illustration-to-title gap 32pt; helper constrained to 280pt width; main button 54pt tall, radius 18pt, side inset 32pt | These are measured source starting points for the comparison. New artwork/font must be assessed optically inside this hierarchy. Avoid enlarging the hero just because the replacement PNG has more transparent padding. |
| Main navigation | [RootView.swift](../../Circleu/App/RootView.swift): root `ZStack(alignment: .bottom)` contains the main content and one `PinguBottomTabBar` outside the selected screen | Retain a single navigation owner with stable placement. Apply the approved Today / Journal / Practice destinations when that behavior is implemented. |
| Tab geometry | [PinguComponents.swift](../../Circleu/Components/PinguComponents.swift): equal-width items; the shared bar has 16pt side inset and 20pt bottom padding | Reuse its visual balance as a reference. Reconcile with actual safe areas rather than repeating a bar independently in each screen. Three items must be assessed at the same baseline. |
| Content hierarchy | [HomeView.swift](../../Circleu/Features/Home/HomeView.swift): greeting → primary action card → supporting content in a ScrollView; [JournalView.swift](../../Circleu/Features/Journal/JournalView.swift): header → search → actual entries or empty state | Preserve a clear main action and scannable sections. Use the approved MVP content rather than importing all current sections into the new design. |
| Reading width | Home/Journal use 20pt side padding and 16pt section spacing; [TipsSetupView.swift](../../Circleu/Features/Tips/TipsSetupView.swift) uses the existing 22pt screen-side token and 20pt section gaps | Start with the established 20–22pt content rhythm. Avoid changing margin, type, art size and card density simultaneously. |
| Scrolling and actions | Home/Journal reserve 120pt at the bottom of scroll content; Practice setup reserves room for its bottom action/navigation | Keep the last item and focused input visible above controls. Validate actual bottom reservation against the eventual shared safe-area layout. |

The source also contains fixed top padding, duplicated token families and existing animations that need context-specific review. Reusing the layout means preserving its visual strengths while adapting to safe areas, keyboard and text size; it does not mean freezing every constant or certifying the old implementation unchanged.

## Why the newer boards felt different

[BrandTodayPreview](../../Prototypes/CircleUVisualPrototype/Sources/CircleUVisualPrototype/BrandDemo.swift) and [BrandHubPreview](../../Prototypes/CircleUVisualPrototype/Sources/CircleUVisualPrototype/BrandFlowPreview.swift) render fixed 390 × 844 boards with rounded clipping. Each board contains its own header/tab/footer composition. These served as visual specimens; inside a real phone Canvas they can clip or place navigation differently. The local HTML review is another separate composition.

Use those artifacts to select artwork, wording and color. Use the original native app to establish phone proportions and navigation ownership. Keep historical boards for comparison; do not treat their fixed outer frame as a production screen contract.

## What changes in the brand pass

| Area | Refinement within the original composition |
| --- | --- |
| Background and surfaces | Apply the accepted ice `#F5FAFF`, opaque reading surfaces and ink `#0D1421`. Preserve hierarchy and visual depth; assess a restrained version of the current glass treatment rather than adding effects everywhere. Original Welcome is dark; applying the accepted light reference changes its appearance, not its structural hierarchy. |
| Primary action and accents | Blue `#054FC9` for main actions and selection; sky/orange only as supporting brand accents. Check real text/control contrast in context. Reuse the existing design foundations during deliberate consolidation; do not introduce another competing token family. |
| Content | Welcome: **Find your words.** “Reflect on a difficult conversation. Practise what to say next.” Keep one main action. Use shorter helpers in existing slots; keep meaningful privacy, capability and failure messages. Detailed proposed copy remains in the [research record](onboarding-patterns-research-2026-10-24.md). |
| Pingu and icons | Use selected transparent originals from the [current asset library](brand-demo/asset-library.md) and [activity collection](brand-demo/pingu-collection.md). Fit visible character bounds to the existing illustration space; do not stretch, crop props or use a contact-sheet tile. Functional controls retain clear symbols and labels where meaning needs them. Calendar header stays free of extra decorative icons. |
| Typography | Retain Plus Jakarta Sans as the accepted candidate. Preserve title/body/action hierarchy while checking its different metrics and wrapping at phone size. Do not mechanically copy old 13–14.5pt helper sizes into every new surface. The guideline's 17pt body starting point and accessible scaling still need a real-layout comparison. Shorten UI text or allow flexible vertical space before shrinking type. |
| Motion | Apply the already reviewed brief greeting/transition direction only where useful. Keep navigation positions stable and writing surfaces still; honor Reduce Motion. Existing repeating mascot/timer behavior is not selected merely because the original layout is preferred. |

Layout selection does not restore deferred circles/rewards or approve automatic account/cloud behavior for the new MVP. The guest-first transition and legacy recovery requirements remain in the [MVP definition](../product/mvp-definition.md). A production privacy claim must match verified behavior.

## Proposed next review

Start with one native **Welcome** comparison using the original layout: retained silhouette/spacing/actions, accepted light palette, selected waving Pingu and concise copy. Keep an unchanged original reference and review both at the same phone, appearance and text size. This is the recommended next specimen, not a completed or approved implementation.

Then apply the accepted treatment to Today, Journal and Practice while retaining one navigation owner. The cute Journal calendar belongs inside the established content width; its extra height must scroll without moving the tab bar. Editors retain the original input/action balance with reduced explanatory chrome.

Check normal and larger text, compact/large phone widths, keyboard, long content, empty/loading/error states and reduced motion before broader adoption. Compare the tab bar's vertical position across destinations, final-item visibility and the visible artwork bounds. Use invented content and retain previous-user recovery routes. No third prototype application is needed.

## Evidence for this pass

Read the cited original and prototype source, accepted branding/motion/content decisions and prior Simulator launch record. Recorded owner preference and the fixed-frame/root-navigation differences. No new render, Simulator interaction, Figma write, Swift edit, asset change or automated app test in this documentation-only review. Previous build/test limitations remain in the [build-repair record](../qa/simulator-build-repair-2026-10-24.md).
