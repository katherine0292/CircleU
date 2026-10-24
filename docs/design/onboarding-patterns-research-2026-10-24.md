# Mobile onboarding, content and type research

24 October 2026. Desk research and a local prototype refinement requested by the owner. Recommendations below are design proposals, not a usability study or approval to change production behavior. The accepted Pingu artwork, palette and Plus Jakarta Sans remain the baseline. The [MVP definition](../product/mvp-definition.md) still owns feature scope.

## Evidence and limits

Reviewed publisher documentation and public product pages for Headspace, Day One, How We Feel and Finch. These are relevant established examples, not a verified popularity ranking. No apps were installed, accounts created, trials purchased or private content submitted. Published help flows can differ from a current first launch by version, region or experiment. Where an exact onboarding sequence was not established, the table says so. Public marketing screenshots are not evidence of a tested first-launch flow.

| App / primary evidence | What the published experience presents | Implication for CircleU — our interpretation |
| --- | --- | --- |
| [Headspace product introduction](https://www.headspace.com/app) | Leads with everyday benefits, then groups meditation, sleep and guided programs. This establishes the public introduction/library structure, not the exact current onboarding sequence. | Explain the conversation benefit before describing machinery. Today needs a small set of relevant actions; a broad wellness library would dilute the approved purpose. |
| [Day One entry creation](https://dayoneapp.com/guides/day-one-ios/creating-entries-in-day-one-for-ios/) and [account setup](https://dayoneapp.com/guides/getting-started-with-day-one/creating-a-day-one-account/) | A prominent add action opens writing; media choices recede when typing begins. Calendar dates offer routes into entries. Accounts support its sync service; these guides do not establish every initial welcome screen. | Make starting and retrieving an entry clear. Let writing dominate the editor. CircleU's guest-first plan does not require copying its sync/account setup. |
| [How We Feel check-in explanation](https://howwefeel.substack.com/p/ch-ch-ch-changes) | The team's historical explanation makes additional check-in steps optional and saved details editable. It also reports feedback asking for faster, less pressuring check-ins. This is older published behavior, not a fresh install audit. | Save a useful reflection without requiring Practice, a next step or a long intake. Keep correction discoverable. |
| [How We Feel Today preview](https://howwefeel.substack.com/p/what-comes-next), 23 July 2026 | Proposes a weekly calendar and contextual cards after check-in. The team explicitly describes it as an iOS test that may change. | A contextual next action can help, but this beta is not evidence for adding a dashboard, streaks or social cards to CircleU. |
| [Finch character setup](https://help.finchcare.com/hc/en-us/articles/37779580853005-Creating-Your-Birb) and [new-user guide](https://help.finchcare.com/hc/en-us/articles/42149821015693-New-User-Guide) | Character color/name/pronouns/trait and personal setup precede a walkthrough; starter goals on Home introduce its pet/adventure loop. | A mascot gives continuity. CircleU can use Pingu on Welcome and empty states while keeping personalization, goals-as-rewards and adventures outside this MVP. |

[Apple's onboarding guidance](https://developer.apple.com/design/human-interface-guidelines/onboarding) recommends brief onboarding, learning through actions, postponing nonessential setup and asking for permissions when the relevant feature is used. This supports our existing single-welcome proposal; it does not prove it will work for our audience.

## Recommendation and alternatives

Retain one Welcome → safe workspace opening → Today, with optional Privacy and earlier-data recovery. Explain capture, correction and Practice at the moment they are used. A three-page feature tour would add reading and repeat the tabs. A personalized intake could tailor an experience later, but currently collects information without a defined use. Neither is justified by this research.

The owner already requested a concise Pingu prototype and approved an isolated motion comparison. This pass revises that review material only. Detailed copy and motion comfort still need owner feedback; no production feature implementation is authorized by this record.

## Content contract and proposed copy

Use a concrete heading, at most one short helper and visibly named actions. This is a working constraint, not a word-count rule for private entries, errors or privacy information. Icons support recognition; retain labels for primary actions, unfamiliar concepts and error recovery. Preserve the calendar's icon-free month header.

| Screen | Proposed visible content | Keep / defer |
| --- | --- | --- |
| Welcome — applied locally | **Find your words.** “Reflect on a difficult conversation. Practise what to say next.” **Get started** | Keep Saved on this device, the deletion/sync warning, optional Privacy & data and Used CircleU before? No tour, questionnaire or permission prompt. |
| Privacy — applied locally | Four short sections: **Saved here**, **Backups & recovery**, **Export & delete**, **Optional voice** | Preserve on-device availability/manual fallback, no CircleU cloud AI/sync, device-backup limits, exported-copy limits and explicit voice permission. Keep earlier-data management reachable. |
| Earlier data — applied locally | **Your earlier words.** “Choose whether to bring earlier CircleU entries into this space.” **Review earlier data** / **Continue without importing** | Keep no automatic import/erasure, later access and separate account recovery that may require internet/sign-in. No real import is simulated as complete. |
| First Today — applied locally | **What’s on your mind?** **Work through a moment** / **Practice a message** | Remove the repeated explanatory paragraph. Keep Today / Journal / Practice and no fabricated history. Onward links remain existing Figma wireframes. |
| Capture — proposal only | **What happened?** “Start with one moment.” **Record** / **Save my words** | Keep typing primary and reflection generation a separate explicit choice. Permissions and capability help appear when needed. Do not remove draft/validation feedback. |
| Reflection — proposal only | **A possible reading**; concise summary, tentative feeling/need, one useful question | Retain original words, edit/reject and words-only save. Shorten instructional chrome, not the user's account. |
| Practice context — proposal only | **What would you like to say?** “Add the situation and what you want to change.” | Optional existing draft; compact goal/tone choices. Show selected source context only for a linked reflection. No duplicate reflection review. |
| Wording / message editor — proposal only | **Your message**; one editable option initially; **Copy message** / **Save practice** | First-use note: “Nothing is sent.” Copy and Save remain distinct. Retain stale-source, unsaved-edit and failed-copy/save states. |
| Journal — proposal only | **Journal**, Search, calm calendar and actual saved entries. Empty: **Your journal starts here.** “Saved reflections will appear here.” | No streak labels, decorative calendar icon, fake first-run entries or duplicate open buttons. Date/search interaction decisions remain open. |
| Saved detail — proposal only | Entry title/date and saved content; contextual **Edit**, **Practice** and options | Inline Saved feedback; no separate success page. Keep export/delete scope and recoverable failure explanations. |

Loading and error copy is intentionally not compressed merely to meet a visual target. Opening, locked storage and read failure retain their meaning, retry/cancel routes and preservation assurances. Release copy must match verified runtime behavior; the current app still contains Firebase/account/cloud paths.

## Font audit

Inspected the actual [bundled font](../../Prototypes/CircleUVisualPrototype/Sources/CircleUVisualPrototype/Resources/BrandFonts/PlusJakartaSans.ttf) with `fontTools.ttLib.TTFont`, not just its filename. The 176,288-byte file identifies as Plus Jakarta Sans Regular, PostScript `PlusJakartaSans-Regular`, with a `wght` axis from 200 to 800 and default 400. Its metadata and the [bundled license](../../Prototypes/CircleUVisualPrototype/Sources/CircleUVisualPrototype/Resources/BrandFonts/OFL-PlusJakartaSans.txt) identify SIL OFL 1.1. The [designer's repository](https://github.com/tokotype/PlusJakartaSans) describes its geometric construction and open counters.

The font contains the test characters I/l/1, O/0, apostrophe, en/em dash, ellipsis and selected Vietnamese diacritics. This is a glyph-presence spot check, not a complete language, shaping or readability certification.

**Recommendation: keep Plus Jakarta Sans.** It provides a clean counterpart to the softly shaded Pingu; changing family is not needed to reduce text density. Normalize the local review to 400 body, 500 labels, 600 buttons/section headings and 700 titles. Use 17px body, 14px explanatory text and approximately 30px titles as review starting points. Reduce tightly negative title tracking from −1.15px to −0.7px. These choices require reading/size testing, not claims of universally better legibility.

Adoption is inconsistent: [BrandDemo.swift](../../Prototypes/CircleUVisualPrototype/Sources/CircleUVisualPrototype/BrandDemo.swift) registers the custom font in the isolated preview process; [PinguDesign.swift](../../Circleu/Design/PinguDesign.swift) and production onboarding still use system typography. Figma's last verified state uses Inter. The native demo uses `.custom(..., fixedSize:)`; this does not establish Dynamic Type support. CoreText's previously reported descriptor suffix `ExtraLight` alone does not establish a wrong bundled font or incorrect rendered weights. Native weight/scaling verification remains necessary before production adoption.

## Motion in the local review

Reuses the [approved isolated motion direction](motion-guideline.md): one whole-illustration greeting, 3° maximum tilt, 500ms total; short 180ms opacity changes on navigation. No input delay, endless bounce, confetti, fake progress, eye-blink deformation or new dependency. The greeting does not replay on every Welcome return; an explicit reviewer replay is available outside the phone. Editors remain still in the broader design proposal.

The local review checks `prefers-reduced-motion` and provides a reviewer Still preview option. Either disables decorative motion; the option cannot override the OS preference. Changes cancel active effects. Document hiding and leaving the viewport also cancel effects without automatic replay on return. No fabricated storage duration was added; outcomes remain selected externally.

Apple's [Reduced Motion criteria](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/reduced-motion-evaluation-criteria/) inform the fallback requirement. Our exact timings are project choices, not Apple requirements. A whole PNG tilt is a greeting treatment, not an articulated flipper animation.

## Delivered and next checks

Local conversation prototype `circleu-onboarding-review-v3.html` preserves v2, existing artwork/font originals, seven storage/navigation states and external Figma handoffs. It applies only Welcome/Privacy/Earlier-data/Today copy and finite review motion. Other screen rows above remain proposals. The inline fragment is stored in the task's durable visualization directory; repository docs record its content/contract, not a production implementation.

Browser checks: loaded images/font, 17px body/700 title, zero phone horizontal overflow at 390 CSS px; Welcome, Privacy, Earlier data and Today also fit a 320px browser viewport (phone measured 261–276px inside the host wrapper). Greeting transform changed after replay and later settled to `none`; Still preview disabled replay. Nested returns, deferral, completed-user read failure, retry-to-ready, locked retry and pending cancel/late-result gating were rechecked. Browser error logs were empty at the end. Responsive override was reset.

Limits: no fresh Figma edit (last known MCP quota blocked), native build, iOS interaction, physical-device test, real storage/recovery, participant comprehension study or motion-comfort finding. Reduced-motion OS changes and hidden/offscreen cancellation are source-reviewed, not lifecycle-tested here. Native Dynamic Type, VoiceOver, dark mode, long journal paragraphs and actual variable-weight rendering remain open.

Next owner walkthrough: explain CircleU's purpose in their own words; start without opening Privacy; explain storage/recovery limits; compare greeting with Still preview. Record actual confusion before refining other screens or authorizing production work.
