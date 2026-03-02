## Summary
- What problem does this PR solve?
- Which screen(s)/component(s) are affected?

## UI Change Scope
- [ ] posts/index
- [ ] posts/show
- [ ] layout/header/mobile bar
- [ ] forms
- [ ] onboarding/legal
- [ ] other:

## Design System Audit
- [ ] One primary CTA per section/screen context
- [ ] No competing CTA between fixed bar and in-page task UI
- [ ] Card hierarchy follows `Title > Summary > Primary meta > Secondary meta`
- [ ] Badge semantics are consistent (`active / inactive / informational`)
- [ ] Empty/zero/error states have a single emphasized next action
- [ ] Disabled states include explicit reason text
- [ ] Loading/success/error states use shared UI rules
- [ ] Focus-visible is clear on all interactive controls
- [ ] Dynamic UI changes are announced where needed
- [ ] Mobile tap target size is >=44px
- [ ] Section/block/component spacing rhythm is preserved
- [ ] Ads use `ad-slot-surface` and `ad-slot-label` rules

## Metrics Hypothesis
- Primary KPI:
- Expected direction:
- Guardrail metric:
- Event(s) to verify:

## Accessibility Notes
- Keyboard flow checked (Tab/Shift+Tab/Esc):
- Screen reader read order checked:
- Error-field association checked:

## Required Audit Record
- CTA count / hierarchy result:
- Empty / zero / error state result:
- Loading / disabled reason result:
- Mobile interference result:

## Testing
- [ ] Manual verification on desktop
- [ ] Manual verification on mobile viewport
- [ ] Locale switch layout verification (ja/en)
- [ ] Relevant automated tests updated/passed

## Screenshots / Recordings
- Before:
- After:
