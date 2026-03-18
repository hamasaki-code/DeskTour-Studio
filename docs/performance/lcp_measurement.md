# LCP Measurement Log

## Goal
Track Largest Contentful Paint (LCP) before and after the image optimization pipeline.

## Prerequisites
- App server running locally (`bin/rails server`)
- Chrome/Chromium available for Selenium
- Test data with at least one published post containing an image

## Commands
```bash
# Baseline (before optimization)
bundle exec ruby script/measure_lcp.rb --url http://127.0.0.1:3000/ --label before

# After optimization
bundle exec ruby script/measure_lcp.rb --url http://127.0.0.1:3000/ --label after
```

## Output
Measurements are stored in:
- `tmp/lcp_measurements.json`

Use the median value (`median_lcp_ms`) to compare before vs after.

## Record Template
| Date (UTC) | URL | Before LCP (ms) | After LCP (ms) | Delta (ms) |
|---|---|---:|---:|---:|
| T.B.D. | `/` | T.B.D. | T.B.D. | T.B.D. |
