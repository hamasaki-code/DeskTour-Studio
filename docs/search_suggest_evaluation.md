# Search Suggest Evaluation Plan

## Hypothesis
Search suggestions (titles/tags/categories/themes) reduce zero-result searches by guiding users during input.

## Implemented
- Added input datalist suggestions on gallery search field.
- Added event `post_search_suggestion_eval` with labels:
  - `suggestion_match`
  - `free_text`

## Success Metric
- Primary: zero-result rate reduction.
- Secondary: search submit-to-detail CTR improvement.

## Guardrail
- Search submit volume should not decrease significantly.
