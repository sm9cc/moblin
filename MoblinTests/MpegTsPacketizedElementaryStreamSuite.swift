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
    func parsesValidPtsField() throws {
        var header = OptionalHeader()
        header.setTimestamp(CMTime(value: 90_000, timescale: 90_000), .invalid)
        let parsedHeader = try OptionalHeader(data: header.encode())
        #expect(parsedHeader.getPresentationTimeStamp().seconds == 1)
        #expect(!parsedHeader.getDecodeTimeStamp().isValid)
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
