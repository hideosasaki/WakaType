import Foundation
import Observation

@Observable
class GameSession {
    var cards: [Card]
    var currentIndex: Int = 0
    var timeLimit: Int
    var remainingTime: Double
    
    var correctCount: Int = 0
    var wrongCount: Int = 0
    var giveUpCount: Int = 0
    
    var isGameOver: Bool = false
    
    var currentCard: Card? {
        guard currentIndex < cards.count else { return nil }
        return cards[currentIndex]
    }
    
    init(cards: [Card], timeLimit: Int) {
        self.cards = cards.shuffled()
        self.timeLimit = timeLimit
        self.remainingTime = Double(timeLimit)
    }
    
    func giveUp() {
        giveUpCount += 1
        nextCard()
    }
    
    func nextCard() {
        currentIndex += 1
        if currentIndex >= cards.count {
            isGameOver = true
        } else {
            remainingTime = Double(timeLimit)
        }
    }
    
    // 他、タイマー更新ロジックなどを実装予定
}
