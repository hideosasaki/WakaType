import Foundation

class CardRepository {
    private let allCards: [Card]
    
    init(cards: [Card]) {
        self.allCards = cards
    }
    
    func fetchCards(color: CardColor?) -> [Card] {
        if let color = color {
            return allCards.filter { $0.color == color }
        }
        return allCards
    }
    
    func getRandomCards(count: Int, color: CardColor?) -> [Card] {
        let filtered = fetchCards(color: color)
        return Array(filtered.shuffled().prefix(count))
    }
    
    static func loadFromBundle() -> CardRepository {
        guard let url = Bundle.main.url(forResource: "cards", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let cards = try? JSONDecoder().decode([Card].self, from: data) else {
            return CardRepository(cards: [])
        }
        return CardRepository(cards: cards)
    }
}
