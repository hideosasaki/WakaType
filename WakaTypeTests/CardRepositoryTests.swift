import Testing
@testable import WakaType

struct CardRepositoryTests {
    
    @Test func testFilteringByColor() {
        let repo = CardRepository(cards: [
            Card(id: 1, kamiNoKu: "k1", shimoNoKu: "s1", kamiNoKuKana: "kk1", shimoNoKuKana: "sk1", color: .blue, kimariji: 1),
            Card(id: 2, kamiNoKu: "k2", shimoNoKu: "s2", kamiNoKuKana: "kk2", shimoNoKuKana: "sk2", color: .pink, kimariji: 2)
        ])
        
        let blueCards = repo.fetchCards(color: .blue)
        #expect(blueCards.count == 1)
        #expect(blueCards.first?.color == .blue)
        
        let allCards = repo.fetchCards(color: nil)
        #expect(allCards.count == 2)
    }
    
    @Test func testRandomSelection() {
        let cards = (1...10).map { i in
            Card(id: i, kamiNoKu: "k\(i)", shimoNoKu: "s\(i)", kamiNoKuKana: "kk\(i)", shimoNoKuKana: "sk\(i)", color: .blue, kimariji: i)
        }
        let repo = CardRepository(cards: cards)
        
        let randomCards = repo.getRandomCards(count: 3, color: .blue)
        #expect(randomCards.count == 3)
        
        // 連続して取得したときに順番が異なるか（確率的だが、通常異なるはず）
        let randomCards2 = repo.getRandomCards(count: 3, color: .blue)
        #expect(randomCards != randomCards2)
    }
}
