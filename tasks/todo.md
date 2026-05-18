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
- [x] Continue sweep on `fix/project-hardening-pass`.
- [x] Audit next high-risk surfaces.
- [x] Fix confirmed defect 5: UDP RTSP control receive rejects short/error reads before parser callbacks.
- [x] Run targeted checks for defect 5.
- [x] Review defect 5 diff.
- [x] Commit defect 5: `cd11b0004` (`Reject short UDP RTSP reads.`).
- [x] Audit next high-risk surfaces.
- [x] Fix confirmed defect 6: RTSP header buffering capped on TCP and UDP control connections.
- [x] Run targeted checks for defect 6.
- [x] Review defect 6 diff.
- [x] Commit defect 6: `7ef26717c` (`Cap RTSP header buffering.`).
- [x] Audit next high-risk surfaces.
- [x] Fix confirmed defect 7: SRT data packet classifier rejects packets shorter than a sequence-number header.
- [x] Run targeted checks for defect 7.
- [x] Review defect 7 diff.
- [x] Commit defect 7: `b82f801ee` (`Reject short SRT data packets.`).
- [x] Audit next high-risk surfaces.
- [x] Fix confirmed defect 8: remote-control filter state skips malformed pairs instead of throwing.
- [x] Run targeted checks for defect 8.
- [x] Review defect 8 diff.
- [x] Commit defect 8: `8bcedf647` (`Skip malformed filter state.`).
- [x] Audit next high-risk surfaces.
- [x] Fix confirmed defect 9: remote-control websocket ignores malformed JSON and non-object messages.
- [x] Run targeted checks for defect 9.
- [x] Review defect 9 diff.
- [x] Commit defect 9: `1156186c2` (`Ignore malformed websocket messages.`).
- [x] Audit next high-risk surfaces.
- [x] Fix confirmed defect 10: RTMP AAC config parser rejects decoder configs shorter than two bytes.
- [x] Run targeted checks for defect 10.
- [x] Review defect 10 diff.
- [x] Commit defect 10: `67a0b3c05` (`Reject short RTMP audio config.`).
- [x] Audit next high-risk surfaces.
- [x] Fix confirmed defect 11: mono WAV headers use derived byte rate and block alignment.
- [x] Run targeted checks for defect 11.
- [x] Review defect 11 diff.
- [x] Commit defect 11: `ef77467b9` (`Write valid mono WAV headers.`).
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
- Defect 5 checks:
  - Red check: UDP RTSP fixed-size receive passed short reads to parser callbacks.
  - Green check: UDP receive helper validates `data.count == size` and reports disconnect on short/error reads.
  - `git diff --check`: pass.
  - `swiftformat`: unavailable in this shell.
  - `swiftlint`: unavailable in this shell.
  - code-review-graph: low impact radius, no affected flows.
- Defect 6 checks:
  - Red check: RTSP header readers could grow without bound before `CRLFCRLF`.
  - Green check: TCP and UDP header readers enforce `rtspMaxHeaderSize`.
  - `git diff --check`: pass.
  - `swiftformat`: unavailable in this shell.
  - `swiftlint`: unavailable in this shell.
  - code-review-graph: low impact radius, no affected flows.
- Defect 7 checks:
  - Red check: `isSrtDataPacket` indexed short packets.
  - Green check: classifier requires `srtSequenceNumberSize` and test covers empty, one-byte, three-byte, data, and control packets.
  - `git diff --check`: pass.
  - `xcodebuild`: unavailable in this shell.
  - `swift`: unavailable in this shell.
  - `swiftformat`: unavailable in this shell.
  - `swiftlint`: unavailable in this shell.
  - code-review-graph: low impact radius, no affected flows.
- Defect 8 checks:
  - Red check: `convertFilters` trusted alternating object/boolean websocket state and could throw on malformed payloads.
  - Green check: source and generated bundle skip malformed pairs and empty filter objects.
  - `npm run build`: pass.
  - `git diff --check`: pass.
  - code-review-graph: medium generated-bundle risk, no affected flows.
- Defect 9 checks:
  - Red check: websocket message handler trusted `JSON.parse` and type assertions for untrusted text frames.
  - Green check: source and generated bundle ignore invalid JSON, `null`, and non-object messages.
  - `npm run build`: pass.
  - `git diff --check`: pass.
  - code-review-graph: medium generated-bundle risk, no affected flows.
- Defect 10 checks:
  - Red check: `MpegTsAudioConfig(data:)` indexed `data[0]` and `data[1]` before validating short decoder config data.
  - Green check: parser returns `nil` for data shorter than two bytes and `RtmpSuite.shortAudioConfig` covers empty and one-byte inputs.
  - `git diff --check`: pass.
  - `swift`: unavailable in this shell.
  - `xcodebuild`: unavailable in this shell.
  - `swiftformat`: unavailable in this shell.
  - `swiftlint`: unavailable in this shell.
  - code-review-graph: medium generated-bundle noise from changed-file graph state, no affected flows.
- Defect 11 checks:
  - Red check: `createWav` hardcoded byte rate and block alignment.
  - Green check: WAV source derives byte rate and block alignment from sample rate and channel count, and mono test expects 44.1 kHz mono header values.
  - `git diff --check`: pass.
  - `swift`: unavailable in this shell.
  - `xcodebuild`: unavailable in this shell.
  - code-review-graph: low impact radius, no affected flows.
- Continuation final checks:
  - Branch: `fix/project-hardening-pass`.
  - `make web-remote-control-frontend-build`: pass.
  - `npm audit --audit-level=moderate`: 0 vulnerabilities.
  - Static regression checks for defects 5 through 11: pass.
  - `git diff --check`: pass.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift`: unavailable in this shell.
  - `xcodebuild`: unavailable in this shell.
  - Unrelated/unowned working tree item left alone: `.idea/`.

## Continued sweep 2026-05-18

### Assumptions

- Continue on `fix/project-hardening-pass`.
- Keep fixes surgical and commit one confirmed defect at a time.
- Use `/home/michael/Development/Research/transport-reference-corpus/` for protocol and media reference checks when touching transport, codec, media, adaptive bitrate, or recovery logic.
- Leave unrelated `.idea/` and unowned instruction-file state alone.

### Acceptance criteria

- Each fix has a concrete failure mode and root cause.
- Each fix changes only the affected path and matching tests or generated artifacts when required.
- Each fix is validated with the smallest relevant check first, then broader available checks.
- Each fix is reviewed before commit and committed separately with a normal descriptive message.

### Checklist

- [x] Select a high-risk transport or media path using local code plus transport corpus references.
- [x] Confirm defect and scope the minimal fix.
- [x] Patch the defect and add or update focused tests when feasible.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [x] Commit the fix alone.

### Review

- Defect 12 checks:
  - Red check: `AdaptiveBitrateSrtBelabox.updateBitrate` force-unwrapped optional `stats.mbpsSendRate`.
  - Corpus check: Belacoder reference uses `stats->mbpsSendRate` to update throughput, so missing send-rate samples are incomplete inputs.
  - Green check: Belabox update now skips missing send-rate samples before mutating rolling bitrate state.
  - Regression coverage: `belaboxIgnoresMissingSendRate` sends `mbpsSendRate: nil` and expects no bitrate change or delegate update.
  - Static check: no `stats.mbpsSendRate!` remains in adaptive bitrate code or tests.
  - `git diff --check`: pass.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test`: blocked because `swift` is unavailable in this shell.
  - `xcodebuild`: unavailable in this shell.
  - code-review-graph: high shared-code impact, no affected flows.
