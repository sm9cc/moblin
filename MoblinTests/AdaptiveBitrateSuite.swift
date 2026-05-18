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

private func makeSettings(packetsInFlight: Int64) -> AdaptiveBitrateSettings {
    AdaptiveBitrateSettings(packetsInFlight: packetsInFlight,
                            rttDiffHighFactor: 0.9,
                            rttDiffHighAllowedSpike: 50,
                            rttDiffHighMinDecrease: 250_000,
                            pifDiffIncreaseFactor: 100_000,
                            minimumBitrate: 250_000)
}

private func update(belabox: AdaptiveBitrateSrtBelabox, bitrate: Int64) async throws {
    try await sleep(milliSeconds: 20)
    belabox.update(stats: makeStats(bitrate: bitrate))
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
    func belaboxIgnoresMissingSendRate() {
        let handler = Handler()
        let belabox = AdaptiveBitrateSrtBelabox(targetBitrate: 5_000_000, delegate: handler)
        belabox.setSettings(settings: adaptiveBitrateBelaboxSettings)
        belabox.update(stats: StreamStats(rttMs: 30,
                                          packetsInFlight: 15,
                                          transportBitrate: 5_000_000,
                                          latency: 3000,
                                          mbpsSendRate: nil,
                                          relaxed: false))
        #expect(belabox.getCurrentBitrate() == 1_000_000)
        #expect(handler.bitrates.isEmpty)
    }

    @Test
    func srtFightClampsZeroPacketsInFlightSettings() {
        let handler = Handler()
        let fight = AdaptiveBitrateSrtFight(targetBitrate: 5_000_000, delegate: handler)
        fight.setSettings(settings: makeSettings(packetsInFlight: 0))
        fight.update(stats: makeStats(bitrate: 5_000_000))
        #expect(fight.getCurrentBitrate() >= 250_000)
    }

    @Test
    func ristClampsNegativePacketsInFlightSettings() {
        let handler = Handler()
        let rist = AdaptiveBitrateRistExperiment(targetBitrate: 5_000_000, delegate: handler)
        rist.setSettings(settings: makeSettings(packetsInFlight: -1))
        rist.update(stats: makeStats(bitrate: 5_000_000))
        #expect(rist.getCurrentBitrate() >= 250_000)
    }
}
