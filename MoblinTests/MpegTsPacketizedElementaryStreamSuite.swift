import AVFoundation
@testable import Moblin
import Testing

struct MpegTsPacketizedElementaryStreamSuite {
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
