@testable import Moblin
import Testing

struct SettingsSuite {
    @Test
    func chatFilter() {
        let filter = SettingsChatFilter()
        filter.enabled = true
        filter.user = ""
        filter.messageStartWords = ["!"]
        #expect(filter.isMatching(user: "erik", segments: [.init(id: 0, text: "!moblin")]))
        #expect(filter.isMatching(user: "erik", segments: [.init(id: 0, text: "!")]))
        #expect(!filter.isMatching(user: "erik", segments: [.init(id: 0, text: "@foo")]))
        #expect(!filter.isMatching(user: "erik", segments: [.init(id: 0, text: "@")]))
        filter.messageStartWords = ["hell", "h"]
        #expect(filter.isMatching(user: "erik",
                                  segments: [
                                      .init(id: 0, text: "hell"),
                                      .init(id: 0, text: "hi"),
                                      .init(id: 0, text: "ho"),
                                  ]))
        #expect(!filter.isMatching(user: "erik",
                                   segments: [
                                       .init(id: 0, text: "hello"),
                                       .init(id: 0, text: "hi"),
                                       .init(id: 0, text: "ho"),
                                   ]))
    }

    @Test
    func adaptiveFpsValidation() {
        #expect(makeValidFps(fps: 42) == SettingsStream.defaultFps)
        #expect(makeValidAdaptiveFpsMinimum(fps: 60, minimumFps: 30) == 30)
        #expect(makeValidAdaptiveFpsMinimum(fps: 60, minimumFps: 42) == defaultAdaptiveFpsMinimum)
        #expect(makeValidAdaptiveFpsMinimum(fps: 15, minimumFps: 15) == 15)
    }
}
