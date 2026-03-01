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

## Fixed Mobile Bar Rules
- Use `mobile-sticky-bar` for all fixed bottom action bars.
- When fixed bars overlap critical inputs (comment forms), hide the bar while input fields are focused.
- Keep a minimum `44px` tap target (`tap-target`) on all touch controls.

## Card Layout Rules
- Information order:
  - `Title -> Summary -> Tags -> Meta`
- Card height rhythm:
  - Keep consistent thumbnail height (`h-40`/`h-44`) to avoid scroll jitter.
- Tags:
  - Show max 2 tags and aggregate overflow as `+n`.
  - Use low-emphasis chip tone for tags to reduce visual noise.

## States
- Empty states must include:
  - Context sentence
  - Next action CTA
- Search zero-results must include:
  - "Clear all" action
  - At least one condition-relax action

## Accessibility Rules
- All interactive controls must expose visible focus style (`:focus-visible`).
- Announce asynchronous status changes (copy success/failure, menu open/close) through the live region.
- Menus and toggles must keep `aria-expanded` synchronized with UI state.

## New Screen Checklist
- [ ] One primary CTA per section
- [ ] Heading/body/meta typography classes applied
- [ ] Empty/zero/error states have explicit next-step CTA
- [ ] Touch targets are `>=44px`
- [ ] Keyboard focus is visually clear on all controls
- [ ] Screen reader status feedback exists for dynamic actions
- [ ] Mobile fixed bars do not cover key inputs
