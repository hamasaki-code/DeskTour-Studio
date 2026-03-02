# Release Observation Policy

## Standard Observation Window
- Minimum: 14 days per UX change batch.
- If sample size is insufficient after 14 days, extend to 21 days.

## Decision States
- Success: KPI moved in expected direction and guardrail is stable.
- Hold: KPI improved but guardrail unstable, or sample size insufficient.
- Rollback: KPI regressed or guardrail breach persisted > 3 consecutive days.

## Required Inputs Before Release
- Primary KPI and expected direction.
- Guardrail KPI.
- Rollback trigger threshold.
- Owner and review date.

## Required Outputs After Observation
- Outcome state (Success / Hold / Rollback).
- Evidence summary with dates.
- Next action (scale / tune / revert).
