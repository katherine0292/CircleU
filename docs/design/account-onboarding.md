# Artwork-led account onboarding

24 October 2026. **Owner-approved direction:** an account is required before entering CircleU; Welcome should be led by a larger Pingu scene with Log in and Sign up at the bottom. This replaces guest entry. **Proposed details below** are a review brief, not production authentication approval or an implemented prototype.

## Welcome composition

Keep the native phone layout and accepted logo, Plus Jakarta Sans and blue/ice/ink palette. Enlarge the upper illustration into the main visual area, with quiet space below for two actions. Start with the existing Pingu/journal artwork and sky/snow shapes. A new bespoke illustration is optional after checking that composition; no new asset, font or color family is selected here.

Recommended story: Pingu pauses with a journal and a simple conversation motif, communicating reflection before speaking. Avoid a busy collage, speech-bubble paragraphs or unrelated activity poses. If the image alone does not explain the purpose in a walkthrough, retain Find your words as one short live-text line within the composition, without a full stop. Do not bake lettering into artwork.

Lower actions, in order: primary **Sign up**, secondary **Log in**, using the existing rounded native control style. No Get started, Skip, guest entry, standalone storage banner or separate Used CircleU before? action on this Welcome. Both buttons must stay reachable at large text sizes and short heights; art yields space before controls shrink. Use scrolling when needed. Preserve predictable Back placement on subsequent screens.

Move the accessible Privacy and data link to both account forms, before submission, and later Settings. Explain authentication data on the forms; explain journal storage before the first reflection. The final wording depends on the actual data plan. Terms/privacy links must open without authentication. Keep recovery entry on Log in; it must remain reachable for previous users who cannot finish normal sign-in. These are proposed placements, not removal of recovery or privacy access.

## Approach and tradeoff

The previous guest-first screen offered immediate writing with storage/recovery messaging. Optional accounts would preserve that route but require a third Welcome choice. The owner explicitly chose required accounts and two Welcome actions instead. Account entry adds credentials/session recovery and connectivity states; it does not itself select cloud storage for private entries.

Recommendation: retain the local-first content/on-device/manual-fallback direction while separately defining authentication and account-scoped storage. Do not automatically restore Firebase content on login, merge existing local scopes, or assume the old and new app use the same identity project. Provider selection and cross-account/offline behavior need a reviewed specification before production work.

## Required account flow coverage

| Route/state | Review expectation |
| --- | --- |
| Welcome → Sign up | Clear form labels, accessible password controls, visible data explanation and a return to Welcome |
| Welcome → Log in | Existing-account form, Forgot password and earlier-data help, with Back to Welcome |
| Invalid or incomplete input | Inline useful explanation; preserve valid input and focus the affected field |
| Authentication in progress | Prevent duplicate requests, describe progress and handle cancellation/late completion truthfully |
| Wrong credentials, unavailable account, offline or service failure | Keep the form recoverable; no false authentication or empty-workspace success |
| Password reset / verification if required by chosen provider | Request, pending, retry, completion and expired-link states; exact policy still open |
| Authenticated → workspace readiness → Today | Only genuine authentication and successful readiness permit entry; failed/locked storage never becomes an empty Journal |
| Returning valid/expired session | Define resume and reauthentication without discarding drafts; offline unlock policy remains open |
| Legacy data | Login is distinct from an explicit source/ownership check, preview and recovery/import; preserve old data if it fails |
| Log out, account switch and deletion | Define draft handling, data isolation, reauthentication and cloud-deletion scope before implementation |

The existing standalone SwiftUI Welcome still shows the previous guest-first v07 design. Its successful button checks apply to that version. The new account flow has no implemented forms, real backend verification or native interaction evidence yet. No credentials should be entered into a static review specimen.

## Before updating the native prototype

1. Review this small visual/copy brief and the [content standard](content.md). Settle the account-form fields/providers by reusing the existing app's reviewed behavior where suitable, without importing Firebase into the isolated prototype.
2. Build an isolated visual/navigation specimen: account Welcome, Log in, Sign up, reset/error/progress states and preserved privacy/earlier-data routes. Make fixture behavior explicit in documentation; no fabricated account creation or storage success.
3. Render and inspect the normal and compact layouts, then check the selected iPhone 18 Pro in Xcode/Device Hub. Verify Back, form switching, keyboard, large text, scrolling and recovery access before Today.

This review does not authorize changing the production app, backend, bundle identity, signing, Apple distribution or existing user data. [Legacy recovery](legacy-recovery-flow.md) and the [transition plan](../superpowers/plans/2026-10-23-local-first-transition.md) retain their preservation requirements; their guest-only startup assumptions now need revision.
