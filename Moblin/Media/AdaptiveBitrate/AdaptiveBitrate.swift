import Collections
import Foundation

let adaptiveBitrateStart: Int64 = 1_000_000
let adaptiveBitrateTransportMinimum = adaptiveBitrateStart

private let adaptiveFpsDecreaseCooldownSamples = 50
private let adaptiveFpsRestoreHoldSamples = 60
private let adaptiveFpsRestoreCooldownSamples = 50

protocol AdaptiveBitrateDelegate: AnyObject {
    func adaptiveBitrateSetVideoStreamBitrate(bitrate: UInt32)
}

struct StreamRuntimeConditions {
    let thermalState: ProcessInfo.ThermalState
    let isLowPowerMode: Bool
    let batteryLevel: Double
    let batteryCharging: Bool
    let cpuUsage: Int?
}

struct StreamStats {
    let rttMs: Double
    let packetsInFlight: Double
    let transportBitrate: Int64?
    let latency: Int32?
    let mbpsSendRate: Double?
    let relaxed: Bool?
    let videoBitrate: UInt32?
    let packetsDropped: Int32?
    let packetsRetransmitted: Int32?
    let packetsReceivedNak: Int32?
    let failedEncodings: Int?
    let thermalState: ProcessInfo.ThermalState?
    let isLowPowerMode: Bool
    let batteryLevel: Double?
    let batteryCharging: Bool?
    let cpuUsage: Int?

    // To not push too high bitrate after static scene. The encoder may output way
    // lower bitrate than configured.
    func limitByTransportBitrate(bitrate: Int64) -> Int64 {
        guard let transportBitrate else {
            return bitrate
        }
        let maximumBitrate = max(transportBitrate + adaptiveBitrateTransportMinimum,
                                 (17 * transportBitrate) / 10)
        return min(bitrate, maximumBitrate)
    }
}

extension StreamStats {
    init(rttMs: Double,
         packetsInFlight: Double,
         transportBitrate: Int64?,
         latency: Int32?,
         mbpsSendRate: Double?,
         relaxed: Bool?,
         videoBitrate: UInt32? = nil,
         packetsDropped: Int32? = nil,
         packetsRetransmitted: Int32? = nil,
         packetsReceivedNak: Int32? = nil,
         failedEncodings: Int? = nil,
         thermalState: ProcessInfo.ThermalState? = nil,
         isLowPowerMode: Bool = false,
         batteryLevel: Double? = nil,
         batteryCharging: Bool? = nil,
         cpuUsage: Int? = nil)
    {
        self.rttMs = rttMs
        self.packetsInFlight = packetsInFlight
        self.transportBitrate = transportBitrate
        self.latency = latency
        self.mbpsSendRate = mbpsSendRate
        self.relaxed = relaxed
        self.videoBitrate = videoBitrate
        self.packetsDropped = packetsDropped
        self.packetsRetransmitted = packetsRetransmitted
        self.packetsReceivedNak = packetsReceivedNak
        self.failedEncodings = failedEncodings
        self.thermalState = thermalState
        self.isLowPowerMode = isLowPowerMode
        self.batteryLevel = batteryLevel
        self.batteryCharging = batteryCharging
        self.cpuUsage = cpuUsage
    }
}

struct AdaptiveFpsAction: Equatable {
    let fps: Int
    let message: String
}

class AdaptiveFps {
    private let configuredFps: Int
    private let minimumFps: Int
    private var currentFps: Int
    private var sampleCount = 0
    private var stableSampleCount = 0
    private var latestDecreaseSample = -adaptiveFpsDecreaseCooldownSamples
    private var latestRestoreSample = -adaptiveFpsRestoreCooldownSamples
    private var rttAverage: Double = 0
    private var rttJitter: Double = 0
    private var previousPacketsDropped: Int32?
    private var previousPacketsRetransmitted: Int32?
    private var previousPacketsReceivedNak: Int32?
    private var previousFailedEncodings: Int?

    init(configuredFps: Int, minimumFps: Int) {
        self.configuredFps = makeValidFps(fps: configuredFps)
        self.minimumFps = makeValidAdaptiveFpsMinimum(fps: self.configuredFps,
                                                      minimumFps: minimumFps)
        currentFps = self.configuredFps
    }

    func getCurrentFps() -> Int {
        currentFps
    }

    func isConfiguredFps(fps: Int) -> Bool {
        fps == configuredFps
    }

    func update(stats: StreamStats) -> AdaptiveFpsAction? {
        sampleCount += 1
        updateRtt(stats.rttMs)
        let droppedDelta = delta(current: stats.packetsDropped, previous: &previousPacketsDropped)
        let retransmittedDelta = delta(current: stats.packetsRetransmitted,
                                       previous: &previousPacketsRetransmitted)
        let nakDelta = delta(current: stats.packetsReceivedNak, previous: &previousPacketsReceivedNak)
        let failedEncodingDelta = delta(current: stats.failedEncodings, previous: &previousFailedEncodings)
        let pressure = hasPressure(stats: stats,
                                   droppedDelta: droppedDelta,
                                   retransmittedDelta: retransmittedDelta,
                                   nakDelta: nakDelta,
                                   failedEncodingDelta: failedEncodingDelta)
        if pressure {
            stableSampleCount = 0
            return reduceFps()
        }
        stableSampleCount += 1
        return restoreFps()
    }

    private func updateRtt(_ rttMs: Double) {
        guard rttMs > 0 else {
            return
        }
        if rttAverage == 0 {
            rttAverage = rttMs
        }
        let rttDelta = abs(rttMs - rttAverage)
        rttAverage = 0.9 * rttAverage + 0.1 * rttMs
        rttJitter = 0.9 * rttJitter + 0.1 * rttDelta
    }

    private func hasPressure(stats: StreamStats,
                             droppedDelta: Int32,
                             retransmittedDelta: Int32,
                             nakDelta: Int32,
                             failedEncodingDelta: Int) -> Bool
    {
        let lossEvents = Int64(retransmittedDelta) + Int64(nakDelta) + 4 * Int64(droppedDelta)
        let lossPressure = lossEvents >= 6
        let rttPressure = stats.rttMs > 0 && rttAverage > 0
            && stats.rttMs > max(250, rttAverage * 1.8)
        let jitterPressure = rttJitter > max(40, rttAverage * 0.35)
        let bandwidthPressure = isLowBandwidthHeadroom(stats: stats)
        let queuePressure = stats.packetsInFlight >= 80
        let encoderPressure = failedEncodingDelta > 0
        let thermalPressure = stats.thermalState == .serious || stats.thermalState == .critical
        let batteryPressure = stats.isLowPowerMode || isLowBattery(stats: stats)
        let cpuPressure = (stats.cpuUsage ?? 0) >= 160
        return lossPressure || encoderPressure || thermalPressure || batteryPressure || cpuPressure
            || (bandwidthPressure && queuePressure)
            || ((rttPressure || jitterPressure) && (bandwidthPressure || stats.packetsInFlight >= 50))
    }

    private func isLowBandwidthHeadroom(stats: StreamStats) -> Bool {
        guard let transportBitrate = stats.transportBitrate,
              let videoBitrate = stats.videoBitrate,
              transportBitrate > 0,
              videoBitrate > 0
        else {
            return false
        }
        let bandwidthBelowVideo = Double(transportBitrate) < Double(videoBitrate) * 0.85
        let sendRateNearTransport: Bool
        if let mbpsSendRate = stats.mbpsSendRate {
            sendRateNearTransport = mbpsSendRate * 1_000_000 >= Double(transportBitrate) * 0.9
        } else {
            sendRateNearTransport = false
        }
        return bandwidthBelowVideo && (sendRateNearTransport || stats.packetsInFlight >= 50)
    }

    private func isLowBattery(stats: StreamStats) -> Bool {
        guard let batteryLevel = stats.batteryLevel,
              let batteryCharging = stats.batteryCharging,
              batteryLevel >= 0
        else {
            return false
        }
        return batteryLevel <= 0.10 && !batteryCharging
    }

    private func reduceFps() -> AdaptiveFpsAction? {
        guard currentFps > minimumFps,
              sampleCount - latestDecreaseSample >= adaptiveFpsDecreaseCooldownSamples
        else {
            return nil
        }
        currentFps = nextLowerFps()
        latestDecreaseSample = sampleCount
        return AdaptiveFpsAction(fps: currentFps, message: "Reduce FPS to \(currentFps)")
    }

    private func restoreFps() -> AdaptiveFpsAction? {
        guard currentFps < configuredFps,
              stableSampleCount >= adaptiveFpsRestoreHoldSamples,
              sampleCount - latestRestoreSample >= adaptiveFpsRestoreCooldownSamples
        else {
            return nil
        }
        currentFps = nextHigherFps()
        latestRestoreSample = sampleCount
        stableSampleCount = 0
        return AdaptiveFpsAction(fps: currentFps, message: "Restore FPS to \(currentFps)")
    }

    private func nextLowerFps() -> Int {
        fpss.first { $0 < currentFps && $0 >= minimumFps } ?? minimumFps
    }

    private func nextHigherFps() -> Int {
        fpss.reversed().first { $0 > currentFps && $0 <= configuredFps } ?? configuredFps
    }

    private func delta(current: Int32?, previous: inout Int32?) -> Int32 {
        guard let current else {
            return 0
        }
        defer {
            previous = current
        }
        guard let previous else {
            return 0
        }
        return max(0, current - previous)
    }

    private func delta(current: Int?, previous: inout Int?) -> Int {
        guard let current else {
            return 0
        }
        defer {
            previous = current
        }
        guard let previous else {
            return 0
        }
        return max(0, current - previous)
    }
}

struct AdaptiveBitrateSettings {
    var packetsInFlight: Int64
    var rttDiffHighFactor: Double
    var rttDiffHighAllowedSpike: Double
    var rttDiffHighMinDecrease: Int64
    var pifDiffIncreaseFactor: Int64
    var minimumBitrate: Int64
}

private struct ActionTaken {
    let timestamp: ContinuousClock.Instant
    let message: String

    init(message: String) {
        timestamp = .now
        self.message = message
    }
}

class AdaptiveBitrate {
    weak var delegate: (any AdaptiveBitrateDelegate)?
    private var actionsTaken: Deque<ActionTaken> = []
    private let dateFormatter = DateFormatter()

    init(delegate: any AdaptiveBitrateDelegate) {
        self.delegate = delegate
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
    }

    func setTargetBitrate(bitrate _: UInt32) {}

    func setSettings(settings _: AdaptiveBitrateSettings) {}

    func getCurrentBitrate() -> UInt32 {
        0
    }

    func getCurrentBitrateInKbps() -> Int64 {
        Int64(getCurrentBitrate() / 1000)
    }

    func getCurrentMaximumBitrateInKbps() -> Int64 {
        0
    }

    func getFastPif() -> Int64 {
        0
    }

    func getSmoothPif() -> Int64 {
        0
    }

    func update(stats _: StreamStats) {
        removeOldActionsTaken()
    }

    func getActionsTaken() -> [String] {
        actionsTaken.map(\.message)
    }

    func logAdaptiveAcion(actionTaken: String) {
        logger.debug("adaptive-bitrate: \(actionTaken)")
        let dateString = dateFormatter.string(from: Date())
        actionsTaken.append(ActionTaken(message: dateString + " " + actionTaken))
        while actionsTaken.count > 6 {
            actionsTaken.removeFirst()
        }
    }

    private func removeOldActionsTaken() {
        let now = ContinuousClock.now
        while let actionTaken = actionsTaken.first {
            if actionTaken.timestamp.duration(to: now) > .seconds(15) {
                actionsTaken.removeFirst()
            } else {
                break
            }
        }
    }
}
