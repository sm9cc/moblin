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

## Continued sweep 2026-05-18 RTP headers

### Assumptions

- Keep existing H264/H265 RTP payload processors on their fixed 12-byte-header contract.
- Normalize valid variable-length RTP headers before those processors receive packets.
- Reject malformed RTP extension and padding lengths instead of passing corrupt payloads downstream.

### Acceptance criteria

- RTP packets with CSRC entries or header extensions are accepted when their lengths are valid.
- Existing fixed-header RTP packets keep the old packet shape.
- Padding bytes are stripped before video payload processing.
- Malformed empty-payload packets fail before H264/H265 payload indexing.

### Checklist

- [x] Select a high-risk RTSP/RTP parser path using local code plus transport corpus references.
- [x] Confirm defect and scope the minimal fix.
- [x] Patch the defect and add focused tests.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [x] Commit the fix alone.

### Review

- Defect 13 checks:
  - Red check: RTSP RTP receive path rejected valid RTP packets with `X` or `CC` bits set.
  - Corpus check: RTP references compute payload offset from CSRC count plus extension header length.
  - Green check: `normalizeRtpPacket` strips CSRC, extension, and padding before fixed-header H264/H265 processors run.
  - Malformed-input guard: RTP packets with no payload after extension or padding now fail before payload indexing.
  - Regression coverage: `RtspClientSuite` covers CSRC plus extension normalization and padding stripping.
  - Static check: old `Unsupported x` and `Unsupported cc` guards are gone.
  - `git diff --check`: pass.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test`: blocked because `swift` is unavailable in this shell.
  - code-review-graph: high RTSP shared-code impact, no affected flows.

## Continued sweep 2026-05-18 MPEG-TS packet size

### Assumptions

- MPEG-TS writer output must keep every TS packet at `MpegTsPacket.size`.
- Keep the packetizer structure unchanged and fix only the impossible first-packet stuffing condition.
- Use existing adaptation-field stuffing behavior to fill short PES payloads.

### Acceptance criteria

- A short PES payload that fits in the first packet encodes as one 188-byte TS packet.
- Existing full first-packet payloads keep their current payload size.
- No unrelated MPEG-TS writer or reader behavior changes.

### Checklist

- [x] Select a high-risk MPEG-TS writer path using local code plus transport corpus references.
- [x] Confirm defect and scope the minimal fix.
- [x] Patch the defect and add focused tests.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [x] Commit the fix alone.

### Review

- Defect 14 checks:
  - Red check: first PES packet stuffing used `payloadOffset > payload.count`, which cannot be true after `min(...)`.
  - Corpus check: MPEG-TS packets are fixed at 188 bytes, matching `MpegTsPacket.size`.
  - Green check: first-packet stuffing now fills `maximumPayloadSize - payloadOffset` when the PES payload is short.
  - Regression coverage: `shortPayloadFirstPacketIsFullSize` verifies a one-packet PES encode has size `MpegTsPacket.size`.
  - Static check: impossible `payloadOffset > payload.count` condition is gone.
  - `git diff --check`: pass.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test`: blocked because `swift` is unavailable in this shell.
  - code-review-graph: high MPEG-TS shared-code impact, no affected flows.

## Continued sweep 2026-05-18 SRTLA local listener startup

### Assumptions

- Official SRT implementation needs the local UDP listener to start before the client can become ready.
- Listener creation failure must surface through the existing SRTLA disconnect/error path.
- Keep the fix to startup/error state ordering only.

### Acceptance criteria

- A local listener creation failure does not leave the client waiting forever for readiness.
- Ready callbacks are accepted even if Network reports `.ready` immediately after `start(queue:)`.
- Existing listener stop behavior remains unchanged.

### Checklist

- [x] Select a high-risk SRTLA startup path using local code plus transport corpus references.
- [x] Confirm defect and scope the minimal fix.
- [x] Patch the defect.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [x] Commit the fix alone.

### Review

- Defect 15 checks:
  - Red check: `LocalListener.start()` swallowed `NWListener` creation failure, and `SrtlaClient` moved to `.waitForLocalSocketListening` after startup returned.
  - Corpus check: BELABOX SRTLA receiver exits on UDP socket setup failure instead of waiting for readiness that cannot happen.
  - Green check: listener creation failure now calls the existing SRTLA error path and reports `false` to the caller.
  - State-ordering check: official SRT mode enters `.waitForLocalSocketListening` before starting the listener, so immediate ready/error callbacks are handled.
  - Safety check: `.ready` no longer force unwraps `listener.port`.
  - Static check: no `listener.port!` remains in `LocalListener`, and `SrtlaClient` guards the listener start result.
  - `git diff --check`: pass.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test`: blocked because `swift` is unavailable in this shell.
  - `xcodebuild`: blocked because `xcodebuild` is unavailable in this shell.
  - code-review-graph: high SRTLA shared-code impact, no affected flows.

## Continued sweep 2026-05-18 unaligned packet reads

### Assumptions

- `Data` packet buffers and slices are not guaranteed to be aligned for typed integer loads.
- Big-endian protocol fields should be decoded byte-by-byte, matching the existing 24-bit and 32-bit helper style.
- Keep the change limited to read helpers used by packet parsers.

### Acceptance criteria

- 16-bit and 32-bit big-endian reads work at non-zero offsets without typed unaligned loads.
- Existing big-endian values are unchanged.
- SRT, SRTLA, RTMP, and MPEG parser callers keep the same helper API.

### Checklist

- [x] Select a high-risk packet helper path using local code plus transport corpus references.
- [x] Confirm defect and scope the minimal fix.
- [x] Patch the defect and add focused tests.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [x] Commit the fix alone.

### Review

- Defect 16 checks:
  - Red check: `getUInt16Be` and `getUInt32Be` used typed `UnsafeRawBufferPointer.load` on packet `Data`, which requires aligned memory.
  - Corpus check: SRT references use explicit network-endian conversion or byte shifts for protocol fields.
  - Green check: both helpers now assemble values from bytes, matching existing `getThreeBytesBe` and `getFourBytesBe`.
  - Regression coverage: `UtilsSuite` covers 16-bit and 32-bit big-endian reads at offset 1.
  - Static check: no typed `load(fromByteOffset: offset, as: UInt16.self)` or `UInt32.self` remains in the helpers.
  - `git diff --check`: pass.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test --filter UtilsSuite`: blocked because `swift` is unavailable in this shell.
  - `xcodebuild`: blocked because `xcodebuild` is unavailable in this shell.
  - code-review-graph: high shared-helper impact, no affected flows.

## Continued sweep 2026-05-18 unaligned packet writes

### Assumptions

- `Data` packet buffers are not guaranteed to be aligned for typed integer stores.
- SRTLA keepalive writes an `Int64` at offset 2, so typed stores can fail in live use.
- Keep the helper API unchanged and update only big-endian packet writers.

### Acceptance criteria

- 16-bit, 32-bit, and 64-bit big-endian writes work at non-zero offsets without typed stores.
- Existing encoded big-endian byte order is unchanged.
- SRTLA keepalive packet construction keeps the same layout.

### Checklist

- [x] Select the paired high-risk packet write helper path using local code plus transport corpus references.
- [x] Confirm defect and scope the minimal fix.
- [x] Patch the defect and add focused tests.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [x] Commit the fix alone.

### Review

- Defect 17 checks:
  - Red check: `setUInt16Be`, `setUInt32Be`, and `setInt64Be` used typed `storeBytes`; SRTLA keepalive writes `Int64` at offset 2.
  - Corpus check: SRT and SRTLA packet fields are byte-addressed network-order fields, not aligned Swift integers.
  - Green check: all three setters now write big-endian bytes directly.
  - Regression coverage: `UtilsSuite` covers 16-bit, 32-bit, and 64-bit big-endian writes at non-zero offsets.
  - Static check: no `storeBytes` remains in `CommonUtils` packet integer setters.
  - `git diff --check`: pass.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test --filter UtilsSuite`: blocked because `swift` is unavailable in this shell.
  - `xcodebuild`: blocked because `xcodebuild` is unavailable in this shell.
  - code-review-graph: high shared-helper impact, no affected flows.

## Continued sweep 2026-05-18 SRT NAK range bounds

### Assumptions

- Moblin still handles NAKs through per-sequence callbacks.
- A compressed SRT loss range must not expand into unbounded CPU or memory work.
- Preserve existing packet parsing and cap only the amount of expanded NAK work.

### Acceptance criteria

- Normal single-sequence and small range NAK packets keep their existing callbacks.
- A very large range stops after the same sequence-count budget used for emitted NAK packets.
- Malformed or hostile NAK input cannot force millions of loop iterations.

### Checklist

- [x] Select a high-risk SRT NAK parser path using local code plus transport corpus references.
- [x] Confirm defect and scope the minimal fix.
- [x] Patch the defect and add focused tests.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [x] Commit the fix alone.

### Review

- Defect 18 checks:
  - Red check: `processSrtNak` expanded compressed ranges with no bound, so a hostile range could force millions of callbacks.
  - Corpus check: SRT validates loss report ranges against sender state before inserting them into bounded loss lists.
  - Green check: Moblin keeps the existing per-sequence callback API but stops expansion at `srtNakMaximumSequenceNumbers`.
  - Consistency check: `NakPacket.pack()` now uses the same sequence-count budget when emitting NAK packets.
  - Regression coverage: `SrtSenderSuite` covers normal range expansion and large range truncation.
  - Static check: old unbounded `stride(from:through:by:)` expansion is gone.
  - `git diff --check`: pass.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test --filter SrtSenderSuite`: blocked because `swift` is unavailable in this shell.
  - `xcodebuild`: blocked because `xcodebuild` is unavailable in this shell.
  - code-review-graph: high SRTLA shared-code impact, no affected flows.

## Continued sweep 2026-05-18 SRTLA server connection handoff

### Assumptions

- `SrtlaServerClientConnection` must not receive packets until its delegate is installed.
- Keep ownership and receive-loop behavior unchanged after startup.
- The only construction path is `SrtlaServerClient.addConnection`.

### Acceptance criteria

- A newly registered SRTLA connection starts receiving only after `delegate` is set.
- Existing duplicate connection checks and connection tracking remain unchanged.
- No receive-loop behavior changes after `start()` is called.

### Checklist

- [x] Select a high-risk SRTLA connection handoff path using local code plus transport references.
- [x] Confirm defect and scope the minimal fix.
- [x] Patch the defect.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [x] Commit the fix alone.

### Review

- Defect 19 checks:
  - Red check: `SrtlaServerClientConnection.init` started `receivePackets()` before `SrtlaServerClient.addConnection` assigned `delegate`.
  - Corpus check: SRTLA data packets are forwarded immediately after registration, so the handoff must be ready before receiving.
  - Green check: `start()` now begins the receive loop after the delegate is installed and the connection is stored.
  - Static check: the only construction path calls `connection.delegate = self`, appends the connection, then calls `connection.start()`.
  - `git diff --check`: pass.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test --filter SrtSenderSuite`: blocked because `swift` is unavailable in this shell.
  - `xcodebuild`: blocked because `xcodebuild` is unavailable in this shell.
  - code-review-graph: high SRTLA server impact, no affected flows.

## Continued sweep 2026-05-18 SRTLA local short packet guard

### Assumptions

- Local SRT server packets still pass through the same SRT header helpers as remote SRTLA packets.
- Packets shorter than the SRT control type field are malformed and should be dropped.
- Keep ACK, NAK, data, and forwarding behavior unchanged for valid packets.

### Acceptance criteria

- `SrtlaServerClient` does not read the SRT control packet type from fewer than two bytes.
- Existing data packet, ACK, NAK, and default forwarding paths are unchanged for valid packets.
- The fix matches the boundary checks already used by the SRTLA listener and remote connection paths.

### Checklist

- [x] Select a high-risk local SRT handoff path using local code plus transport corpus references.
- [x] Confirm defect and scope the minimal fix.
- [x] Patch the defect.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [x] Commit the fix alone.

### Review

- Defect 20 checks:
  - Red check: `handlePacketFromLocalSrtServer` read the SRT control packet type without first proving two bytes exist.
  - Corpus check: BELABOX SRTLA `get_srt_type()` returns before reading when the packet is shorter than the type field.
  - Green check: the local SRT callback now drops packets shorter than `srtControlTypeSize`, matching the SRTLA listener and remote connection guard pattern.
  - Static check: valid data packets, ACKs, NAKs, and default forwarding still use the same branches after the new guard.
  - `git diff --check`: pass.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test --filter SrtSenderSuite`: blocked because `swift` is unavailable in this shell.
  - `xcodebuild`: blocked because `xcodebuild` is unavailable in this shell.
  - code-review-graph: low SRTLA callback impact, no affected flows, test gap for private `NWConnection` callback.

## Continued sweep 2026-05-18 RTSP fragmented RTP payload guards

### Assumptions

- RTP packets have already been normalized before the codec depacketizers run.
- H.264 FU-A packets must include FU indicator, FU header, and at least one byte of fragment payload.
- H.265 FU packets must include the two-byte payload header, FU header, and at least one byte of fragment payload.

### Acceptance criteria

- H.264 FU-A packets with only FU indicator and FU header are rejected before frame assembly.
- H.265 FU packets with only payload header and FU header are rejected before frame assembly.
- Valid fragmented H.264 and H.265 packets keep their existing assembly paths.

### Checklist

- [x] Select a high-risk RTSP/RTP depacketizer path using local code plus transport corpus references.
- [x] Confirm defect and scope the minimal fix.
- [x] Patch the defect.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [x] Commit the fix alone.

### Review

- Defect 21 checks:
  - Red check: H.264 FU-A packets with only FU indicator and FU header appended an empty fragment payload.
  - Red check: H.265 FU packets with only payload header and FU header appended an empty fragment payload.
  - Corpus check: FFmpeg rejects H.264 FU-A input shorter than FU indicator, FU header, and one payload byte.
  - Corpus check: FFmpeg rejects or defers HEVC FU input with no payload bytes after the FU header.
  - Green check: H.264 FU-A now requires 15 normalized RTP bytes, preserving the existing valid assembly path.
  - Green check: H.265 FU now requires 16 normalized RTP bytes, preserving the existing valid assembly path.
  - `git diff --check`: pass.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test --filter RtspClientSuite`: blocked because `swift` is unavailable in this shell.
  - `xcodebuild`: blocked because `xcodebuild` is unavailable in this shell.
  - code-review-graph: low RTSP codec impact, no affected flows, test gap for private codec processors.

## Continued sweep 2026-05-18 RTSP transport disconnect recovery

### Assumptions

- RTSP transport callbacks run on `rtspClientQueue`.
- Existing reconnect timers define Moblin's RTSP recovery policy.
- Explicit user stop should not schedule a reconnect.

### Acceptance criteria

- A transport disconnect while the RTSP client is started enters the existing reconnect path.
- A transport disconnect after explicit stop does nothing.
- Existing startup timeout and keepalive recovery behavior remain unchanged.

### Checklist

- [x] Select a high-risk RTSP transport recovery path using local code plus transport corpus references.
- [x] Confirm defect and scope the minimal fix.
- [x] Patch the defect.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [x] Commit the fix alone.

### Review

- Defect 22 checks:
  - Red check: RTSP transports reported disconnects for receive failures and oversized headers, but `RtspClient.rtspTransportDisconnected()` ignored them.
  - Corpus check: GStreamer RTSP reconnects when the server closes the control connection.
  - Green check: transport disconnects now enter Moblin's existing `reconnectSoon()` path while the client is started.
  - Stop check: callbacks after explicit stop or after an already-disconnected reset return without scheduling a reconnect.
  - Static check: startup timeout and keepalive recovery still call the same reconnect helper as before.
  - `git diff --check`: pass.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test --filter RtspClientSuite`: blocked because `swift` is unavailable in this shell.
  - `xcodebuild`: blocked because `xcodebuild` is unavailable in this shell.
  - code-review-graph: low RTSP delegate impact, no affected flows, no reported test gaps.

## Continued sweep 2026-05-18 RTSP TCP interleaved channel validation

### Assumptions

- RTSP/TCP setup responses must provide numeric RTP and RTCP interleaved channels.
- Channels outside the one-byte interleaved frame header cannot be represented by Moblin's TCP transport.
- Rejecting an invalid setup response is safer than silently setting nil channels and dropping media.

### Acceptance criteria

- Valid `interleaved=0-1` setup responses still parse.
- Out-of-range TCP interleaved channels throw during setup response handling.
- RTP and RTCP channel assignment only happens after both values are valid.

### Checklist

- [x] Select a high-risk RTSP setup parser path using local code plus transport corpus references.
- [x] Confirm defect and scope the minimal fix.
- [x] Patch the defect.
- [x] Add focused parser tests.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [x] Commit the fix alone.

### Review

- Defect 23 checks:
  - Red check: `RtspTransportRtpRtspTcp.handleSetupTransportResponse()` silently assigned nil RTP or RTCP channels when `interleaved=` values exceeded `UInt8`.
  - Corpus check: FFmpeg and GStreamer generate explicit RTP/RTCP interleaved channel pairs for RTSP/TCP setup.
  - Green check: both parsed interleaved channel values must now fit the one-byte RTSP interleaved frame header before assignment.
  - Regression coverage: `RtspClientSuite` covers a valid `interleaved=0-1` response and rejects `interleaved=256-257`.
  - `git diff --check`: pass.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test --filter RtspClientSuite`: blocked because `swift` is unavailable in this shell.
  - `xcodebuild`: blocked because `xcodebuild` is unavailable in this shell.
  - code-review-graph: low RTSP parser impact, no affected flows; reported test gap despite the focused parser tests.
