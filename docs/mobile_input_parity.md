# Mobile Input Parity Checklist (iOS / Android)

## Scope
- Keyboard open/close behavior
- Focus transitions between fields
- Safe area overlap with sticky action bars
- Dialog and menu focus return on close

## Implemented Baseline
- Platform class tagging (`platform-ios`, `platform-android`) in UI runtime.
- Sticky bars use safe-area-aware padding.
- Mobile action bars hide while forms are focused.

## Manual Verification Script
1. Open post detail on iOS Safari and Android Chrome.
2. Open/close report modal and verify focus returns to trigger.
3. Focus report reason/details fields and verify sticky bar hides.
4. Submit with missing required fields and verify reason text is visible.
