# Design Review Checklist

## Cadence
- Trigger: every new screen and every UI-affecting change.
- Format: one checklist record per PR.
- Required attendees: implementation owner + one reviewer.

## Required Checks
- CTA hierarchy: one primary action per section/screen context.
- State design: loading, success, error, empty, zero-results, disabled reason.
- Accessibility: keyboard flow, focus visibility, live region updates, heading structure.
- Metrics hypothesis: expected KPI impact + guardrail metric.
- Governance: link PR to a Design Debt ID (`UXR-*`) with owner/date/done-condition.

## Keyboard Completion Script
1. Traverse with `Tab` and `Shift+Tab` from page top to bottom.
2. Confirm visible `:focus-visible` on all interactive elements.
3. Open/close menus and dialogs using keyboard only.
4. Verify `Esc` closes layer and focus returns to trigger.
5. Verify post/report forms can be completed without pointer.

## Accessibility Read Order Script
1. Confirm one `h1` per page.
2. Validate heading order (`h1 > h2 > h3`) without skips.
3. Confirm error summaries are linked to relevant fields.
4. Confirm card metadata order matches visual order.

## PR Artifact Requirements
- Before/after screenshots (desktop + mobile).
- Run `ruby script/ui_screenshot_compare.rb` when baseline screenshots are configured.
- Run `ruby script/check_no_default_fallbacks.rb` for critical locale fallback audit.
- Checklist result notes for CTA/state/accessibility/metrics.
- Manual verification notes for keyboard and locale switch.
- KPI card with expected KPI, guardrail KPI, rollback trigger, and observation review date.
