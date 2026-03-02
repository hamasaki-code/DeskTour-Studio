# Dark Mode Migration Inventory

Date: 2026-03-02
Owner: UI backlog implementation

## Goal
Complete pre-migration inventory for dark mode by identifying hard-coded colors and prioritizing token migration.

## Priority Buckets
- P0 (high-frequency UI): header, navigation CTA, post cards, form controls, flash/toast, comment threads.
- P1 (medium-frequency UI): report modal, notifications page, profile screens, onboarding, ad wrappers.
- P2 (low-frequency UI): admin panels, legal pages, email templates.

## Current Status
- Tokenized baseline exists in `app/assets/tailwind/application.css` (`--ds-*` variables for typography, spacing, focus, skeleton).
- Hard-coded utility classes remain in ERB templates (`text-slate-*`, `bg-white`, `border-slate-*`, `text-blue-*`, etc.).
- Third-party embeds (`g-recaptcha`, AdSense) are non-themable and require neutral containers.

## Hard-coded Color Hotspots (Sample)
- `app/views/posts/index.html.erb`
- `app/views/posts/show.html.erb`
- `app/views/posts/_form.html.erb`
- `app/views/layouts/application.html.erb`
- `app/views/users/_form.html.erb`

## Migration Strategy
1. Map semantic tokens for text/surface/border/interactive states:
   - `--ds-surface-1`, `--ds-surface-2`, `--ds-border-1`, `--ds-border-2`
   - `--ds-text-main`, `--ds-text-subtle`, `--ds-text-muted`
   - `--ds-accent`, `--ds-accent-contrast`, `--ds-danger`, `--ds-warning`, `--ds-success`
2. Replace repeated utility colors with component classes in P0 screens first.
3. Keep contrast gate for both themes before enabling switch:
   - Body text >= 4.5:1
   - Meta/aux text >= 4.5:1
   - CTA labels >= 4.5:1
4. Add visual regression snapshots for `ja/en` in both light/dark.

## Component Readiness
- Ready: skeleton/toast/focus/tap/spacing tokens in Tailwind layer.
- Partial: cards/forms/badges (token + hard-coded mixed).
- Not-ready: legal/admin/email templates.

## Next Implementation Batch
- Batch A: header/nav, post index cards, post show sections.
- Batch B: form screens + notifications + profile pages.
- Batch C: legal/admin pages and email theming.
