// SRTLA is a bonding protocol on top of SRT.
// Designed by rationalsa for the BELABOX project.
// https://github.com/BELABOX/srtla

import Foundation
import Network

private let clientRemoveTimeout = 10.0
private let localSrtServerConnectionReceiveBatchSize = 25
private let localSrtServerDataPacketsFlushTimeout = 0.025

private class NakPacket {
    private var sns: [UInt32] = []
    private var latestNakTimestamp: UInt32?
    private var latestNakDestinationSrtSocketId: UInt32?

    func setLatestTimestamp(timestamp: UInt32) {
        latestNakTimestamp = timestamp
    }

    func setLatestNakDestinationSrtSocketId(socketId: UInt32) {
        latestNakDestinationSrtSocketId = socketId
    }

    func add(sn: UInt32) {
        if let index = sns.firstIndex(where: { $0 >= sn }) {
            if sns[index] != sn {
                sns.insert(sn, at: index)
            }
        } else {
            sns.append(sn)
        }
    }

    func removeUpTo(ackSn: UInt32) {
        sns = sns.filter { !isSrtSnAcked(sn: $0, ackSn: ackSn) }
    }

    func remove(sn: UInt32) {
        if let index = sns.firstIndex(where: { $0 == sn }) {
            sns.remove(at: index)
        }
    }

    func pack() -> Data? {
        guard !sns.isEmpty, let latestNakTimestamp, let latestNakDestinationSrtSocketId else {
            return nil
        }
        let writer = ByteWriter()
        writer.writeUInt16(SrtPacketType.nak.rawValue | srtControlPacketTypeBit)
        writer.writeUInt16(0)
        writer.writeUInt32(0)
        writer.writeUInt32(latestNakTimestamp)
        writer.writeUInt32(latestNakDestinationSrtSocketId)
        for sn in sns.prefix(srtNakMaximumSequenceNumbers) {
            writer.writeUInt32(sn)
        }
        return writer.data
    }
}

class SrtlaServerClient: @unchecked Sendable {
    private var localSrtServerConnection: NWConnection?
    private var connections: [SrtlaServerClientConnection] = []
    private var latestConnection: SrtlaServerClientConnection?
    let createdAt: ContinuousClock.Instant = .now
    private var nakPacket = NakPacket()
    private var periodicNakTimer = SimpleTimer(queue: srtlaServerQueue)
    private var dataPacketsFlushTimer = SimpleTimer(queue: srtlaServerQueue)
    private var dataPacketsToSend: [Data] = []

    init(srtPort: UInt16) {
        logger.info("srtla-server-client: Creating local SRT server connection.")
        createLocalSrtServerConnection(srtPort: srtPort)
        startPeriodicNakTimer()
    }

    func stop() {
        stopPeriodicNakTimer()
        dataPacketsFlushTimer.stop()
        dataPacketsToSend.removeAll()
        localSrtServerConnection?.cancel()
        localSrtServerConnection = nil
    }

    private func createLocalSrtServerConnection(srtPort: UInt16) {
        let params = NWParameters(dtls: .none)
        localSrtServerConnection = NWConnection(
            host: .ipv4(.loopback),
            port: .init(integerLiteral: srtPort),
            using: params
        )
        localSrtServerConnection!.stateUpdateHandler = handleStateUpdate(to:)
        localSrtServerConnection!.start(queue: srtlaServerQueue)
        receivePackets()
    }

    private func startPeriodicNakTimer() {
        periodicNakTimer.startPeriodic(interval: 0.1) { [weak self] in
            self?.handlePeriodicNakTimer()
        }
    }

    private func stopPeriodicNakTimer() {
        periodicNakTimer.stop()
    }

    private func handlePeriodicNakTimer() {
        guard let packet = nakPacket.pack() else {
            return
        }
        sendPacketOnLatestConnection(packet: packet)
    }

    private func handleStateUpdate(to state: NWConnection.State) {
        logger.info("srtla-server-client: State change to \(state)")
    }

    private func receivePackets() {
        guard let localSrtServerConnection else {
            return
        }
        let receiveConnection = localSrtServerConnection
        receiveConnection.batch {
            for index in 0 ..< localSrtServerConnectionReceiveBatchSize {
                receiveConnection.receiveMessage { [weak self, weak receiveConnection] packet, _, _, error in
                    guard let self,
                          let receiveConnection,
                          self.localSrtServerConnection === receiveConnection
                    else {
                        return
                    }
                    if let error {
                        logger.info("srtla-server-client: Receive \(error)")
                        return
                    }
                    if let packet, !packet.isEmpty {
                        self.handlePacketFromLocalSrtServer(packet: packet)
                    }
                    guard index == localSrtServerConnectionReceiveBatchSize - 1 else {
                        return
                    }
                    self.receivePackets()
                }
            }
        }
    }

    func addConnection(connection: NWConnection) {
        guard !connections.contains(where: { $0.connection.endpoint == connection.endpoint }) else {
            logger.info("srtla-server-client: Connection \(connection.endpoint) already registered")
            return
        }
        let connection = SrtlaServerClientConnection(connection: connection)
        connection.delegate = self
        connections.append(connection)
        connection.start()
        logger.info("srtla-server-client: Added connection. Using \(connections.count) connection(s)")
    }

    private func handlePacketFromLocalSrtServer(packet: Data) {
        guard packet.count >= srtControlTypeSize else {
            logger.info(
                "srtla-server-client: Packet from local SRT server too short (\(packet.count) bytes)."
            )
            return
        }
        guard !isShortSrtDataPacket(packet: packet) else {
            logger.info(
                "srtla-server-client: SRT data packet from local server too short (\(packet.count) bytes)."
            )
            return
        }
        if isSrtDataPacket(packet: packet) {
            sendPacketOnLatestConnection(packet: packet)
        } else {
            switch SrtPacketType(rawValue: getSrtControlPacketType(packet: packet)) {
            case .ack:
                handleAckPacketFromLocalSrtServer(packet: packet)
            case .nak:
                handleNakPacketFromLocalSrtServer(packet: packet)
            default:
                sendPacketOnLatestConnection(packet: packet)
            }
        }
    }

    private func handleAckPacketFromLocalSrtServer(packet: Data) {
        sendPacketOnAllConnections(packet: packet)
        guard packet.count >= 20 else {
            return
        }
        nakPacket.removeUpTo(ackSn: getSrtSequenceNumber(packet: packet[16 ..< 20]))
    }

    private func handleNakPacketFromLocalSrtServer(packet: Data) {
        sendPacketOnAllConnections(packet: packet)
        guard packet.count >= 16 else {
            return
        }
        processSrtNak(packet: packet) { sn in
            nakPacket.add(sn: sn)
        }
        nakPacket.setLatestTimestamp(timestamp: packet.getUInt32Be(offset: 8))
        nakPacket.setLatestNakDestinationSrtSocketId(socketId: packet.getUInt32Be(offset: 12))
    }

    private func sendPacketOnLatestConnection(packet: Data) {
        latestConnection?.sendPacket(packet: packet)
    }

    private func sendPacketOnAllConnections(packet: Data) {
        for connection in connections {
            connection.sendPacket(packet: packet)
        }
    }

    private func scheduleDataPacketsFlush() {
        dataPacketsFlushTimer.startSingleShot(timeout: localSrtServerDataPacketsFlushTimeout) { [weak self] in
            self?.flushDataPackets()
        }
    }

    private func flushDataPackets() {
        dataPacketsFlushTimer.stop()
        guard !dataPacketsToSend.isEmpty else {
            return
        }
        localSrtServerConnection?.batch {
            for packet in dataPacketsToSend {
                localSrtServerConnection?.send(content: packet, completion: .idempotent)
            }
        }
        dataPacketsToSend.removeAll()
    }

    func handlePeriodicTimer() -> Bool {
        let now = ContinuousClock.now
        var index = 0
        while index < connections.count {
            let connection = connections[index]
            if connection.isActive(now: now) {
                index += 1
            } else {
                connection.stop()
                connections.remove(at: index)
                logger
                    .info("srtla-server-client: Removed connection. Using \(connections.count) connection(s)")
            }
        }
        return connections.isEmpty && createdAt.duration(to: now) > .seconds(clientRemoveTimeout)
    }
}

extension SrtlaServerClient: SrtlaServerClientConnectionDelegate {
    func handlePacketFromSrtClient(_ connection: SrtlaServerClientConnection, packet: Data) {
        guard !isShortSrtDataPacket(packet: packet) else {
            logger.info("srtla-server-client: SRT data packet from client too short (\(packet.count) bytes).")
            return
        }
        if isSrtDataPacket(packet: packet) {
            nakPacket.remove(sn: getSrtSequenceNumber(packet: packet))
            dataPacketsToSend.append(packet)
            if dataPacketsToSend.count == 1 {
                scheduleDataPacketsFlush()
            }
            if dataPacketsToSend.count > 15 {
                flushDataPackets()
            }
        } else {
            flushDataPackets()
            localSrtServerConnection?.send(content: packet, completion: .idempotent)
        }
        latestConnection = connection
    }
}
