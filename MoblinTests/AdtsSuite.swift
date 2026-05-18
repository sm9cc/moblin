import Foundation
@testable import Moblin
import Testing

struct AdtsSuite {
    @Test
    func rejectsShortHeader() {
        #expect(AdtsHeader(data: Data(repeating: 0, count: AdtsHeader.size - 1)) == nil)
    }

    @Test
    func rejectsInvalidSyncWord() {
        var data = AdtsHeader.encode(type: 2, frequency: 4, channels: 2, length: 1)
        data[1] = 0xE9
        #expect(AdtsHeader(data: data) == nil)
    }

    @Test
    func rejectsFrameLengthPastBufferEnd() {
        let data = AdtsHeader.encode(type: 2, frequency: 4, channels: 2, length: 1).prefix(AdtsHeader.size)
        #expect(AdtsHeader(data: Data(data)) == nil)
    }

    @Test
    func acceptsCompleteFrame() {
        let data = AdtsHeader.encode(type: 2, frequency: 4, channels: 2, length: 1) + Data([0])
        #expect(AdtsHeader(data: data)?.aacFrameLength == UInt16(data.count))
    }
}
