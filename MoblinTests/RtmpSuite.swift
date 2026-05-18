import AVFoundation
@testable import Moblin
import Testing

struct RtmpSuite {
    @Test
    func twitchUrl() {
        let url = "rtmp://foo.com/app/live_asefwefwefwef"
        let streamUrl = makeRtmpUri(url: url)
        let streamKey = makeRtmpStreamKey(url: url)
        #expect(streamUrl == "rtmp://foo.com/app")
        #expect(streamKey == "live_asefwefwefwef")
    }

    @Test
    func kickUrl() {
        let url = "rtmp://foo.com/foobar"
        let streamUrl = makeRtmpUri(url: url)
        let streamKey = makeRtmpStreamKey(url: url)
        #expect(streamUrl == "rtmp://foo.com")
        #expect(streamKey == "foobar")
    }

    @Test
    func bilibiliUrl() {
        let url = "rtmp://foo.com/live/?foo=bar&a=b"
        let streamUrl = makeRtmpUri(url: url)
        let streamKey = makeRtmpStreamKey(url: url)
        #expect(streamUrl == "rtmp://foo.com/live")
        #expect(streamKey == "?foo=bar&a=b")
    }

    @Test
    func twitcastingUrl() {
        let url = "rtmp://foo.com/live/g:3234234?key=1234"
        let streamUrl = makeRtmpUri(url: url)
        let streamKey = makeRtmpStreamKey(url: url)
        #expect(streamUrl == "rtmp://foo.com/live")
        #expect(streamKey == "g:3234234?key=1234")
    }

    @Test
    func shortAudioConfig() {
        #expect(MpegTsAudioConfig(data: []) == nil)
        #expect(MpegTsAudioConfig(data: [0]) == nil)
    }

    @Test
    func rtmpChunkSizeValidation() {
        #expect(!isValidRtmpChunkSize(0))
        #expect(isValidRtmpChunkSize(1))
        #expect(isValidRtmpChunkSize(0x7FFF_FFFF))
        #expect(!isValidRtmpChunkSize(0x8000_0000))
        #expect(!isValidRtmpChunkSize(0xFFFF_FFFF))
    }
}
