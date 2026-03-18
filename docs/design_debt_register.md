# Design Debt Register

Date: 2026-03-02

| ID | Theme | Impact KPI | Difficulty | Dependencies | Target Date | Status |
|---|---|---|---|---|---|---|
| DD-001 | Full token migration for dark mode | readability / bounce rate | Medium | token map, snapshot tests | 2026-04-15 | Planned |
| DD-002 | Admin IA/breadcrumb parity | task completion time | Low | shared breadcrumb helper | 2026-03-25 | Planned |
| DD-003 | Report-queue automation backend | report resolution time | High | moderation service/controller | 2026-05-01 | Proposed |
| DD-004 | Saved posts server sync | return visit CTR | Medium | user auth/session design | 2026-05-15 | Proposed |
| DD-005 | Low-bandwidth image preset | LCP on 2g | Medium | variant strategy | 2026-04-30 | Planned |

## Rules
- Every new UI debt entry must include KPI + deadline.
- Re-prioritize weekly in design review meeting.
- Do not close debt items without measurable verification notes.

## 2026-03-07 UI/UX Batch

| ID | Item | Expected KPI | Guardrail KPI | Owner | Target Date | Done Condition | Status |
|---|---|---|---|---|---|---|---|
| UXR-001 | Index primary CTA single-path | search start rate | bounce rate | Product+Frontend | 2026-03-21 | Hero has one primary CTA and first/revisit panel exclusive rendering | Implemented |
| UXR-002 | Persistent applied-filter chips | search completion rate | zero-result rate | Product+Frontend | 2026-03-21 | Keyword/category/theme/tag chips are always visible and removable individually | Implemented |
| UXR-003 | Card interaction conflict reduction | card-to-detail CTR | mistaken tap estimate | Frontend | 2026-03-21 | Card explicit CTA reduced to one and save moved to icon toggle | Implemented |
| UXR-004 | Mobile action menu risk separation | report flow completion | accidental report open rate | Frontend | 2026-03-21 | Share and report are visually sectioned and report requires intent confirmation | Implemented |
| UXR-005 | First-visit quick start flow | first-session engagement | onboarding skip rate | Product+Frontend | 2026-03-21 | Popular tag quick chips + dismissible 3-step inline guide | Implemented |
| UXR-006 | Locale consistency and fallback audit | trust score proxy (return visits) | missing translation incidents | Frontend | 2026-03-28 | Primary navigation/index/detail/report strings moved to managed locale keys | Implemented |
| UXR-007 | Unified live announcements | keyboard/search/save task success | duplicate toast rate | Frontend | 2026-03-21 | Save/filter/result updates announce through one live region path | Implemented |
| UXR-008 | KPI-first rollout governance | decision cycle lead time | rollback frequency | Product | 2026-03-14 | Every UXR entry defines expected KPI + guardrail + DoD before rollout | Implemented |
| UXR-009 | Post form input load reduction | post start-to-submit conversion | form abandonment rate | Frontend | 2026-03-28 | Required-first step flow + image recommendation copy + confirm step | Implemented |
| UXR-010 | Proactive validation | first-pass form success | validation error loops | Frontend | 2026-03-28 | URL format validation is inline and blocking before confirm step | Implemented |
| UXR-011 | Perceived loading feedback | search submit completion | premature back navigation | Frontend | 2026-03-21 | Search updating status indicator shown during submit | Implemented |
| UXR-012 | Detail information priority | detail read completion | ad interaction misclicks | Product+Frontend | 2026-03-28 | First view keeps title/image/summary emphasis and contextual sections below | Implemented |
| UXR-013 | Profile trust-signal enrichment | profile visit-to-follow proxy | profile bounce | Frontend | 2026-03-28 | User stats + category strength + creator index path added | Implemented |
| UXR-014 | Policy links in context | policy access from action flows | report/form drop-off | Frontend | 2026-03-21 | Post/report flows include inline policy links at decision points | Implemented |
| UXR-015 | Report feedback clarity | report completion confidence | duplicate report attempts | Product+Frontend | 2026-03-21 | Receipt ID + expected response window displayed after submission | Implemented |
| UXR-016 | Design-system governance gate | UI regression rate | review throughput | Design+Frontend | 2026-03-21 | Checklist and tokenized usage remain mandatory in PR review | Implemented |
| UXR-017 | Readability optimization | read completion rate | scroll depth drop-off | Design+Frontend | 2026-03-28 | Reading measure utility applied to long-form text | Implemented |
| UXR-018 | Empty/zero/error action consistency | recovery action CTR | dead-end state rate | Frontend | 2026-03-28 | Zero-state reason copy and explicit next-step CTA standardized | Implemented |
| UXR-019 | Feedback consistency | action confidence proxy | toast overlap rate | Frontend | 2026-03-21 | Toast dedupe and consistent severity timing applied | Implemented |
| UXR-020 | Navigation context preservation | detail-to-list continuation rate | reset-filter incidents | Frontend | 2026-03-21 | List scroll/filter restore behavior retained and observable | Implemented |
| UXR-021 | Motion discipline | task completion speed | motion-related opt-out | Frontend | 2026-03-28 | Motion tokens remain unified with reduced-motion fallback | Implemented |
| UXR-022 | Form draft resilience | draft recovery rate | stale-draft confusion | Frontend | 2026-03-28 | Draft TTL + manual clear action available in post form | Implemented |
| UXR-023 | Input modality parity | keyboard completion rate | mobile overflow defects | QA+Frontend | 2026-03-28 | Tap-target constraints and keyboard flows covered in system tests | Implemented |
| UXR-024 | Trust transparency labels | ad/report trust interactions | complaint rate | Product+Frontend | 2026-03-21 | Sponsored/UGC/report policy cues visible in detail and ad areas | Implemented |
