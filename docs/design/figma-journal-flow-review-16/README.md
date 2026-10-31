# Journal flow review 16

31 October 2026. Prototype repair and verification only; no native changes.

[Open the prototype](https://www.figma.com/proto/rfknpmLIXsOxA7fHUQQMtR/CircleU-Design--from-Claude-canvas-?node-id=74-210&starting-point-node-id=74%3A3&scaling=scale-down&content-scaling=fixed). Page `74:2`: **CircleU • connected review 16**.

## Repairs

- Search previously showed an empty result before a new Today entry was saved. It now uses the existing walk entry, including its current words and tags. Tap the query to switch between the `walk` result and the `weekend` empty fixture.
- Calendar 31 October previously showed two dots with only one entry. The second dot now follows the new-entry saved state across all 31 October calendar frames.
- Three discard screens displayed the deadline draft instead of their respective entry. Each now matches its editor.
- Editor tabs bypassed discard confirmation. Back and tab exits now ask before leaving; Discard continues to the requested destination, while Keep editing returns to the editor.

Transparent Codex Pingu artwork from [review 15](../figma-transparent-artwork-review-15/README.md) is retained. No image generation, Weave operation or Figma AI-credit generation was invoked for this pass.

## Checks performed in the Figma player

| Journey | Observed result |
| --- | --- |
| Search before a new save | Existing walk entry visible |
| Query toggle | `weekend` empty state and `walk` result reachable |
| Search → entry → Study + Overloaded → Done → edit → Save → Back | Same search result retained updated tags and predefined replacement text |
| Calendar → 29 October → work entry → Edit → Back | Correct work draft shown in discard confirmation |
| Keep editing → Practice tab → Discard | Confirmation shown before navigating to Practice |
| Calendar → 31 October → entry → Back | Selected date and edited entry retained |
| Calendar → 30 October | “Nothing written that day.” shown |
| Next month → Go to today → list | November empty month, October 31 and Journal list reachable |
| Today → write fixture → Save → calendar | One dot/count became two; both entries reachable by scrolling, tab bar stayed fixed |

Structural audit after all repairs: 125 screen/state frames, no missing navigation destinations, no tab-position mismatches. Audit checks target existence and placement, not every semantic route.

Evidence: [search export](search.png), [edited search result](search-edited.jpg), [calendar return](calendar-return.jpg), [two entries](calendar-two-entries.jpg), [scrolled calendar](calendar-scrolled.jpg).

## Review checklist

- [ ] Owner reviews Journal density, compact context chips and labelled feeling artwork.
- [ ] Owner tries search → entry → tags → edit → Back.
- [ ] Owner tries an editor tab exit and Keep editing / Discard.
- [ ] Review Today capture, drafts, save/retry and optional reflection next.
- [ ] Scope native integration separately after design review.

This prototype uses fixed queries, predefined text changes and session variables. It does not demonstrate arbitrary search/input, durable storage, actual AI or native accessibility. Not all dates, tag combinations, tab-exit variants or errors were exercised. No Xcode build, unit/UI suite, Dynamic Type or physical VoiceOver check was run this turn.

## Implementation evidence

[Search/calendar repair](repair-search-calendar.js) and [editor-exit repair](repair-editor-exits.js) are records of one-time applied mutations, not idempotent utilities. Do not rerun blindly. New search card: `106:449`; editor-exit variable: `VariableID:108:453` (`journalEditorExit`, 0 entry, 1 Today, 2 Journal, 3 Practice). Existing frames, fonts, artwork and navigation structure were preserved.
