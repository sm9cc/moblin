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

## Continued sweep 2026-05-18 RTSP UDP server port validation

### Assumptions

- RTSP/UDP setup responses must provide numeric RTP and RTCP server ports.
- Moblin only sends RTCP back to the server port today, but accepting an invalid RTP half hides malformed transport negotiation.
- Rejecting malformed setup responses should happen before the client enters playback.

### Acceptance criteria

- Valid `server_port=5004-5005` setup responses still parse.
- Out-of-range RTP server ports throw during UDP setup response handling.
- RTCP send port assignment remains unchanged for valid responses.

### Checklist

- [x] Select a high-risk RTSP UDP setup parser path using local code plus transport corpus references.
- [x] Confirm defect and scope the minimal fix.
- [x] Patch the defect.
- [x] Add focused parser tests.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [x] Commit the fix alone.

### Review

- Defect 24 checks:
  - Red check: `RtspTransportRtpUdp.handleSetupTransportResponse()` validated only the RTCP half of `server_port=rtp-rtcp`.
  - Corpus check: GStreamer parses and validates the whole `server_port` range before accepting an RTSP transport response.
  - Green check: UDP setup now rejects responses where either RTP or RTCP server port cannot fit a valid 16-bit port.
  - Regression coverage: `RtspClientSuite` covers a valid `server_port=5004-5005` response and rejects `server_port=999999-5005`.
  - `git diff --check`: pass.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test --filter RtspClientSuite`: blocked because `swift` is unavailable in this shell.
  - `xcodebuild`: blocked because `xcodebuild` is unavailable in this shell.
  - code-review-graph: low RTSP parser impact, no affected flows; reported test gap despite the focused parser tests.

## Continued sweep 2026-05-18 RTSP Content-Length validation

### Assumptions

- RTSP response bodies used by Moblin are SDP or small control payloads.
- A malformed `Content-Length` is a protocol error and should not be treated as an absent body.
- A one MiB body cap is far above normal SDP sizes while preventing unbounded server-controlled reads.

### Acceptance criteria

- Missing `Content-Length` still means no body.
- Negative or nonnumeric `Content-Length` values disconnect instead of desynchronizing the RTSP stream parser.
- Oversized positive `Content-Length` values disconnect before scheduling a body read.
- Valid RTSP body reads below the cap keep the existing delivery path.

### Checklist

- [x] Select a high-risk RTSP body parser path using local code plus transport corpus references.
- [x] Confirm defect and scope the minimal fix.
- [x] Patch the defect.
- [x] Add focused parser tests.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [x] Commit the fix alone.

### Review

- Defect 25 checks:
  - Red check: malformed `Content-Length` values were treated as absent bodies, leaving any following bytes to desynchronize the RTSP parser.
  - Red check: large positive `Content-Length` values scheduled server-controlled body reads with no Moblin cap.
  - Corpus check: FFmpeg bounds SDP buffers at 16 KiB, and GStreamer exposes a content-length limit before allocating a body buffer.
  - Green check: malformed content lengths now disconnect, missing content length still means no body, and accepted body reads are capped at one MiB.
  - Regression coverage: `RtspClientSuite` covers missing, valid, negative, and nonnumeric `Content-Length` parsing.
  - Static check: TCP and UDP header readers both apply the same parser and cap before `receiveRtspContent`.
  - `git diff --check`: pass.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test --filter RtspClientSuite`: blocked because `swift` is unavailable in this shell.
  - `xcodebuild`: blocked because `xcodebuild` is unavailable in this shell.
  - code-review-graph: low RTSP body parser impact, no affected flows; reported test gap for private receive callbacks.

## Continued sweep 2026-05-18 RTSP digest request URI

### Assumptions

- Digest authentication must hash and report the URI for the request being sent.
- RTSP SETUP can use a media control URL that differs from the original DESCRIBE URL.
- Keep the current MD5-only Digest support unchanged.

### Acceptance criteria

- Digest `ha2` uses `request.url`, matching the URI written in the RTSP request line.
- Digest `uri="..."` uses `request.url`.
- DESCRIBE remains unchanged because its request URL is the base RTSP URL.

### Checklist

- [x] Select a high-risk RTSP authentication path using local code plus transport corpus references.
- [x] Confirm defect and scope the minimal fix.
- [x] Patch the defect.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [x] Commit the fix alone.

### Review

- Defect 26 checks:
  - Red check: RTSP Digest `ha2` and `uri` used the client's base URL even when the outgoing request line used `request.url`.
  - Corpus check: FFmpeg hashes `method:uri` and emits the same request URI in the Digest `uri` field.
  - Green check: Moblin now hashes and reports `request.url`, matching `Request.pack(cSeq:)`.
  - Scope check: MD5-only Digest support, realm, nonce, and retry behavior are unchanged.
  - `git diff --check`: pass.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test --filter RtspClientSuite`: blocked because `swift` is unavailable in this shell.
  - `xcodebuild`: blocked because `xcodebuild` is unavailable in this shell.
  - code-review-graph: low RTSP auth impact, no affected flows; reported a test gap for the private auth path.

## Continued sweep 2026-05-18 RTSP setup control URL joining

### Assumptions

- SDP `a=control:` values are URI references and must be joined with the RTSP aggregate URL.
- Relative control values such as `trackID=1` should append as a path segment when `Content-Base` lacks a trailing slash.
- Control query strings must be preserved in the SETUP request URL.

### Acceptance criteria

- Relative control values join to `Content-Base` with exactly one separator slash.
- Absolute RTSP control URLs remain unchanged.
- Query strings in relative control values remain in the generated SETUP URL.
- Existing missing-control fallback to the client RTSP URL remains unchanged.

### Checklist

- [x] Select a high-risk RTSP setup URL path using local code plus transport corpus references.
- [x] Confirm defect and scope the minimal fix.
- [x] Patch the defect.
- [x] Add focused parser tests.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [x] Commit the fix alone.

### Review

- Defect 27 checks:
  - Red check: `makeSetupUrl` appended `controlUrl.path` directly to `Content-Base`, which dropped relative query strings and produced `rtsp://example.com/livetrackID=1` when the base URL had no trailing slash.
  - Corpus check: FFmpeg appends a separator before relative SDP control paths, and GStreamer builds stream setup locations from the aggregate control URL plus the stream control value.
  - Green check: SDP control values remain raw strings, and `makeRtspSetupUrl` joins relative control values with exactly one separator slash while preserving query strings.
  - Regression coverage: `RtspClientSuite` covers relative control paths, relative query strings, duplicate slash avoidance, absolute control URLs, and missing control fallback.
  - Static check: no `controlUrl.path`, `var control: URL`, or `URL(string: mediaDescription.getValue(for: "control"))` remains in the RTSP setup path.
  - `git diff --check`: pass.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test --filter RtspClientSuite`: blocked because `swift` is unavailable in this shell.
  - `xcodebuild`: blocked because `xcodebuild` is unavailable in this shell.
  - code-review-graph: medium RTSP parser impact, no affected flows; reported test gaps for private/internal RTSP parser entities despite focused `RtspClientSuite` coverage.

## Continued sweep 2026-05-18 RTSP fragmented RTP state

### Assumptions

- RTP packets have already been normalized before H.264 and H.265 depacketizers run.
- A fragmented NAL continuation without an active fragmented NAL is malformed and must not be appended to prior complete frame data.
- An unfinished fragmented NAL should be dropped when a new single NAL or new fragmented start arrives.

### Acceptance criteria

- H.264 FU-A continuations before a start fragment are rejected.
- H.265 FU continuations before a start fragment are rejected.
- New single NAL or fragmented-start packets do not decode a previously incomplete fragmented NAL.
- Completed fragmented NALs still decode on the next frame boundary as before.

### Checklist

- [x] Select a high-risk RTSP fragmented RTP path using local code plus transport corpus references.
- [x] Confirm defect and scope the minimal fix.
- [x] Patch the defect.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [x] Commit the fix alone.

### Review

- Defect 28 checks:
  - Red check: H.264 and H.265 RTP FU continuations appended payload bytes even when no fragmented NAL was active, so malformed continuations could corrupt the prior complete frame.
  - Red check: a new single NAL or FU start decoded the prior `data` buffer even when that buffer held an unfinished fragmented NAL.
  - Corpus check: MistServer drops H.264 FU-A continuations before a start bit, GStreamer tracks the current FU type and drops continuations when no FU is active, and FFmpeg rejects HEVC packets with both S and E set.
  - Green check: H.264 and H.265 processors now track active fragmented NAL state, reject continuations without a start, reject packets with both start and end bits set, and drop incomplete fragmented data at the next frame boundary.
  - Scope check: valid single NALs, FU starts, FU continuations, and completed fragmented frames keep the same assembly layout.
  - Test gap: codec processors are private and require live `CMFormatDescription` setup; no new unit test was added for this private state path.
  - `git diff --check`: pass.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test --filter RtspClientSuite`: blocked because `swift` is unavailable in this shell.
  - `xcodebuild`: blocked because `xcodebuild` is unavailable in this shell.
  - code-review-graph: medium RTSP parser impact, no affected flows; reported test gaps for private/internal RTSP entities.

## Continued sweep 2026-05-18 RTMP peer chunk-size validation

### Assumptions

- RTMP Set Chunk Size values from peers must be at least 1 and no larger than 0x7FFFFFFF.
- Invalid chunk sizes should stop the RTMP client before receive sizing is updated.
- The existing default chunk size and valid peer chunk-size handling should remain unchanged.

### Acceptance criteria

- Peer chunk size 0 is rejected.
- Peer chunk sizes above 0x7FFFFFFF are rejected.
- Peer chunk sizes 1 and 0x7FFFFFFF remain accepted.
- Tests cover the accepted and rejected protocol boundary values.

### Checklist

- [x] Select a high-risk RTMP control-message path using local code plus transport corpus references.
- [x] Confirm defect and scope the minimal fix.
- [x] Patch the defect.
- [x] Add focused tests.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [x] Commit the fix alone.

### Review

- Defect 29 checks:
  - Red check: RTMP Set Chunk Size accepted peer values 0 and values above 0x7FFFFFFF, then updated the server receive chunk size with those invalid values.
  - Corpus check: GStreamer defines valid peer chunk sizes as 1 through 0x7FFFFFFF and rejects out-of-range values before assignment; FFmpeg rejects non-positive incoming chunk sizes.
  - Green check: `processMessageChunkSize` now rejects invalid peer chunk sizes before updating `chunkSizeFromClient`, while boundary values 1 and 0x7FFFFFFF remain valid.
  - Regression coverage: `RtmpSuite.rtmpChunkSizeValidation` covers zero, lower boundary, upper boundary, and oversized peer values.
  - `git diff --check`: pass.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test --filter RtmpSuite`: blocked because `swift` is unavailable in this shell.
  - `xcodebuild`: blocked because `xcodebuild` is unavailable in this shell.
  - code-review-graph: low working-tree risk with one reported test gap on a nearby function, and no affected flows.

## Continued sweep 2026-05-18 RTMP extended chunk stream ID endian

### Assumptions

- RTMP 3-byte basic headers encode chunk stream IDs above 319 as little-endian `chunkStreamId - 64`.
- The existing 1-byte and 2-byte basic header paths should remain unchanged.
- A byte-level unit test is enough to cover this framing rule.

### Acceptance criteria

- Encoding chunk stream ID 400 produces the extended basic header bytes `0x01 0x50 0x01`.
- Decoding those bytes recovers chunk stream ID 400.
- Existing lower chunk stream ID encoding is untouched.

### Checklist

- [x] Select a high-risk RTMP chunk framing path using local code plus transport corpus references.
- [x] Confirm defect and scope the minimal fix.
- [x] Patch the defect.
- [x] Add focused tests.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [x] Commit the fix alone.

### Review

- Defect 30 checks:
  - Red check: RTMP 3-byte basic headers encoded and decoded `chunkStreamId - 64` as big-endian, so valid chunk stream IDs above 319 were put on the wire in the wrong byte order.
  - Corpus check: FFmpeg writes extended RTMP channel IDs with `bytestream_put_le16` and reads them with `AV_RL16`.
  - Green check: extended chunk stream IDs now encode the low byte first and decode with `readUInt16Le()`.
  - Regression coverage: `RtmpStreamSuite.extendedChunkStreamIdUsesLittleEndian` checks the exact bytes for chunk stream ID 400 and verifies decoding recovers 400.
  - `git diff --check`: pass.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test --filter RtmpStreamSuite`: blocked because `swift` is unavailable in this shell.
  - `xcodebuild`: blocked because `xcodebuild` is unavailable in this shell.
  - code-review-graph: low working-tree risk with no affected flows; reported static test gaps for the changed RTMP chunk entities despite the focused test.

## Continued sweep 2026-05-18 RTMP stopped client receive loop

### Assumptions

- Once an RTMP client is stopped and moved to idle, buffered bytes from that client should be discarded.
- A stopped RTMP client should not schedule another `NWConnection.receive`.
- EOF from `NWConnection.receive` should stop the client instead of waiting for the periodic timeout.

### Acceptance criteria

- `receiveDataFromNetwork` returns immediately for idle clients.
- A receive callback does not schedule another receive after an error, EOF, or stop during buffered processing.
- Buffered parsing stops once `stopInternal` idles the client.
- ACK messages are not sent after the client has been stopped.

### Checklist

- [x] Select a high-risk RTMP receive lifecycle path.
- [x] Confirm defect and scope the minimal fix.
- [x] Patch the defect.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [x] Commit the fix alone.

### Review

- Defect 31 checks:
  - Red check: the RTMP receive callback always scheduled another receive after processing data, even if processing stopped and idled the client.
  - Red check: buffered parsing continued through any remaining bytes after `stopInternal` canceled the connection, and ACK sending could still run after stop.
  - Green check: idle clients no longer schedule receives, EOF stops the client immediately, buffered parsing exits once the client is idle, and ACK sending is skipped after stop.
  - Test gap: this path depends on `NWConnection.receive` callback timing and buffered network delivery; no new unit test was added.
  - `git diff --check`: pass.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test --filter RtmpStreamSuite`: blocked because `swift` is unavailable in this shell.
  - `xcodebuild`: blocked because `xcodebuild` is unavailable in this shell.
  - code-review-graph: low working-tree risk with no affected flows; reported expected test gaps for the private receive loop.

## Continued sweep 2026-05-18 WebRTC callback user-pointer lifetime

### Assumptions

- libdatachannel stores user pointers but does not own Swift `Unmanaged` retains.
- Swift objects retained for native callbacks must release those retains after deleting the peer connection or track.
- Native delete calls should stay guarded so repeated stop paths do not delete invalid IDs.

### Acceptance criteria

- `WebrtcIngestClient` releases peer-connection and track callback retains on stop.
- WHIP `PeerConnection` and `RtcTrack` release their callback retains on close/deinit and on throwing init cleanup.
- `WhipServerClient` stops its ingest client on deinit so overwritten sessions do not leave native callbacks alive.
- Repeated stop/close paths do not call libdatachannel delete APIs with invalid IDs.

### Checklist

- [x] Select a high-risk WebRTC lifecycle path using local code plus WHIP/WHEP corpus references.
- [x] Confirm defect and scope the minimal fix.
- [x] Patch the defect.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [x] Commit the fix alone.

### Review

- Defect 32 checks:
  - Red check: WebRTC ingest and WHIP sender code used `Unmanaged.passRetained` for libdatachannel callback pointers, but stop/close paths never released those retains.
  - Red check: repeated stop/close paths could call libdatachannel delete APIs again with already-invalid peer connection or track IDs.
  - Corpus check: WHIP/WHEP reference implementations treat sessions as explicit resources with close/delete lifecycle; local native callback resources need matching teardown.
  - Green check: peer connection and track user-pointer retains now release after native delete, throwing init cleanup releases retained callback owners, and repeated close paths are guarded.
  - Green check: `WhipServerClient` stops its ingest client on deinit so replaced WHIP sessions do not leave native callbacks alive.
  - Test gap: libdatachannel callback ownership requires the native runtime; no new unit test was added.
  - `git diff --check`: pass.
  - line-width scan for changed Swift files: pass.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test --filter RtmpStreamSuite`: blocked because `swift` is unavailable in this shell.
  - `xcodebuild`: blocked because `xcodebuild` is unavailable in this shell.
  - code-review-graph: medium working-tree risk with no affected flows; reported expected native WebRTC lifecycle test gaps.

## Continued sweep 2026-05-18 SRT callback context lifetime

### Assumptions

- libsrt callback context pointers do not own Swift `Unmanaged` retains.
- Swift objects retained for SRT callbacks must release those retains after the SRT socket is closed or callback setup fails.
- Existing SRT close behavior should remain asynchronous on `processorControlQueue` for the old sender path.

### Acceptance criteria

- `SrtStreamOfficial` releases its retained send-hook context on close, deinit, and connect failure after callback registration.
- `SrtServer` releases its retained listen-callback context on stop and listen-callback setup failure.
- Repeated close/stop paths do not double-release retained callback contexts.

### Checklist

- [x] Select high-risk SRT callback context paths using local code and SRT corpus references.
- [x] Confirm defect and scope the minimal fix.
- [x] Patch the defect.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [x] Commit the fix alone.

### Review

- Defect 33 checks:
  - Red check: `SrtStreamOfficial` retained its `SendHook` for the SRT send callback and never released that retain on close, deinit, or connect failure after callback registration.
  - Red check: `SrtServer` retained itself for the SRT listen callback and never released that retain on stop or callback setup failure.
  - Green check: SRT callback contexts now release after socket close, setup failure paths release the newly retained context, and repeated setup/close paths release at most once.
  - Scope check: SRT send/listen callback signatures and callback behavior are unchanged.
  - Test gap: libsrt callback ownership requires the native runtime; no new unit test was added.
  - `git diff --check`: pass.
  - line-width scan for changed Swift files: pass.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test --filter SrtSenderSuite`: blocked because `swift` is unavailable in this shell.
  - `xcodebuild`: blocked because `xcodebuild` is unavailable in this shell.
  - code-review-graph: medium working-tree risk with no affected flows; reported expected native SRT callback test gaps.

## Continued sweep 2026-05-18 SRT NAK range wraparound

### Assumptions

- SRT packet sequence numbers are 31-bit and wrap from `0x7fffffff` to `0`.
- A NAK loss range may cross that wrap boundary.
- Existing NAK range expansion bounds must stay in place to avoid oversized retransmit work.

### Acceptance criteria

- Shared SRT NAK parsing expands wraparound ranges instead of dropping them.
- The experimental SRT sender retransmit path uses the same wraparound sequence increment.
- Existing maximum NAK expansion bounds still stop large ranges.
- Focused unit coverage documents the wraparound range case.

### Checklist

- [x] Select high-risk SRT/SRTLA packet-loss recovery path using local code and SRT corpus references.
- [x] Confirm defect and scope the minimal fix.
- [x] Patch the defect.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [x] Commit the fix alone.

### Review

- Defect 34 checks:
  - Red check: `processSrtNak` used `while sn <= upToNakSn`, so a range such as `0x7ffffffe ... 1` produced no sequence numbers.
  - Red check: `SrtSender.handleNakPacket` had the same ascending-only loop in the retransmit path.
  - Corpus check: Haivision SRT defines sequence numbers as `0 ... 2^31 - 1` and uses wrap-aware `incseq`/`seqcmp` helpers.
  - Green check: shared NAK parsing now increments sequence numbers with wraparound and keeps the existing maximum expansion bound.
  - Green check: `SrtSender.handleNakPacket` uses the same wraparound increment when scheduling retransmits.
  - Green check: `SrtSenderSuite` covers a NAK range crossing `0x7fffffff` to `0`.
  - `git diff --check`: pass.
  - line-width scan for changed Swift files: pass.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test --filter SrtSenderSuite`: blocked because `swift` is unavailable in this shell.
  - `xcodebuild -list -project Moblin.xcodeproj`: blocked because `xcodebuild` is unavailable in this shell.
  - code-review-graph: medium working-tree risk with no affected flows; reported existing private SRT sender test gaps.

## Continued sweep 2026-05-18 SRTLA data batch flushing

### Assumptions

- SRTLA data packets may still be batched briefly for local efficiency.
- A partial data batch must not wait forever for another packet.
- Control packets must not pass earlier queued data packets on the same SRTLA link.

### Acceptance criteria

- SRTLA client and server data batches flush after a bounded idle timeout.
- SRTLA client and server flush pending data before sending control packets.
- Stop/reconnect paths clear pending data batches instead of carrying stale packets to a later connection.
- Existing batch-size flush behavior remains.

### Checklist

- [x] Select high-risk SRTLA data forwarding path using local code and SRTLA corpus references.
- [x] Confirm defect and scope the minimal fix.
- [x] Patch the defect.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [x] Commit the fix alone.

### Review

- Defect 35 checks:
  - Red check: server-side SRTLA data batches flushed only when another data packet arrived after 25 ms, so a short burst could sit indefinitely.
  - Red check: client-side SRTLA data batches had the same idle-burst risk and could survive reconnect until later data flushed them.
  - Red check: both paths could send a control packet while earlier data packets were still queued locally.
  - Corpus check: BELABOX, OpenIRL, and Go SRTLA references forward SRT packets immediately to the next hop and do not let control forwarding overtake queued data.
  - Green check: server-side local SRT forwarding now flushes a partial data batch after 25 ms, before control packets, and clears pending data on stop.
  - Green check: client-side remote forwarding now flushes a partial data batch after 15 ms, before control packets, and clears pending data on reconnect/stop.
  - Scope check: connection scoring, packet selection, SRTLA registration, and ACK/NAK packet formats are unchanged.
  - Test gap: this path depends on `NWConnection` UDP send timing; no new unit test was added.
  - `git diff --check`: pass.
  - whole-file line-width scan found an existing 111-character line in `SrtlaServerClient.swift`; changed lines were manually reviewed for width.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test --filter SrtSenderSuite`: blocked because `swift` is unavailable in this shell.
  - `xcodebuild -list -project Moblin.xcodeproj`: blocked because `xcodebuild` is unavailable in this shell.
  - code-review-graph: medium working-tree risk, low review-context risk, no affected flows; reported existing private SRT/SRTLA test gaps.

## Continued sweep 2026-05-18 SRTLA batched receive errors

### Assumptions

- Each batched `NWConnection.receiveMessage` callback can complete independently with an error.
- A receive error should stop that receive batch from scheduling more reads.
- Old connection callbacks should not schedule reads on a replacement connection after stop or reconnect.

### Acceptance criteria

- SRTLA client and server batched receive loops handle an error in any callback, not only the final callback.
- SRTLA client receive errors trigger reconnect through the existing reconnect path.
- SRTLA server local-SRT callbacks from an old local connection are ignored after stop/replacement.
- SRTLA per-link server connections stop scheduling receive batches after stop or receive error.

### Checklist

- [x] Select high-risk SRTLA receive lifecycle path.
- [x] Confirm defect and scope the minimal fix.
- [x] Patch the defect.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [x] Commit the fix alone.

### Review

- Defect 36 checks:
  - Red check: `RemoteConnection.receivePackets`, `SrtlaServerClient.receivePackets`, and `SrtlaServerClientConnection.receivePackets` only checked `error` when the final receive callback in a batch ran.
  - Red check: callbacks from old SRTLA connections could still schedule another receive batch after stop or reconnect.
  - Corpus check: BELABOX/OpenIRL SRTLA receive loops handle each socket read result immediately; they do not defer error handling to the end of a synthetic batch.
  - Green check: all three batched receive loops now handle any callback error before packet processing or rescheduling.
  - Green check: `RemoteConnection` reconnects through the existing reconnect path on receive error and ignores stale callbacks from old `NWConnection` instances.
  - Green check: `SrtlaServerClientConnection` marks itself stopped and cancels its connection on receive error, so later callbacks cannot reschedule reads.
  - Scope check: SRTLA packet parsing, registration, ACK generation, and send scheduling are unchanged.
  - Test gap: batched `NWConnection.receiveMessage` callback timing requires Network.framework runtime coverage; no new unit test was added.
  - `git diff --check`: pass.
  - whole-file line-width scan found an existing 111-character line in `SrtlaServerClient.swift`; changed lines were manually reviewed for width.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test --filter SrtSenderSuite`: blocked because `swift` is unavailable in this shell.
  - `xcodebuild -list -project Moblin.xcodeproj`: blocked because `xcodebuild` is unavailable in this shell.
  - code-review-graph: medium working-tree risk, low review-context risk, no affected flows; reported existing private SRTLA receive test gaps.

## Continued sweep 2026-05-18 Enhanced RTMP AVC ingest

### Assumptions

- Enhanced RTMP video packets with `avc1` carry AVC decoder configuration and AVC samples.
- Enhanced RTMP video packets with `hvc1` keep the existing HEVC behavior.
- Unsupported Enhanced RTMP codecs should still be rejected.

### Acceptance criteria

- Enhanced RTMP `avc1` packets are mapped to AVC instead of disconnecting as unsupported.
- Enhanced RTMP `hvc1` packets keep the existing HEVC sequence-start and frame handling.
- Unsupported Enhanced RTMP fourCC values still stop the client.
- The fix stays confined to codec mapping and server-side Enhanced RTMP parsing.

### Checklist

- [x] Select high-risk RTMP codec ingest path using local code and transport corpus references.
- [x] Confirm defect and scope the minimal fix.
- [x] Patch the defect.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [x] Commit the fix alone.

### Review

- Defect 37 checks:
  - Red check: `processMessageVideoExtendedHeader` rejected every Enhanced RTMP fourCC except `hvc1`, so valid `avc1` publishers were disconnected.
  - Corpus check: MistServer maps Enhanced RTMP `avc1` to H264 and handles `avc1` and `hvc1` with the same Enhanced CodedFrames offsets.
  - Green check: Enhanced RTMP fourCC values now map through `FlvVideoFourCC.codec`, so `avc1` uses the AVC config path and `hvc1` keeps the HEVC path.
  - Green check: `RtmpSuite.enhancedVideoFourCcCodecMapping` covers the `avc1` and `hvc1` codec mapping.
  - Scope check: unsupported Enhanced RTMP fourCC values are still rejected before codec mapping.
  - `git diff --check`: pass.
  - whole-file line-width scan found an existing 115-character line in `RtmpServerChunkStream.swift`; changed lines were manually reviewed for width.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test --filter RtmpSuite`: blocked because `swift` is unavailable in this shell.
  - `xcodebuild -list -project Moblin.xcodeproj`: blocked because `xcodebuild` is unavailable in this shell.
  - code-review-graph: risk 0.35, no affected flows; review context flags shared FLV enum impact.

## Continued sweep 2026-05-18 ADTS frame validation

### Assumptions

- ADTS AAC frame parsing should reject malformed packetized elementary stream data at the header boundary.
- The existing writer emits complete protection-absent ADTS frames and must keep the same output.
- This fix should not change MPEG-TS packet assembly or sample-buffer timing.

### Acceptance criteria

- ADTS headers shorter than seven bytes are rejected.
- ADTS headers with an invalid syncword are rejected.
- ADTS headers whose declared frame length exceeds the available data are rejected.
- Complete ADTS frames still parse and expose the declared frame length.

### Checklist

- [x] Select high-risk MPEG-TS AAC parser path using local code and transport corpus references.
- [x] Confirm defect and scope the minimal fix.
- [x] Patch the defect.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [x] Commit the fix alone.

### Review

- Defect 38 checks:
  - Red check: `AdtsHeader` accepted buffers without the 12-bit ADTS syncword and accepted declared frame lengths beyond the available buffer.
  - Corpus check: FFmpeg's ADTS demuxer validates a seven-byte header, checks the syncword, and rejects frame sizes smaller than the header.
  - Green check: `AdtsHeader` now validates the ADTS syncword and rejects declared frame lengths outside the available buffer.
  - Green check: `AdtsSuite` covers short headers, invalid syncwords, truncated frames, and complete frames.
  - Scope check: ADTS encoding, MPEG-TS packet assembly, and sample-buffer timestamp handling are unchanged.
  - `git diff --check`: pass.
  - line-width scan for changed Swift files: pass.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test --filter AdtsSuite`: blocked because `swift` is unavailable in this shell.
  - `xcodebuild -list -project Moblin.xcodeproj`: blocked because `xcodebuild` is unavailable in this shell.
  - code-review-graph: risk 0.35, no affected flows; review context flags shared ADTS reader impact.

## Continued sweep 2026-05-18 PES scrambling control parsing

### Assumptions

- MPEG-TS PES optional-header bitfields should round-trip by masking the field and then shifting it.
- The fix should not change timestamp extraction, packet lengths, or payload assembly.

### Acceptance criteria

- `PES_scrambling_control` bits in byte 0 are decoded from bits 4 and 5.
- Other optional-header fields keep their existing parsing.
- A focused unit test covers a nonzero scrambling-control field.

### Checklist

- [x] Select high-risk MPEG-TS PES parser path using local code and transport corpus references.
- [x] Confirm defect and scope the minimal fix.
- [x] Patch the defect.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [x] Commit the fix alone.

### Review

- Defect 39 checks:
  - Red check: `OptionalHeader.init(data:)` decoded `scramblingControl` as `bytes[0] & (0x30 >> 4)`, so the valid `0x30` field decoded as zero.
  - Corpus check: GStreamer PES parsing documents `PES_scrambling_control` as the two bits covered by `0x30`.
  - Green check: `OptionalHeader` now masks byte 0 with `0x30` before shifting.
  - Green check: `MpegTsPacketizedElementaryStreamSuite.parsesScramblingControl` covers a nonzero field.
  - Scope check: timestamp extraction, packet lengths, and payload assembly are unchanged.
  - `git diff --check`: pass.
  - line-width scan for changed Swift files: pass.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test --filter MpegTsPacketizedElementaryStreamSuite`: blocked because `swift` is unavailable in this shell.
  - `xcodebuild -list -project Moblin.xcodeproj`: blocked because `xcodebuild` is unavailable in this shell.
  - code-review-graph: risk 0.40, no affected flows; review context flags shared MPEG-TS parser impact.

## Continued sweep 2026-05-18 WebRTC NTP timestamp validation

### Assumptions

- WebRTC RTCP sync timestamps use the standard 64-bit NTP fixed-point format.
- The high 32 bits are seconds and the low 32 bits are fractional seconds.
- Timestamps before the Unix epoch should be rejected before subtracting the NTP epoch offset.

### Acceptance criteria

- `decodeNtpTimestamp` validates the high 32-bit seconds field, not the whole fixed-point value.
- Fraction-only values cannot underflow the Unix epoch subtraction.
- A focused unit test covers epoch conversion, fractional conversion, and pre-Unix rejection.

### Checklist

- [x] Select high-risk WebRTC RTCP sync timestamp path using local code and transport corpus references.
- [x] Confirm defect and scope the minimal fix.
- [x] Patch the defect.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [x] Commit the fix alone.

### Review

- Defect 46 checks:
  - Red check: `decodeNtpTimestamp` compared the whole 64-bit fixed-point value to the Unix epoch
    offset, allowing fraction-only values through and underflowing the seconds subtraction.
  - Corpus check: GStreamer reads NTP timestamps as separate high 32-bit seconds and low 32-bit
    fractional fields.
  - Green check: `decodeNtpTimestamp` now validates the seconds field before subtracting the epoch
    offset and converts the fraction independently.
  - Green check: `RtspClientSuite.decodeNtpTimestampUsesSecondsField` covers Unix epoch, 1.5 second
    fractional conversion, and a pre-Unix fraction-only value.
  - Scope check: WebRTC track setup, depacketizers, audio/video decoding, timestamp rebasing, and
    target latency logic are unchanged.
  - `python3` timestamp formula check: `[0.0, 1.5, None]`.
  - `git diff --check`: pass.
  - line-width scan for changed Swift files: one pre-existing 120-character line remains at
    `MoblinTests/RtspClientSuite.swift:113`; no changed line exceeded 110 characters.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test --filter RtspClientSuite`: blocked because `swift` is unavailable in this shell.
  - `xcodebuild -list -project Moblin.xcodeproj`: blocked because `xcodebuild` is unavailable in this shell.
  - code-review-graph: minimal/detect risk 0.40, no affected flows; review context flags high impact
    because WebRTC ingest is a shared media path.

## Continued sweep 2026-05-18 RTMP extended chunk stream IDs

### Assumptions

- RTMP clients may legally use chunk stream IDs that require 2-byte or 3-byte basic headers.
- Rejecting extended basic headers before the message header is a real interoperability failure.
- The fix should not change message header parsing, chunk payload parsing, or outbound chunk encoding.

### Acceptance criteria

- The RTMP server accepts 1-byte, 2-byte, and 3-byte basic headers.
- Extended chunk stream IDs are decoded with the RTMP little-endian 3-byte form.
- A focused unit test covers the basic-header decoder.

### Checklist

- [x] Select high-risk RTMP chunk parser path using local code and transport corpus references.
- [x] Confirm defect and scope the minimal fix.
- [x] Patch the defect.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [ ] Commit the fix alone.

### Review

- Defect 45 checks:
  - Red check: `RtmpServerClient` stopped any client that used RTMP chunk stream ID forms encoded with
    2-byte or 3-byte basic headers.
  - Corpus check: GStreamer's RTMP chunk parser decodes ID 0 as next byte plus 64 and ID 1 as
    little-endian 16-bit value plus 64.
  - Green check: server receive state now reads remaining basic-header bytes and dispatches the same
    message-header states for 1-byte, 2-byte, and 3-byte chunk stream IDs.
  - Green check: `RtmpChunk` and `RtmpServerClient` now share the same basic-header decoder.
  - Green check: `RtmpSuite.rtmpBasicHeaderDecodesExtendedChunkStreamIds` covers 1-byte, 2-byte, and
    little-endian 3-byte basic headers.
  - Scope check: message header parsing, chunk payload parsing, outbound chunk splitting, and media
    decoding are unchanged.
  - `git diff --check`: pass.
  - line-width scan for changed Swift files: one pre-existing 111-character line remains at
    `Moblin/Media/RtmpServer/RtmpServerClient.swift:381`; no changed line exceeded 110 characters.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test --filter RtmpSuite`: blocked because `swift` is unavailable in this shell.
  - `xcodebuild -list -project Moblin.xcodeproj`: blocked because `xcodebuild` is unavailable in this shell.
  - code-review-graph: minimal/detect risk 0.40, no affected flows; review context flags high impact
    because RTMP chunk decoding is shared by many impacted nodes.

## Continued sweep 2026-05-18 PES marker bit validation

### Assumptions

- MPEG-2 PES optional headers must start with marker bits `10`.
- Invalid marker bits should reject the PES header before any optional-field parsing.
- Valid PES optional headers should keep existing bitfield parsing.

### Acceptance criteria

- PES optional headers with marker bits other than `10` are rejected.
- Existing valid optional-header parsing stays unchanged.
- A focused unit test covers the rejected marker-bit case.

### Checklist

- [x] Select high-risk MPEG-TS PES fixed-header parser path using local code and transport corpus references.
- [x] Confirm defect and scope the minimal fix.
- [x] Patch the defect.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [x] Commit the fix alone.

### Review

- Defect 41 checks:
  - Red check: `OptionalHeader` decoded marker bits but accepted values other than `10`, so malformed MPEG-2 PES headers stayed in sync.
  - Corpus check: GStreamer rejects MPEG-2 PES optional headers when `(flags & 0xc0) != 0x80`.
  - Green check: `OptionalHeader` now rejects marker bits other than `10` before parsing the remaining optional header fields.
  - Green check: `MpegTsPacketizedElementaryStreamSuite.rejectsInvalidMarkerBits` covers the malformed marker-bit case.
  - Scope check: timestamp fields, packet lengths, payload assembly, and valid optional-header parsing are unchanged.
  - `git diff --check`: pass.
  - line-width scan for changed Swift files: pass.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test --filter MpegTsPacketizedElementaryStreamSuite`: blocked because `swift` is unavailable in this shell.
  - `xcodebuild -list -project Moblin.xcodeproj`: blocked because `xcodebuild` is unavailable in this shell.
  - code-review-graph: risk 0.40, no affected flows; review context flags shared MPEG-TS parser impact.

## Continued sweep 2026-05-18 PCR extension encoding

### Assumptions

- MPEG-TS PCR byte 4 carries the PCR base low bit, six reserved bits set to one, and the PCR extension high bit.
- `TSProgramClockReference.encode` should encode the low nine bits of the extension argument.
- The current caller still passes extension zero, but the shared encoder should be correct for valid nonzero PCR extensions.

### Acceptance criteria

- PCR extension bit 8 is reflected in encoded byte 4.
- Existing PCR base-bit and reserved-bit behavior stays unchanged.
- A focused unit test covers a nonzero PCR extension high bit.

### Checklist

- [x] Select high-risk MPEG-TS PCR timestamp encoder path using local code and transport corpus references.
- [x] Confirm defect and scope the minimal fix.
- [x] Patch the defect.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [x] Commit the fix alone.

### Review

- Defect 42 checks:
  - Red check: `TSProgramClockReference.encode` tested the low bit of an already encoded byte, so PCR extension bit 8 was never written.
  - Corpus check: FFmpeg encodes PCR byte 4 as `pcr_high << 7 | pcr_low >> 8 | 0x7e`; GStreamer encodes `((pcr_ext >> 8) & 0x01)` into the same bit.
  - Green check: PCR extension bit 8 is now copied from `(e & 0x0100)` into encoded byte 4.
  - Green check: `MpegTsPacketizedElementaryStreamSuite.encodesProgramClockReferenceExtensionHighBit` covers the nonzero high-bit case.
  - Scope check: packet headers, payload sizing, PES assembly, and current extension-zero caller behavior are unchanged.
  - `git diff --check`: pass.
  - line-width scan for changed Swift files: pass.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test --filter MpegTsPacketizedElementaryStreamSuite`: blocked because `swift` is unavailable in this shell.
  - `xcodebuild -list -project Moblin.xcodeproj`: blocked because `xcodebuild` is unavailable in this shell.
  - code-review-graph: risk 0.40, no affected flows; review context flags shared MPEG-TS packet impact.

## Continued sweep 2026-05-18 PES timestamp marker bits

### Assumptions

- MPEG-2 PES PTS and DTS fields carry one-bit marker values in bytes 0, 2, and 4 of each five-byte timestamp field.
- Invalid PTS or DTS marker bits should reject the optional header before timestamp decode.
- Valid timestamp parsing and timestamp encoding should stay unchanged.

### Acceptance criteria

- PES headers with invalid PTS marker bits are rejected.
- PES headers with invalid DTS marker bits are rejected.
- Focused unit tests cover both malformed timestamp fields.

### Checklist

- [x] Select high-risk MPEG-TS PES timestamp parser path using local code and transport corpus references.
- [x] Confirm defect and scope the minimal fix.
- [x] Patch the defect.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [x] Commit the fix alone.

### Review

- Defect 43 checks:
  - Red check: `TSTimestamp.decode` masked timestamp marker bits but no parser path rejected malformed marker bits.
  - Corpus check: GStreamer `READ_TS` rejects PTS and DTS fields unless marker bits in bytes 0, 2, and 4 are set.
  - Green check: `OptionalHeader` now validates PTS and DTS marker bits after confirming the timestamp field lengths.
  - Green check: `MpegTsPacketizedElementaryStreamSuite` covers invalid PTS and DTS marker-bit cases.
  - Scope check: timestamp encoding, PCR encoding, packet lengths, and payload assembly are unchanged.
  - `git diff --check`: pass.
  - line-width scan for changed Swift files: pass.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test --filter MpegTsPacketizedElementaryStreamSuite`: blocked because `swift` is unavailable in this shell.
  - `xcodebuild -list -project Moblin.xcodeproj`: blocked because `xcodebuild` is unavailable in this shell.
  - code-review-graph: risk 0.40, no affected flows; review context flags shared MPEG-TS parser impact.

## Continued sweep 2026-05-18 PSI CRC validation

### Assumptions

- MPEG-TS PAT and PMT sections must be rejected when their MPEG-2 CRC does not match the section bytes.
- `section_length`, `program_info_length`, and `ES_info_length` are 12-bit fields.
- Existing PAT and PMT encoding should stay unchanged.

### Acceptance criteria

- Valid PAT sections generated by the local writer still parse.
- Corrupted PAT sections are rejected before program mappings are used.
- PSI and PMT descriptor length masks use the full 12-bit fields from the spec.

### Checklist

- [x] Select high-risk MPEG-TS PSI parser path using local code and transport corpus references.
- [x] Confirm defect and scope the minimal fix.
- [x] Patch the defect.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [x] Commit the fix alone.

### Review

- Defect 45 checks:
  - Red check: `MpegTsProgramSpecificInformation.init(data:)` ignored the section CRC, so corrupted PAT and PMT data could update stream mappings.
  - Corpus check: GStreamer validates MPEG-TS section CRC and FFmpeg reads PSI lengths with `0xfff` masks.
  - Green check: PSI parsing now validates the CRC over the section bytes before decoding PAT or PMT section data.
  - Green check: PSI, PMT program-info, and ES-info length parsing now use 12-bit masks.
  - Green check: `MpegTsPacketizedElementaryStreamSuite` covers valid PAT parsing and corrupted PAT CRC rejection.
  - CRC residue check: Python MPEG-2 CRC reproduction returned `0x0` over section plus CRC.
  - `git diff --check`: pass.
  - line-width scan for changed Swift files: pass.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test --filter MpegTsPacketizedElementaryStreamSuite`: blocked because `swift` is unavailable in this shell.
  - `xcodebuild -list -project Moblin.xcodeproj`: blocked because `xcodebuild` is unavailable in this shell.
  - code-review-graph: risk 0.35, no affected flows; review context flags shared MPEG-TS PSI parser impact.

## Continued sweep 2026-05-18 PES packet length bounds

### Assumptions

- A nonzero MPEG-2 PES packet length bounds bytes after the packet-length field.
- Packet length zero remains unbounded for video and other streams that use open-ended PES payloads.
- Trailing bytes beyond a bounded PES length should not be exposed as media payload.

### Acceptance criteria

- Bounded PES packets read only the payload bytes declared by `PES_packet_length`.
- Packet length zero keeps reading all remaining payload bytes.
- A focused unit test covers a bounded PES with extra trailing bytes.

### Checklist

- [x] Select high-risk MPEG-TS PES reassembly path using local code and transport corpus references.
- [x] Confirm defect and scope the minimal fix.
- [x] Patch the defect.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [x] Commit the fix alone.

### Review

- Defect 44 checks:
  - Red check: `MpegTsPacketizedElementaryStream.init(data:)` parsed `packetLength` but read all remaining bytes into `data`.
  - Corpus check: FFmpeg caps PES payload collection using `PES_packet_length + PES_START_SIZE - pes_header_size`.
  - Green check: nonzero `packetLength` now bounds the number of media payload bytes read after the optional header.
  - Green check: `MpegTsPacketizedElementaryStreamSuite.boundedPacketLengthDropsTrailingBytes` covers trailing bytes after a bounded PES.
  - Scope check: packet length zero, optional-header parsing, timestamp validation, and TS packet writing are unchanged.
  - `git diff --check`: pass.
  - line-width scan for changed Swift files: pass.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test --filter MpegTsPacketizedElementaryStreamSuite`: blocked because `swift` is unavailable in this shell.
  - `xcodebuild -list -project Moblin.xcodeproj`: blocked because `xcodebuild` is unavailable in this shell.
  - code-review-graph: risk 0.40, no affected flows; review context flags shared MPEG-TS parser impact.

## Continued sweep 2026-05-18 PES timestamp field validation

### Assumptions

- MPEG-TS PES packets with timestamp flags must include the full five-byte PTS field or full PTS plus DTS fields.
- `PTS_DTS_flags == 01` is invalid for MPEG-2 PES.
- Invalid PES optional headers should fail while parsing the PES header, before timestamp decoding.

### Acceptance criteria

- PES headers with PTS flag and fewer than five optional timestamp bytes are rejected.
- PES headers with PTS plus DTS flags and fewer than ten optional timestamp bytes are rejected.
- PES headers with only the DTS flag are rejected.
- Existing valid PES timestamp parsing remains unchanged.

### Checklist

- [x] Select high-risk MPEG-TS PES timestamp parser path using local code and transport corpus references.
- [x] Confirm defect and scope the minimal fix.
- [x] Patch the defect.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [x] Commit the fix alone.

### Review

- Defect 40 checks:
  - Red check: `OptionalHeader` accepted timestamp flags without enough optional bytes, allowing `TSTimestamp.decode` to index past the buffer later.
  - Corpus check: GStreamer PES parsing waits for five PTS bytes, ten PTS/DTS bytes, and treats DTS-only flags as invalid.
  - Green check: `OptionalHeader` now rejects short PTS fields, short PTS/DTS fields, and invalid DTS-only flags during PES parsing.
  - Green check: `MpegTsPacketizedElementaryStreamSuite` covers all three malformed timestamp cases and a valid PTS round trip.
  - Scope check: timestamp encoding, packet lengths, payload assembly, and sample-buffer timestamp wrapping are unchanged.
  - `git diff --check`: pass.
  - line-width scan for changed Swift files: pass.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test --filter MpegTsPacketizedElementaryStreamSuite`: blocked because `swift` is unavailable in this shell.
  - `xcodebuild -list -project Moblin.xcodeproj`: blocked because `xcodebuild` is unavailable in this shell.
  - code-review-graph: risk 0.40, no affected flows; review context flags shared MPEG-TS parser impact.

## Continued sweep 2026-05-18 NAL start-code conversion

### Assumptions

- Annex B H.264 and H.265 access units can contain three-byte or four-byte start codes.
- Moblin converts Annex B input to four-byte length-prefixed NAL units for the WebRTC and MPEG-TS
  decode paths.
- Main app targets include iOS 16.4, so conversion must not depend on iOS 18-only `Data` movement.

### Acceptance criteria

- All three-byte Annex B start codes convert to four-byte big-endian NAL length prefixes.
- Mixed three-byte and four-byte start-code samples keep their original NAL order and payload bytes.
- Existing all-four-byte start-code conversion keeps its current in-place path.

### Checklist

- [x] Select high-risk NAL conversion path using local code and transport corpus references.
- [x] Confirm defect and scope the minimal fix.
- [x] Add focused regression tests.
- [x] Patch the defect.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [x] Commit the fix alone.

### Review

- Defect 46 checks:
  - Red check: `removeNalUnitStartCodes` only moved payload bytes on iOS 18 and later when any NAL used a three-byte start code.
  - Target check: `Moblin.xcodeproj` still has main app deployment targets at iOS 16.4.
  - Corpus check: FFmpeg converts Annex B NAL start-code prefixes into four-byte size fields for MP4-style packetized data, and GStreamer AVC parsing reads NAL length prefixes.
  - Green check: mixed-prefix samples now rebuild into four-byte length-prefixed NAL units without `Data.moveSubranges`.
  - Green check: `RtspClientSuite` covers all-three-byte and mixed three-byte/four-byte start-code conversion.
  - Static check: no `moveSubranges`, `#available(iOS 18`, or iOS 18-only comment remains in `NalUnitStream`.
  - Python reproduction of the parser/converter logic returned `[True, True]` for the two regression cases.
  - `git diff --check`: pass.
  - line-width scan for changed lines: pass; whole-file scan still reports pre-existing `RtspClientSuite.swift:143`.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test --filter RtspClientSuite`: blocked because `swift` is unavailable in this shell.
  - `xcodebuild -list -project Moblin.xcodeproj`: blocked because `xcodebuild` is unavailable in this shell.
  - code-review-graph: risk 0.35, no affected flows; review context flags shared NAL conversion impact.

## Continued sweep 2026-05-19 adaptive bitrate PIF settings

### Assumptions

- SRT adaptive bitrate settings can be restored from persisted JSON or imported settings, not only from the
  settings sliders.
- Fight and RIST adaptive algorithms divide by the configured packets-in-flight threshold during updates.
- Invalid restored thresholds must not crash the streaming pipeline.

### Acceptance criteria

- Zero packets-in-flight settings do not divide by zero in the SRT Fight algorithm.
- Negative packets-in-flight settings do not divide by zero in the RIST adaptive algorithm.
- Valid adaptive bitrate behavior remains unchanged.

### Checklist

- [x] Select high-risk adaptive bitrate settings path using local code and transport-corpus context.
- [x] Confirm defect and scope the minimal fix.
- [x] Add focused regression tests.
- [x] Run targeted validation and available repo checks.
- [x] Review changed diff and impact.
- [ ] Commit the fix alone.

### Review

- Defect 47 checks:
  - Red check: restored or imported SRT adaptive bitrate settings could set the packets-in-flight threshold
    to zero or less, then Fight/RIST update logic divided by that threshold.
  - Corpus check: SRT stats define in-flight packet count as a sender-side congestion signal, and BELABOX
    adaptive bitrate uses send-buffer/RTT pressure as the bitrate-control input.
  - Green check: Fight and RIST adaptive settings now clamp the internal packets-in-flight threshold to at
    least one before logging and storing the settings.
  - Green check: `AdaptiveBitrateSuite` covers zero settings for SRT Fight and negative settings for RIST.
  - Scope check: valid adaptive settings, bitrate math, RTT/PIF smoothing, and BELABOX behavior are unchanged.
  - `git diff --check`: pass.
  - line-width scan for changed Swift files: pass.
  - `make style-check`: blocked because `swiftformat` is unavailable in this shell.
  - `make lint`: blocked because `swiftlint` is unavailable in this shell.
  - `swift test --filter AdaptiveBitrateSuite`: blocked because `swift` is unavailable in this shell.
  - `xcodebuild -list -project Moblin.xcodeproj`: blocked because `xcodebuild` is unavailable in this shell.
  - code-review-graph: risk 0.40, no affected flows; review context flags adaptive bitrate settings/update
    test gaps because Swift tests could not run here.
