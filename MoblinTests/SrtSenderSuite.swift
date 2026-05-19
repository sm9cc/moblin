import Foundation
@testable import Moblin
import Testing

private class ModelMock {
    private let connected = MessageQueue<Void>()
    private let disconnected = MessageQueue<Void>()
    private let packets = MessageQueue<String>()
    private(set) var numberOfConnects = 0

    func waitForConnected() async {
        await connected.get()
    }

    func waitForDisconnected() async {
        await disconnected.get()
    }

    func waitForPacket() async -> String {
        await packets.get()
    }
}

extension ModelMock: SrtSenderDelegate {
    func srtSenderConnected() {
        numberOfConnects += 1
        connected.put(())
    }

    func srtSenderDisconnected() {
        disconnected.put(())
    }

    func srtSenderOutput(packet: Data) {
        packets.put(packet.hexString())
    }
}

struct SrtSenderSuite {
    @Test
    func shortPacketsAreNotDataPackets() {
        #expect(!isSrtDataPacket(packet: Data()))
        #expect(!isSrtDataPacket(packet: Data([0x00])))
        #expect(!isSrtDataPacket(packet: Data([0x00, 0x00, 0x00])))
        #expect(isSrtDataPacket(packet: Data([0x00, 0x00, 0x00, 0x00])))
        #expect(!isSrtDataPacket(packet: Data([0x80, 0x00, 0x00, 0x00])))
    }

    @Test
    func processSrtNakRange() {
        let packet = createSrtNakPacket([0x8000_0001, 0x0000_0003])
        var sns: [UInt32] = []
        processSrtNak(packet: packet) { sn in
            sns.append(sn)
        }
        #expect(sns == [1, 2, 3])
    }

    @Test
    func processSrtNakRangeWraps() {
        let packet = createSrtNakPacket([0xFFFF_FFFE, 0x0000_0001])
        var sns: [UInt32] = []
        processSrtNak(packet: packet) { sn in
            sns.append(sn)
        }
        #expect(sns == [0x7FFF_FFFE, 0x7FFF_FFFF, 0, 1])
    }

    @Test
    func processSrtNakLargeRangeIsBounded() {
        let packet = createSrtNakPacket([0x8000_0001, UInt32(srtNakMaximumSequenceNumbers + 100)])
        var count = 0
        var lastSn: UInt32 = 0
        processSrtNak(packet: packet) { sn in
            count += 1
            lastSn = sn
        }
        #expect(count == srtNakMaximumSequenceNumbers)
        #expect(lastSn == UInt32(srtNakMaximumSequenceNumbers))
    }

    @Test
    func connectDisconnect() async throws {
        let sender = SrtSender(streamId: "1234", latency: 2000, experimental: false)
        let model = ModelMock()
        sender.delegate = model
        sender.start()
        let socketId = await checkInductionHandshake(packet: model.waitForPacket())
        try sender.input(packet: createInductionHandshake())
        _ = await checkConclusionHandshake(packet: model.waitForPacket(), socketId: socketId)
        try sender.input(packet: createConclusionHandshake())
        await model.waitForConnected()
        sender.send(now: .now.advanced(by: .seconds(6)))
        await model.waitForDisconnected()
    }

    @Test
    func duplicateConclusionDoesNotReconnect() async throws {
        let sender = SrtSender(streamId: "1234", latency: 2000, experimental: false)
        let model = ModelMock()
        sender.delegate = model
        try await connect(sender: sender, model: model)
        try sender.input(packet: createConclusionHandshake())
        #expect(model.numberOfConnects == 1)
    }

    @Test
    func ackClearsAllInflightPackets() async throws {
        let sender = SrtSender(streamId: "1234", latency: 2000, experimental: false)
        let model = ModelMock()
        sender.delegate = model
        try await connect(sender: sender, model: model)
        let now = ContinuousClock.now
        let firstPacket = makeDataPacket(sender: sender, payload: [0x47])
        let secondPacket = makeDataPacket(sender: sender, payload: [0x48])
        sender.enqueue(packet: firstPacket, now: now)
        sender.enqueue(packet: secondPacket, now: now)
        sender.send(now: now.advanced(by: .milliseconds(3)))
        _ = await model.waitForPacket()
        let secondPacketHex = await model.waitForPacket()
        let secondSequenceNumber = try sequenceNumber(packet: secondPacketHex)
        #expect(sender.getPerformanceData()?.pktFlightSize == 2)
        sender.input(packet: createAckPacket(sequenceNumber: nextSrtSn(sn: secondSequenceNumber)))
        #expect(sender.getPerformanceData()?.pktFlightSize == 0)
    }

    private func connect(sender: SrtSender, model: ModelMock) async throws {
        sender.start()
        let socketId = await checkInductionHandshake(packet: model.waitForPacket())
        try sender.input(packet: createInductionHandshake())
        _ = await checkConclusionHandshake(packet: model.waitForPacket(), socketId: socketId)
        try sender.input(packet: createConclusionHandshake())
        await model.waitForConnected()
    }

    private func makeDataPacket(sender: SrtSender, payload: [UInt8]) -> SrtDataPacket {
        payload.withUnsafeBytes {
            sender.newDataPacket(payload: $0)
        }
    }

    private func createAckPacket(sequenceNumber: UInt32) -> Data {
        let writer = ByteWriter()
        writer.writeUInt16(srtControlPacketTypeBit | SrtPacketType.ack.rawValue)
        writer.writeUInt16(0)
        writer.writeUInt32(1)
        writer.writeUInt32(0)
        writer.writeUInt32(0)
        writer.writeUInt32(sequenceNumber)
        writer.writeUInt32(10_000)
        return writer.data
    }

    private func sequenceNumber(packet: String) throws -> UInt32 {
        guard let sequenceNumber = UInt32(packet.substring(begin: 0, end: 8), radix: 16) else {
            throw "Invalid sequence number"
        }
        return sequenceNumber
    }

    private func checkInductionHandshake(packet: String) -> UInt32 {
        #expect(packet.count == 128)
        #expect(packet.substring(begin: 0, end: 16) == "8000000000000000")
        _ = UInt32(packet.substring(begin: 16, end: 24), radix: 16)!
        #expect(packet.substring(begin: 24, end: 48) == "000000000000000400000002")
        _ = UInt32(packet.substring(begin: 48, end: 56), radix: 16)!
        #expect(packet.substring(begin: 56, end: 80) == "000005dc0000200000000001")
        let socketId = UInt32(packet.substring(begin: 80, end: 88), radix: 16)!
        #expect(socketId != 0)
        #expect(packet.substring(begin: 88, end: 128) == "000000000100007f000000000000000000000000")
        return socketId
    }

    private func createInductionHandshake() throws -> Data {
        try Data(hexString: """
        80000000000000000000000000000000000000040000000200000fe6000005dc\
        00002000000000012ab1f77c000000000100007f000000000000000000000000
        """)
    }

    private func createSrtNakPacket(_ values: [UInt32]) -> Data {
        var packet = Data(count: 16 + values.count * 4)
        for (index, value) in values.enumerated() {
            packet.setUInt32Be(value: value, offset: 16 + index * 4)
        }
        return packet
    }

    private func checkConclusionHandshake(packet: String, socketId: UInt32) -> (UInt32, UInt32) {
        #expect(packet.count == 176)
        #expect(packet.substring(begin: 0, end: 16) == "8000000000000000")
        let timestamp = UInt32(packet.substring(begin: 16, end: 24), radix: 16)!
        #expect(packet.substring(begin: 24, end: 48) == "2ab1f77c0000000500000005")
        let sequenceNumber = UInt32(packet.substring(begin: 48, end: 56), radix: 16)!
        #expect(packet.substring(begin: 56, end: 80) == "000005dc00002000ffffffff")
        #expect(UInt32(packet.substring(begin: 80, end: 88), radix: 16)! == socketId)
        #expect(packet.substring(begin: 88, end: 176) ==
            """
            000000000100007f00000000000000000000000000010003000105030000\
            00bf07d007d00005000134333231
            """)
        return (timestamp, sequenceNumber)
    }

    private func createConclusionHandshake() throws -> Data {
        try Data(hexString: """
        800000000000000000000000000000000000000500000005000000000000\
        05dc00002000ffffffff2ab1f77c000000000100007f0000000000000000\
        000000000001000300010503000000bf07d007d00005000134333231
        """)
    }
}
