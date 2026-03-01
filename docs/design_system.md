# DeskTour Studio UI System

## Core Tokens
- Typography:
  - `ds-heading-xl`: Page titles
  - `ds-heading-lg`: Section titles
  - `ds-heading-md`: Card and subsection titles
  - `ds-text-body`: Main reading text
  - `ds-text-support`: Supporting explanation text
  - `ds-text-meta`: Metadata (date, small labels)
  - `ds-text-muted`: Helper or hint text
- Spacing:
  - `space-y-content`: Major section rhythm
  - `space-y-form`: Form field rhythm
- Surfaces:
  - `ds-card`: Standard card surface
  - `ds-shadow-soft`: Soft elevation
  - `ds-badge`: Compact metadata badge

## CTA Hierarchy
- `cta-primary`:
  - Main conversion action for the current context.
  - Keep to one primary per section whenever possible.
- `cta-secondary`:
  - Important but non-primary actions (navigation back, alternate action).
- `cta-tertiary`:
  - Utility actions (toggle, lightweight links, low emphasis controls).
- `cta-compact`:
  - Small variants for dense UI areas (chips, inline controls).
- Header rule:
  - Keep exactly one primary CTA in the desktop header action row.
  - Utility controls (language, preference toggles) must live in a separate utility group.

## Fixed Mobile Bar Rules
- Use `mobile-sticky-bar` for all fixed bottom action bars.
- When fixed bars overlap critical inputs (comment forms), hide the bar while input fields are focused.
- Keep a minimum `44px` tap target (`tap-target`) on all touch controls.
- If in-page CTA already owns the current task (for example, search submit), suppress competing fixed-bar CTA while that task UI is visible or active.

## Card Layout Rules
- Information order:
  - `Title -> Summary -> Primary meta -> Secondary meta`
- Card height rhythm:
  - Keep consistent thumbnail height (`h-40`/`h-44`) to avoid scroll jitter.
- Tags:
  - Show max 2 tags and aggregate overflow as `+n`.
  - Use low-emphasis chip tone for tags to reduce visual noise.

## Badge State Rules
- `active`:
  - Use `ds-badge-active` for currently applied filters or selected states.
  - Include an additional signal beyond color (icon/checkmark/weight).
- `inactive`:
  - Use `ds-badge-inactive` for selectable but not selected options.
- `informational`:
  - Use `ds-badge-info` for passive metadata chips.

## States
- Empty states must include:
  - Context sentence
  - One primary next action CTA
- Search zero-results must include:
  - One emphasized first action
  - Additional recovery actions as lower-emphasis links

## Accessibility Rules
- All interactive controls must expose visible focus style (`:focus-visible`).
- Announce asynchronous status changes (copy success/failure, menu open/close) through the live region.
- Menus and toggles must keep `aria-expanded` synchronized with UI state.
- Modal/menu behavior must be consistent:
  - Initial focus lands on the first actionable control.
  - `Esc` closes the layer.
  - Focus returns to the trigger after close.
- Anchor targets under sticky headers must use `scroll-margin-top` (`ds-anchor-offset`).
- Respect `prefers-reduced-motion`: disable non-essential animation and smooth scrolling.

## Typography And Rhythm
- Japanese UI optimization:
  - Prefer narrower reading columns and slightly larger paragraph rhythm in `lang-ja`.
  - Avoid over-compressing labels; prioritize scan speed over density.
- Spacing hierarchy:
  - `section > block > component` must use fixed rhythm scales (`space-y-section`, `space-y-block`, `space-y-component`).

## Ads Placement
- Wrap ad slots in a low-noise container (`ad-slot-surface`) with clear spacing from content groups.
- Add a compact disclosure label (`ad-slot-label`) to separate ads from primary content.
- Add a context separator before ad groups (`ad-slot-divider`) when placed between reading/comment sections.

## Responsive Density Rules
- Define information density by breakpoint:
  - Mobile: prioritize one-line metadata rows and collapsed secondary controls.
  - Tablet: allow 2-column cards and compact chips.
  - Desktop: expose utility menus and additional metadata only when they do not compete with the primary CTA.
- Prevent overflow in mixed Japanese/English labels with `ds-break-words` and explicit line-clamp rules.

## Component State Matrix
- Every interactive component must define and visually test:
  - `default`
  - `hover`
  - `focus-visible`
  - `disabled`
  - `loading`
- Components covered:
  - `cta-*`
  - `ds-badge-*`
  - form controls (`input/select/textarea`)
  - menus/dialog triggers

## Contrast Audit Flow
- Use WCAG 2.2 contrast checks as a required pre-merge gate for:
  - Body text
  - Meta text
  - CTA labels
  - Badge text and borders
- Keep contrast checks in PR artifacts:
  - Screenshot set (default + focus-visible + disabled)
  - Measured contrast values and pass/fail notes

## Media Loading And CLS
- Use explicit aspect-ratio wrappers for list/detail media (`ds-media-frame-*`).
- Image containers should render skeleton placeholders (`ds-media-skeleton`) until `load/error`.
- Keep width/height attributes on image tags to stabilize layout before decode.

## Dark Mode Readiness
- Maintain colors through `--ds-*` tokens only; avoid hard-coded semantic colors in component markup.
- Before dark mode rollout, classify:
  - Directly tokenized components (ready)
  - Mixed token/hard-coded components (needs migration)
  - Third-party embeds (non-themable constraints)
- Define minimum contrast targets per theme variant before enabling user toggle.

## Alt Text Guidelines
- Post images: descriptive, content-bearing alt text (setup context + key visual trait).
- Decorative icons: `aria-hidden="true"` and no redundant alt text.
- Informational icons inside controls: text label must remain understandable without icon.

## KPI-Driven Iteration Loop
- Track UI changes against measurable outcomes:
  - Search zero-result rate
  - Card-to-detail click-through rate
  - Comment completion rate
  - Share/copy action rate
  - Back-navigation recovery success (list position restore)
- PRs that change conversion-critical UI must include:
  - Hypothesis
  - Affected KPI(s)
  - Expected direction and guardrail metric

## Design Audit Workflow
- Pull requests that modify UI must complete a design-system checklist in the PR template.
- PR body must include explicit results for: CTA hierarchy, empty/zero states, focus visibility, and mobile fixed-bar interference.
- Reviewer must validate:
  - CTA count and hierarchy per screen
  - badge state semantics
  - empty/zero/error states
  - focus visibility and dynamic announcements
  - mobile fixed-bar conflicts with core interactions

## New Screen Checklist
- [ ] One primary CTA per section
- [ ] Heading/body/meta typography classes applied
- [ ] Empty/zero/error states have explicit next-step CTA
- [ ] Touch targets are `>=44px`
- [ ] Keyboard focus is visually clear on all controls
- [ ] Screen reader status feedback exists for dynamic actions
- [ ] Mobile fixed bars do not cover key inputs
- [ ] Badge states use active/inactive/informational roles consistently
- [ ] Section/block/component spacing rhythm is preserved
