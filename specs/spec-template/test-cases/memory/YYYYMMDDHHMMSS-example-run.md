---
date: {YYYY-MM-DDTHH:MM:SSZ}
summary: {Suite or test case} {passed}/{total} pass{, TC-nnn failing: short reason}
tags: [{area}]
commit: {short hash under test}
---

<!-- One file per test run, named <YYYYMMDDHHMMSS>-<slug>.md (UTC).
     See RECORDS.md -> Test-Run Entries. This example file is a template:
     do not copy it into a real spec. -->

## Result

{PASS/FAIL summary, counts, key data such as test record IDs - never
credentials, API keys, or auth tokens}

## {Optional: Blocker / Fix Applied / Still Open}

{...}

Log: `logs/run-{timestamp}.log`
