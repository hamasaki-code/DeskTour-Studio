# Information Architecture Consistency Audit

Date: 2026-03-02
Scope: posts/index, posts/show, post/user forms, notifications, onboarding, legal pages

## Audit Criteria
- Current location visibility: breadcrumb/context path is present.
- Next-step visibility: each screen exposes at least one forward action.
- Policy access: legal links are visible from high-entry screens.
- Heading structure: one `h1` per page and progressive section headings.

## Findings and Implemented Actions
- Added global breadcrumb-style context nav in layout.
- Added onboarding quick link to major entry points.
- Added legal quick links in header utility and key content pages.
- Added revisit block on gallery page for "recently viewed" and "saved" shortcuts.

## Open Follow-up
- Add explicit breadcrumb coverage for admin namespace.
- Consider hierarchical IA map in docs for future feature teams.
