import Foundation
@testable import Moblin
import Testing

struct RtspClientSuite {
    @Test
    func tcpTransportAcceptsValidInterleavedChannels() throws {
        let transport = RtspTransportRtpRtspTcp()
        try transport.handleSetupTransportResponse("RTP/AVP/TCP;unicast;interleaved=0-1")
    }

    @Test
    func tcpTransportRejectsInvalidInterleavedChannels() {
        let transport = RtspTransportRtpRtspTcp()
        #expect(throws: "Invalid interleaving channels in RTP/AVP/TCP;unicast;interleaved=256-257.") {
            try transport.handleSetupTransportResponse("RTP/AVP/TCP;unicast;interleaved=256-257")
        }
    }

    @Test
    func udpTransportAcceptsValidServerPorts() throws {
        let transport = RtspTransportRtpUdp()
        try transport.handleSetupTransportResponse("RTP/AVP;unicast;server_port=5004-5005")
    }

    @Test
    func udpTransportRejectsInvalidRtpServerPort() {
        let transport = RtspTransportRtpUdp()
        #expect(throws: "Invalid RTP or RTCP server port in: RTP/AVP;unicast;server_port=999999-5005") {
            try transport.handleSetupTransportResponse("RTP/AVP;unicast;server_port=999999-5005")
        }
    }

    @Test
    func parseMissingContentLength() {
        #expect(parseContentLength(from: "RTSP/1.0 200 OK\r\n\r\n".utf8Data) == 0)
    }

    @Test
    func parseValidContentLength() {
        #expect(parseContentLength(from: "RTSP/1.0 200 OK\r\nContent-Length: 12\r\n\r\n".utf8Data) == 12)
    }

    @Test
    func rejectNegativeContentLength() {
        #expect(parseContentLength(from: "RTSP/1.0 200 OK\r\nContent-Length: -1\r\n\r\n".utf8Data) == nil)
    }

    @Test
    func rejectNonnumericContentLength() {
        #expect(parseContentLength(from: "RTSP/1.0 200 OK\r\nContent-Length: nope\r\n\r\n".utf8Data) == nil)
    }

    @Test
    func normalizeRtpPacketSkipsCsrcAndExtension() throws {
        let packet = Data([
            0x91, 0x60, 0x00, 0x02, 0x00, 0x00, 0x00, 0x10,
            0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88,
            0xBE, 0xDE, 0x00, 0x01, 0x99, 0xAA, 0xBB, 0xCC,
            0x65, 0x88,
        ])
        let normalized = try normalizeRtpPacket(packet: packet)
        #expect(normalized == Data([
            0x80, 0x60, 0x00, 0x02, 0x00, 0x00, 0x00, 0x10,
            0x11, 0x22, 0x33, 0x44, 0x65, 0x88,
        ]))
    }

    @Test
    func normalizeRtpPacketSkipsPadding() throws {
        let packet = Data([
            0xA0, 0x60, 0x00, 0x02, 0x00, 0x00, 0x00, 0x10,
            0x11, 0x22, 0x33, 0x44, 0x65, 0x88, 0x00, 0x02,
        ])
        let normalized = try normalizeRtpPacket(packet: packet)
        #expect(normalized == Data([
            0x80, 0x60, 0x00, 0x02, 0x00, 0x00, 0x00, 0x10,
            0x11, 0x22, 0x33, 0x44, 0x65, 0x88,
        ]))
    }

    @Test
    func decodeNtpTimestampUsesSecondsField() {
        let unixEpoch = UInt64(2_208_988_800) << 32
        #expect(decodeNtpTimestamp(v: unixEpoch) == 0.0)

        let oneAndHalfSeconds = (UInt64(2_208_988_801) << 32) | (UInt64(1) << 31)
        #expect(decodeNtpTimestamp(v: oneAndHalfSeconds) == 1.5)

        #expect(decodeNtpTimestamp(v: 0x0000_0000_FFFF_FFFF) == nil)
    }

    @Test
    func removeNalUnitStartCodesConvertsThreeByteStartCodes() {
        var data = Data([
            0x00, 0x00, 0x01, 0x65, 0xAA,
            0x00, 0x00, 0x01, 0x41, 0xBB, 0xCC,
        ])

        removeNalUnitStartCodes(&data, getNalUnits(data: data))

        #expect(data == Data([
            0x00, 0x00, 0x00, 0x02, 0x65, 0xAA,
            0x00, 0x00, 0x00, 0x03, 0x41, 0xBB, 0xCC,
        ]))
    }

    @Test
    func removeNalUnitStartCodesConvertsMixedStartCodes() {
        var data = Data([
            0x00, 0x00, 0x00, 0x01, 0x67,
            0x00, 0x00, 0x01, 0x68, 0x99,
        ])

        removeNalUnitStartCodes(&data, getNalUnits(data: data))

        #expect(data == Data([
            0x00, 0x00, 0x00, 0x01, 0x67,
            0x00, 0x00, 0x00, 0x02, 0x68, 0x99,
        ]))
    }

    @Test
    func makeSetupUrlAddsSeparatorForRelativeControl() throws {
        let url = try makeRtspSetupUrl(baseUrl: "rtsp://example.com/live", controlUrl: "trackID=1")
        #expect(url?.absoluteString == "rtsp://example.com/live/trackID=1")
    }

    @Test
    func makeSetupUrlPreservesRelativeControlQuery() throws {
        let url = try makeRtspSetupUrl(baseUrl: "rtsp://example.com/live/", controlUrl: "trackID=1?token=abc")
        #expect(url?.absoluteString == "rtsp://example.com/live/trackID=1?token=abc")
    }

    @Test
    func makeSetupUrlAvoidsDuplicateSeparator() throws {
        let url = try makeRtspSetupUrl(baseUrl: "rtsp://example.com/live/", controlUrl: "/trackID=1")
        #expect(url?.absoluteString == "rtsp://example.com/live/trackID=1")
    }

    @Test
    func makeSetupUrlKeepsAbsoluteControlUrl() throws {
        let url = try makeRtspSetupUrl(baseUrl: "rtsp://example.com/live", controlUrl: "rtsp://media.example.com/track")
        #expect(url?.absoluteString == "rtsp://media.example.com/track")
    }

    @Test
    func makeSetupUrlReturnsNilWithoutControlUrl() throws {
        let url = try makeRtspSetupUrl(baseUrl: "rtsp://example.com/live", controlUrl: nil)
        #expect(url == nil)
    }
}
