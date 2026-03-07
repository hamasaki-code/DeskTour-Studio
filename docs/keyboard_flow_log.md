# Keyboard Flow Log

## 2026-03-07 UI/UX Overhaul
- Scope:
  - `posts#index` search and filter controls
  - `posts#show` desktop action menu
  - mobile header utility menu
- Verified flows:
  - keyboard open/close for desktop action menu (`Esc` close)
  - keyboard submit from search keyword input (`Enter`)
  - mobile menu dismiss with `Esc`
- Evidence:
  - `test/system/keyboard_flow_test.rb`
  - `test/accessibility/basic_audit_test.rb`
