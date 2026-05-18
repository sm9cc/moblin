import AVFoundation
@testable import Moblin
import Testing

struct MpegTsPacketizedElementaryStreamSuite {
    @Test
    func parsesScramblingControl() throws {
        let optionalHeader = try OptionalHeader(data: Data([0b1011_0000, 0, 0]))
        #expect(optionalHeader.scramblingControl == 3)
    }

    @Test
    func rejectsInvalidMarkerBits() {
        #expect(throws: "Invalid PES marker bits") {
            try OptionalHeader(data: Data([0b0111_0000, 0, 0]))
        }
    }

    @Test
    func rejectsShortPtsField() {
        #expect(throws: "Short PES PTS field") {
            try OptionalHeader(data: Data([0b1000_0000, 0b1000_0000, 4, 0, 0, 0, 0]))
        }
    }

    @Test
    func rejectsShortDtsField() {
        #expect(throws: "Short PES PTS/DTS fields") {
            try OptionalHeader(data: Data([0b1000_0000, 0b1100_0000, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0]))
        }
    }

    @Test
    func rejectsOnlyDtsFlag() {
        #expect(throws: "Invalid PES PTS/DTS flags") {
            try OptionalHeader(data: Data([0b1000_0000, 0b0100_0000, 5, 0, 0, 0, 0, 0]))
        }
    }

    @Test
    func rejectsInvalidPtsMarkerBits() {
        var header = OptionalHeader()
        header.setTimestamp(CMTime(value: 90_000, timescale: 90_000), .invalid)
        var data = header.encode()
        data[3] = data[3] & 0xFE
        #expect(throws: "Invalid PES PTS marker bits") {
            try OptionalHeader(data: data)
        }
    }

    @Test
    func rejectsInvalidDtsMarkerBits() {
        var header = OptionalHeader()
        header.setTimestamp(
            CMTime(value: 90_000, timescale: 90_000),
            CMTime(value: 45_000, timescale: 90_000)
        )
        var data = header.encode()
        data[8] = data[8] & 0xFE
        #expect(throws: "Invalid PES DTS marker bits") {
            try OptionalHeader(data: data)
        }
    }

    @Test
    func parsesValidPtsField() throws {
        var header = OptionalHeader()
        header.setTimestamp(CMTime(value: 90_000, timescale: 90_000), .invalid)
        let parsedHeader = try OptionalHeader(data: header.encode())
        #expect(parsedHeader.getPresentationTimeStamp().seconds == 1)
        #expect(!parsedHeader.getDecodeTimeStamp().isValid)
    }

    @Test
    func boundedPacketLengthDropsTrailingBytes() throws {
        let stream = try MpegTsPacketizedElementaryStream(
            data: Data([0, 0, 1, 0xE0, 0, 4, 0x80, 0, 0, 0xAA, 0xBB])
        )
        #expect(stream.data == Data([0xAA]))
    }

    @Test
    func encodesProgramClockReferenceExtensionHighBit() {
        #expect(TSProgramClockReference.encode(0, 0x0100) == Data([0, 0, 0, 0, 0x7F, 0]))
    }

    @Test
    func parsesProgramAssociationWithValidCrc() throws {
        let table = MpegTsProgramAssociation()
        table.programs[1] = 256
        let parsedTable = try MpegTsProgramAssociation(data: table.packet(0).payload)
        #expect(parsedTable.programs[1] == 256)
    }

    @Test
    func rejectsProgramAssociationCrcMismatch() {
        let table = MpegTsProgramAssociation()
        table.programs[1] = 256
        var payload = table.packet(0).payload
        payload[12] ^= 0x01
        #expect(throws: "Invalid PSI CRC") {
            try MpegTsProgramAssociation(data: payload)
        }
    }

    @Test
    func shortPayloadFirstPacketIsFullSize() {
        let stream = MpegTsPacketizedElementaryStream(
            streamId: 0xE0,
            presentationTimeStamp: CMTime(value: 0, timescale: 90_000),
            decodeTimeStamp: .invalid,
            data: Data([0x65])
        )
        let packets = stream.arrayOfPackets(256, true, nil)
        #expect(packets.count == 1)
        #expect(packets[0].encode().count == MpegTsPacket.size)
    }
}
