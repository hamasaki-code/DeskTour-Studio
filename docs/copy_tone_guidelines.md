# UI Copy Tone Guidelines

Date: 2026-03-08

## Scope
- `posts/index`, `posts/show`, `posts/form`
- `reports` flows
- `users` flows
- navigation, menu, and feedback messages

## Japanese tone
- Default style: polite `です/ます` style.
- Error and warning text:
  - Keep causal format: `原因: ... 操作: ... 再試行: ...`
  - Do not use aggressive imperative tone.
- CTA labels:
  - Use short action phrases (`投稿を探す`, `投稿作成`, `通報を送信`).
  - Keep labels consistent between desktop and mobile.

## English tone
- Use direct and concise action wording.
- Prefer plain language over technical wording.
- Keep tense and voice consistent (`Processing...`, `Report received...`).

## Mixed-locale policy
- Do not ship English labels in Japanese UI except product names.
- Do not ship Japanese labels in English UI except proper nouns.
- Remove `default:` fallback usage from app files to prevent silent mixed copy.

## Review checklist
- Confirm locale pair (`ja` and `en`) both have the same key set.
- Confirm CTA wording matches the same meaning in both locales.
- Confirm feedback messages keep the same severity and intent.
