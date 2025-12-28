import Testing
import Foundation
@testable import WakaType

struct CardTests {
    @Test func testCardDecoding() throws {
        let json = """
        {
            "id": 1,
            "kamiNoKu": "秋の田の 刈りほの庵の 苫をあらみ",
            "shimoNoKu": "わが衣手は 露にぬれつつ",
            "kamiNoKuKana": "あきのたの かりほのいほの とまをあらみ",
            "shimoNoKuKana": "わがころもでは つゆにぬれつつ",
            "color": "blue",
            "kimariji": 1
        }
        """.data(using: .utf8)!
        
        let card = try JSONDecoder().decode(Card.self, from: json)
        
        #expect(card.id == 1)
        #expect(card.color == .blue)
        #expect(card.kimariji == 1)
        #expect(card.kamiNoKu.contains("秋の田の"))
    }
}
