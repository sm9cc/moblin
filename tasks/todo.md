# Production-readiness sweep

Date: 2026-05-18

## Assumptions

- Sweep scope is `/home/michael/Development/Swift/moblin`.
- Fix only confirmed defects with narrow changes.
- Make one commit per fix.

## Acceptance criteria

- Confirmed bugs have a focused test or direct reproduction check.
- Changed behavior passes targeted validation.
- Available project checks are run before final status.
- Each fix is committed separately.
- Diff review is recorded before each commit.

## Checklist

- [x] Read project instructions.
- [x] Confirm repo scope and clean starting state.
- [x] Audit high-risk Swift and frontend surfaces.
- [x] Fix confirmed defect 1: remote-control status values rendered as text, not HTML.
- [x] Run targeted checks for defect 1.
- [x] Review defect 1 diff.
- [x] Commit defect 1: `a37e6b797` (`Escape remote control status values.`).
- [x] Fix confirmed defect 2: Watch keepalive timer stored, weak-captured, and not duplicated on repeated setup.
- [x] Run targeted checks for defect 2.
- [x] Review defect 2 diff.
- [x] Commit defect 2: `e0207ac21` (`Avoid duplicate watch keepalive timers.`).
- [x] Fix confirmed defect 3: stale WHEP offer responses no longer mutate stopped clients or leave late server sessions alive.
- [x] Run targeted checks for defect 3.
- [x] Review defect 3 diff.
- [x] Commit defect 3: `ac0501f0b` (`Ignore stale WHEP offer responses.`).
- [x] Fix confirmed defect 4: RTSP TCP fixed-size receive rejects short/error reads before parser indexing.
- [x] Run targeted checks for defect 4.
- [x] Review defect 4 diff.
- [x] Commit defect 4: `b905ee499` (`Reject short RTSP TCP reads.`).
- [x] Run broad final checks.

## Review

- Defect 1 checks:
  - Red check: `rg -n 'innerHTML=' WebRemoteControlFrontend/src/index.tsx` found the unsafe render.
  - Green check: no `innerHTML` in `WebRemoteControlFrontend/src/index.tsx` or generated `Moblin/RemoteControl/Web/js/index.mjs`.
  - `npm install`: 0 vulnerabilities.
  - `npm run build`: pass.
  - `git diff --check`: pass.
  - code-review-graph: no affected flows; generated JS risk high due minified bundle impact radius.
- Defect 2 checks:
  - Red check: Watch timer block captured `self` strongly.
  - Green check: staged `WatchModel.swift` has stored `periodicTimer`, invalidation, and `[weak self]`.
  - `git diff --check`: pass.
  - `swiftformat`: unavailable in this shell.
  - `swiftlint`: unavailable in this shell.
  - code-review-graph: low impact radius, no affected flows.
- Defect 3 checks:
  - Red check: stopped WHEP offer response could mutate/reconnect.
  - Green check: stopped offer response is guarded and sends DELETE for late sessions.
  - `git diff --check`: pass.
  - `swiftformat`: unavailable in this shell.
  - `swiftlint`: unavailable in this shell.
  - code-review-graph: low impact radius, no affected flows.
- Defect 4 checks:
  - Red check: RTSP fixed-size receive passed short reads to parser callbacks.
  - Green check: receive helper validates `data.count == size` and reports disconnect on short/error reads.
  - `git diff --check`: pass.
  - `swiftformat`: unavailable in this shell.
  - `swiftlint`: unavailable in this shell.
  - code-review-graph: low impact radius, no affected flows.
- Final checks:
  - Branch: `fix/project-hardening-pass`.
  - `npm run build`: pass.
  - `npm audit --audit-level=moderate`: 0 vulnerabilities.
  - Static regression checks for all four fixes: pass.
  - `git diff --check`: pass.
  - Missing tools in this shell: `xcodebuild`, `swiftformat`, `swiftlint`, `oxfmt`, `oxlint`, `codespell`, `periphery`.
  - Unrelated/unowned working tree item left alone: `.idea/`.
