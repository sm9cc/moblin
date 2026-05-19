import AVFoundation
import Collections
@testable import Moblin
import Testing

private class Handler {
    var bitrates: Deque<UInt32> = []
}

extension Handler: AdaptiveBitrateDelegate {
    func adaptiveBitrateSetVideoStreamBitrate(bitrate: UInt32) {
        bitrates.append(bitrate)
    }
}

private func makeStats(bitrate: Int64) -> StreamStats {
    StreamStats(rttMs: 30,
                packetsInFlight: 15,
                transportBitrate: bitrate,
                latency: 3000,
                mbpsSendRate: Double(bitrate),
                relaxed: false)
}

private func update(belabox: AdaptiveBitrateSrtBelabox, bitrate: Int64) async throws {
    try await sleep(milliSeconds: 20)
    belabox.update(stats: makeStats(bitrate: bitrate))
}

private func makeFpsStats(rttMs: Double = 40,
                          packetsInFlight: Double = 10,
                          transportBitrate: Int64? = 6_000_000,
                          mbpsSendRate: Double? = 3,
                          videoBitrate: UInt32? = 4_000_000,
                          packetsDropped: Int32? = nil,
                          packetsRetransmitted: Int32? = nil,
                          packetsReceivedNak: Int32? = nil,
                          failedEncodings: Int? = nil,
                          thermalState: ProcessInfo.ThermalState? = .nominal,
                          isLowPowerMode: Bool = false,
                          batteryLevel: Double? = 0.5,
                          batteryCharging: Bool? = true,
                          cpuUsage: Int? = 20) -> StreamStats
{
    StreamStats(rttMs: rttMs,
                packetsInFlight: packetsInFlight,
                transportBitrate: transportBitrate,
                latency: 3000,
                mbpsSendRate: mbpsSendRate,
                relaxed: false,
                videoBitrate: videoBitrate,
                packetsDropped: packetsDropped,
                packetsRetransmitted: packetsRetransmitted,
                packetsReceivedNak: packetsReceivedNak,
                failedEncodings: failedEncodings,
                thermalState: thermalState,
                isLowPowerMode: isLowPowerMode,
                batteryLevel: batteryLevel,
                batteryCharging: batteryCharging,
                cpuUsage: cpuUsage)
}

private func update(adaptiveFps: AdaptiveFps, stats: StreamStats, count: Int) -> [AdaptiveFpsAction] {
    var actions: [AdaptiveFpsAction] = []
    for _ in 0 ..< count {
        if let action = adaptiveFps.update(stats: stats) {
            actions.append(action)
        }
    }
    return actions
}

struct AdaptiveBitrateSuite {
    @Test
    func belaboxStartAtLowerThanTarget() async throws {
        let handler = Handler()
        let belabox = AdaptiveBitrateSrtBelabox(targetBitrate: 5_000_000, delegate: handler)
        belabox.setSettings(settings: adaptiveBitrateBelaboxSettings)
        #expect(belabox.getCurrentBitrate() == 1_000_000)
        #expect(belabox.getCurrentMaximumBitrateInKbps() == 1000)
        #expect(handler.bitrates.isEmpty)
        try await update(belabox: belabox, bitrate: 5_000_000)
        #expect(belabox.getCurrentBitrate() == 1_133_333)
    }

    @Test
    func belaboxTransportBitrateLimit() async throws {
        let handler = Handler()
        let belabox = AdaptiveBitrateSrtBelabox(targetBitrate: 5_000_000, delegate: handler)
        belabox.setSettings(settings: adaptiveBitrateBelaboxSettings)
        #expect(belabox.getCurrentBitrate() == 1_000_000)
        #expect(belabox.getCurrentMaximumBitrateInKbps() == 1000)
        #expect(handler.bitrates.isEmpty)
        let transportBitrate5Mbps: Int64 = 5_000_000
        while belabox.getCurrentBitrate() != 5_000_000 {
            try await update(belabox: belabox, bitrate: transportBitrate5Mbps)
        }
        let transportBitrate1Mbps: Int64 = 1_000_000
        try await update(belabox: belabox, bitrate: transportBitrate1Mbps)
        #expect(belabox.getCurrentBitrate() == 2_000_000)
        #expect(handler.bitrates.last == 2_000_000)
    }

    @Test
    func adaptiveFpsStableConditionsKeepConfiguredFps() {
        let adaptiveFps = AdaptiveFps(configuredFps: 60, minimumFps: 30)
        let actions = update(adaptiveFps: adaptiveFps, stats: makeFpsStats(), count: 200)
        #expect(actions.isEmpty)
        #expect(adaptiveFps.getCurrentFps() == 60)
    }

    @Test
    func adaptiveFpsWeakTransportReducesOnePresetAtATime() {
        let adaptiveFps = AdaptiveFps(configuredFps: 60, minimumFps: 30)
        var nak: Int32 = 0
        var retransmitted: Int32 = 0
        var actions: [AdaptiveFpsAction] = []
        for _ in 0 ..< 80 {
            nak += 8
            retransmitted += 8
            if let action = adaptiveFps.update(stats: makeFpsStats(rttMs: 320,
                                                                   packetsInFlight: 120,
                                                                   transportBitrate: 2_000_000,
                                                                   mbpsSendRate: 5,
                                                                   videoBitrate: 5_000_000,
                                                                   packetsRetransmitted: retransmitted,
                                                                   packetsReceivedNak: nak))
            {
                actions.append(action)
            }
        }
        #expect(actions.map(\.fps) == [50, 30])
        #expect(adaptiveFps.getCurrentFps() == 30)
    }

    @Test
    func adaptiveFpsLargePacketCounterDeltaIsSafe() {
        let adaptiveFps = AdaptiveFps(configuredFps: 60, minimumFps: 30)
        _ = adaptiveFps.update(stats: makeFpsStats(packetsDropped: 0))
        let action = adaptiveFps.update(stats: makeFpsStats(packetsDropped: Int32.max))
        #expect(action?.fps == 50)
    }

    @Test
    func adaptiveFpsEncoderPressureReducesFps() {
        let adaptiveFps = AdaptiveFps(configuredFps: 30, minimumFps: 15)
        var actions: [AdaptiveFpsAction] = []
        for failedEncodings in 0 ..< 40 {
            if let action = adaptiveFps.update(stats: makeFpsStats(failedEncodings: failedEncodings)) {
                actions.append(action)
            }
        }
        #expect(actions.map(\.fps) == [25])
        #expect(adaptiveFps.getCurrentFps() == 25)
    }

    @Test
    func adaptiveFpsThermalAndPowerPressureReduceFps() {
        let adaptiveFps = AdaptiveFps(configuredFps: 30, minimumFps: 15)
        let actions = update(
            adaptiveFps: adaptiveFps,
            stats: makeFpsStats(thermalState: .serious,
                                isLowPowerMode: true,
                                batteryLevel: 0.08,
                                batteryCharging: false),
            count: 40
        )
        #expect(actions.map(\.fps) == [25])
        #expect(adaptiveFps.getCurrentFps() == 25)
    }

    @Test
    func adaptiveFpsMissingNetworkMetricsDoNotReduceFps() {
        let adaptiveFps = AdaptiveFps(configuredFps: 60, minimumFps: 30)
        let actions = update(adaptiveFps: adaptiveFps,
                             stats: makeFpsStats(rttMs: 0,
                                                 transportBitrate: nil,
                                                 mbpsSendRate: nil,
                                                 videoBitrate: nil,
                                                 thermalState: nil,
                                                 batteryLevel: nil,
                                                 batteryCharging: nil,
                                                 cpuUsage: nil),
                             count: 200)
        #expect(actions.isEmpty)
        #expect(adaptiveFps.getCurrentFps() == 60)
    }

    @Test
    func adaptiveFpsRecoveryRequiresStableSamples() {
        let adaptiveFps = AdaptiveFps(configuredFps: 60, minimumFps: 30)
        var nak: Int32 = 0
        var retransmitted: Int32 = 0
        for _ in 0 ..< 80 {
            nak += 8
            retransmitted += 8
            _ = adaptiveFps.update(stats: makeFpsStats(rttMs: 320,
                                                       packetsInFlight: 120,
                                                       transportBitrate: 2_000_000,
                                                       mbpsSendRate: 5,
                                                       videoBitrate: 5_000_000,
                                                       packetsRetransmitted: retransmitted,
                                                       packetsReceivedNak: nak))
        }
        #expect(adaptiveFps.getCurrentFps() == 30)
        let earlyRecoveryActions = update(adaptiveFps: adaptiveFps, stats: makeFpsStats(), count: 40)
        #expect(earlyRecoveryActions.isEmpty)
        let recoveryActions = update(adaptiveFps: adaptiveFps, stats: makeFpsStats(), count: 180)
        #expect(recoveryActions.map(\.fps) == [50, 60])
        #expect(adaptiveFps.getCurrentFps() == 60)
    }

    @Test
    func adaptiveFpsMinimumBoundsAreEnforced() {
        let adaptiveFps = AdaptiveFps(configuredFps: 60, minimumFps: 15)
        var nak: Int32 = 0
        var retransmitted: Int32 = 0
        for _ in 0 ..< 200 {
            nak += 10
            retransmitted += 10
            _ = adaptiveFps.update(stats: makeFpsStats(rttMs: 350,
                                                       packetsInFlight: 160,
                                                       transportBitrate: 1_000_000,
                                                       mbpsSendRate: 5,
                                                       videoBitrate: 6_000_000,
                                                       packetsRetransmitted: retransmitted,
                                                       packetsReceivedNak: nak))
        }
        #expect(adaptiveFps.getCurrentFps() == 15)
    }
}
