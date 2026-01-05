import Foundation
import Observation
import Combine

enum GameState {
    case playing
    case checkingAnswer
    case memorizing
    case finished
}

enum InputMode {
    case kamiToShimo
    case shimoToKami
    case all
}

@Observable
class GameSession {
    var cards: [Card]
    var currentIndex: Int = 0
    var timeLimit: Int
    var remainingTime: Double
    var mode: InputMode
    var state: GameState = .playing
    var currentInput: String = ""
    var lastWrongInput: String? = nil
    
    var displayedInput: String {
        engine.convertToKana(currentInput)
    }

    func convertToKana(_ romaji: String) -> String {
        engine.convertToKana(romaji)
    }
    
    var correctCount: Int = 0
    var wrongCount: Int = 0
    var giveUpCount: Int = 0
    
    private let engine = TypingEngine()
    private var timer: AnyCancellable?
    
    var currentCard: Card? {
        guard currentIndex < cards.count else { return nil }
        return cards[currentIndex]
    }
    
    var targetString: String {
        guard let card = currentCard else { return "" }
        let combined: String
        switch mode {
        case .kamiToShimo: combined = card.shimoNoKuKana
        case .shimoToKami: combined = card.kamiNoKuKana
        case .all: combined = card.kamiNoKuKana + card.shimoNoKuKana
        }
        return combined.replacingOccurrences(of: " ", with: "")
                       .replacingOccurrences(of: "　", with: "")
    }
    
    init(cards: [Card], timeLimit: Int, mode: InputMode = .kamiToShimo) {
        self.cards = cards.shuffled()
        self.timeLimit = timeLimit
        self.remainingTime = Double(timeLimit)
        self.mode = mode
        startTimer()
    }
    
    private func startTimer() {
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.advanceTime(0.1)
            }
    }
    
    func advanceTime(_ seconds: Double) {
        guard state == .playing else { return }
        remainingTime = max(0, remainingTime - seconds)
        if remainingTime <= 0 {
            lastWrongInput = currentInput
            currentInput = ""
            state = .memorizing
        }
    }
    
    func appendInput(_ string: String) {
        guard state == .playing || state == .memorizing else { return }
        if lastWrongInput != nil {
            lastWrongInput = nil
        }
        currentInput += string
    }
    
    func backspace() {
        guard !currentInput.isEmpty else { return }
        currentInput = engine.removeLastKanaBlock(from: currentInput)
    }
    
    func submitCurrentInput() {
        let input = currentInput
        currentInput = ""
        
        if state == .memorizing {
            submitMemorizationInput(input)
        } else {
            submitInput(input)
        }
    }
    
    func submitInput(_ input: String) {
        guard state == .playing else { return }
        
        if input.isEmpty {
            giveUp()
            return
        }
        
        let result = engine.check(input: input, target: targetString)
        if result.isComplete {
            correctCount += 1
            lastWrongInput = nil
            nextCard()
        } else {
            wrongCount += 1
            lastWrongInput = input
            // 不正解の場合は状態を維持して再入力を促す（仕様通り）
        }
    }
    
    func submitMemorizationInput(_ input: String) {
        guard state == .memorizing else { return }
        let result = engine.check(input: input, target: targetString)
        if result.isComplete {
            nextCard()
        } else {
            wrongCount += 1
            lastWrongInput = input
        }
    }
    
    func giveUp() {
        giveUpCount += 1
        lastWrongInput = currentInput
        currentInput = ""
        state = .memorizing
    }
    
    private func nextCard() {
        currentIndex += 1
        if currentIndex >= cards.count {
            state = .finished
            timer?.cancel()
        } else {
            state = .playing
            remainingTime = Double(timeLimit)
            lastWrongInput = nil
        }
    }
}
