# CircleU content standard

24 October 2026. Draft writing standard requested by the owner; apply to new/revised prototype copy, then review before a production-wide copy pass. Existing screens have not all been updated. Product decisions live in the [MVP definition](../product/mvp-definition.md), visual rules in the [branding guideline](branding-guideline.md).

## Voice

Write plainly, warmly and briefly. Respect adults dealing with difficult conversations. Describe an action or useful outcome; avoid motivational filler, exaggerated praise, clinical claims and pressure to share or act. Pingu supplies warmth without making functional language childish.

Use sentence case for CircleU-authored headings, buttons and labels. This is a deliberate project style, including Log in and Sign up; it is not a claim that Apple's button guidance prescribes sentence case. Keep system-provided interface text unchanged.

## Punctuation and length

| Element | Rule | Preferred example |
| --- | --- | --- |
| Heading or tagline | Short phrase, no terminal full stop | Find your words |
| Button | Clear action, normally 1–3 words; no full stop | Sign up · Log in · Save reflection |
| Tab or field label | Short noun/phrase, no full stop | Journal · Email · Password |
| Helper/body | One useful sentence where possible; normal punctuation for complete sentences | Your changes haven't been saved. |
| Validation/error | State the issue and useful next action; complete sentences use punctuation | Enter your email address. |
| Question | Use a question mark when asking a real question | Discard your changes? |
| Progress | Name actual ongoing work; ellipsis only while work is underway | Saving… |

Do not add a full stop merely to make a headline feel polished. Do not remove punctuation from explanations that need complete sentences. Avoid exclamation marks, all caps and decorative ellipses. Length targets guide editing; never truncate meaning, accessibility text or translated content to meet them.

## Shared terms

| Use | Meaning / avoid |
| --- | --- |
| CircleU | Exact product spelling |
| Today / Journal / Practice | Approved destination names |
| Reflection | A saved reflection, distinct from original words and a suggested interpretation |
| Practice a message | Preparing wording; it never implies sending it |
| Save / Copy | Separate actions; copying does not save an entry |
| Log in / Sign up / Log out | Account actions; avoid mixing Login, Sign in and Log in in the same flow |
| Recover earlier data | An explicit, ownership-checked recovery operation; logging in alone is not an import |
| Find your words | Communication in the user's own voice; Find the word sounds like vocabulary lookup |

Use Australian English in prose, including practise as a verb. Keep the approved Practice destination label. Preserve users' own writing without rewriting it to match house style.

## Artwork and accessibility

The Welcome illustration can communicate reflection and conversation. Use one clear scene rather than repeating the same message in artwork, a heading and a paragraph. Keep Find your words as live, scalable text if it appears visually within the composition; do not bake essential copy into a PNG. This is our accessibility/localization design recommendation.

Keep the accepted Plus Jakarta Sans family and blue/ice/ink palette. New copy must support Dynamic Type and meaningful VoiceOver order. Label controls with text; illustration alone cannot explain an unfamiliar action. Hide decorative scene layers from accessibility; describe meaningful content without repeating adjacent text.

## Truthful state and data copy

- Show Saved, Account created, Copied or Deleted only after the relevant operation succeeds. A static prototype is not evidence of a real outcome; keep review limitations outside depicted product screens.
- Required accounts do not imply journal sync, automatic restore, remote generation or guaranteed recovery. Describe only the reviewed and verified data flow.
- Move detailed privacy/storage explanations to the account/data-use context and Settings, with access before submitting information. Removing a Welcome banner must not remove those explanations.
- Distinguish local entry deletion, account deletion and previous cloud-data deletion. Preserve error/retry information, source ownership and recovery choices.
- No Sample, Demo, placeholder instructions, debug details or review notes in product copy. Invented scenarios and fixture limitations belong in review documentation.
- Suggestions are tentative and editable. Avoid diagnoses, claims about another person's motives and certainty the app cannot establish.

## Review before accepting copy

Read the screen at normal and larger text sizes: one clear purpose, explicit actions, no duplicated helper, no unexplained icon, consistent terms and accurate outcome/privacy claims. Check empty, loading, validation and error states, not only the happy path. Keep approved strings near their feature for now; a production String Catalog and a complete copy inventory belong to the implementation plan, not this documentation change.

## References

Apple's [Writing guidance](https://developer.apple.com/design/human-interface-guidelines/writing) supports concise, consistent language and a shared vocabulary. Its [Alerts guidance](https://developer.apple.com/design/human-interface-guidelines/alerts) distinguishes fragments from full sentences and recommends specific action labels. Apple's component guidance includes title-case conventions; CircleU's sentence-case choice is a documented house-style adaptation. The live-text recommendation supports later [localization](https://developer.apple.com/localization/) and accessibility work; it does not establish that either has been validated.
