import Testing
import Foundation
@testable import WakaType

@MainActor
struct GameSessionTests {
    
    private func createSession(timeLimit: Int = 10) -> GameSession {
        let cards = [
            Card(id: 1, kamiNoKu: "k1", shimoNoKu: "s1", kamiNoKuKana: "kk1", shimoNoKuKana: "sk1", color: .blue, kimariji: 1),
            Card(id: 2, kamiNoKu: "k2", shimoNoKu: "s2", kamiNoKuKana: "kk2", shimoNoKuKana: "sk2", color: .pink, kimariji: 2)
        ]
        return GameSession(cards: cards, timeLimit: timeLimit)
    }

    @Test func testSessionInitialization() {
        let session = createSession()
        #expect(session.correctCount == 0)
        #expect(session.state == .playing)
        #expect(session.currentInput == "")
    }

    @Test func testInputManagement() {
        let session = createSession()
        
        session.appendInput("a")
        session.appendInput("b")
        #expect(session.currentInput == "ab")
        
        session.backspace()
        #expect(session.currentInput == "a")
        
        session.backspace()
        #expect(session.currentInput == "")
        
        // 空の状態でのバックスペース
        session.backspace()
        #expect(session.currentInput == "")
    }
    
    @Test func testSubmitCurrentInput() {
        let session = createSession()
        
        session.appendInput("wrong")
        session.submitCurrentInput()
        
        #expect(session.currentInput == "")
        #expect(session.wrongCount == 1)
    }
    
    @Test func testGiveUp() {
        let session = createSession()
        // 空入力を送信
        session.submitInput("")
        
        #expect(session.giveUpCount == 1)
        // ギブアップ直後は暗記モード（正解表示中）になるべき
        #expect(session.state == .memorizing)
    }

    @Test func testTimerExpiration() {
        let session = createSession(timeLimit: 5)
        
        // 時間を5秒進める（模擬的）
        session.advanceTime(5)
        
        #expect(session.state == .memorizing)
        #expect(session.remainingTime == 0)
    }

    @Test func testScoringAndReinput() {
        let cards = [
            Card(id: 1, kamiNoKu: "k1", shimoNoKu: "s1", kamiNoKuKana: "kk1", shimoNoKuKana: "すき", color: .blue, kimariji: 1)
        ]
        let session = GameSession(cards: cards, timeLimit: 10)
        
        // 不正解を入力
        session.submitInput("wrong")
        #expect(session.wrongCount == 1)
        #expect(session.state == .playing)
        
        // 正解を入力 (新ロジックに基づく一致を確認)
        session.submitInput("suki")
        #expect(session.correctCount == 1)
    }

    @Test func testRealJapaneseInput() {
        let cards = [
            Card(id: 1, kamiNoKu: "あ", shimoNoKu: "いう", kamiNoKuKana: "あ", shimoNoKuKana: "い う", color: .blue, kimariji: 1)
        ]
        let session = GameSession(cards: cards, timeLimit: 10, mode: .kamiToShimo)
        
        // targetString は "いう" (スペース除去済み) になるはず
        #expect(session.targetString == "いう")
        
        // "iu" と入力して確定
        session.appendInput("i")
        session.appendInput("u")
        #expect(session.currentInput == "iu")
        #expect(session.displayedInput == "いう")
        
        session.submitCurrentInput()
        
        // 正解として判定され、終了状態になるはず（カードが1枚なので）
        #expect(session.correctCount == 1)
        #expect(session.state == .finished)
    }

    @Test func testMemorizationRequirement() {
        let session = createSession()
        session.giveUp()
        
        #expect(session.state == .memorizing)
        
        // 暗記モードでは正しく入力するまで次へ進めない
        session.submitMemorizationInput("wrong")
        #expect(session.state == .memorizing)
        
        let correctStr = session.currentCard?.shimoNoKuKana ?? ""
        session.submitMemorizationInput(correctStr)
        
        // 正解入力後、次のカードへ
        #expect(session.currentIndex == 1)
        #expect(session.state == .playing)
    }

    @Test func testInputModes() {
        let cards = [Card(id: 1, kamiNoKu: "k1", shimoNoKu: "s1", kamiNoKuKana: "kk1", shimoNoKuKana: "sk1", color: .blue, kimariji: 1)]
        
        // 下の句を入力させるモード
        let session1 = GameSession(cards: cards, timeLimit: 10, mode: .kamiToShimo)
        #expect(session1.targetString == "sk1")
        
        // 上の句を入力させるモード
        let session2 = GameSession(cards: cards, timeLimit: 10, mode: .shimoToKami)
    }

    @Test func testTimeoutTransition() {
        let cards = [
            Card(id: 1, kamiNoKu: "k1", shimoNoKu: "s1", kamiNoKuKana: "kk1", shimoNoKuKana: "はるの　きっさ", color: .blue, kimariji: 1),
            Card(id: 2, kamiNoKu: "k2", shimoNoKu: "s2", kamiNoKuKana: "kk2", shimoNoKuKana: "sk2", color: .blue, kimariji: 1)
        ]
        let session = GameSession(cards: cards, timeLimit: 10)
        
        // targetString がスペース（半角・全角）を除去しているか確認
        #expect(session.targetString == "はるのきっさ")
        
        // タイムアウトさせる
        session.advanceTime(10)
        #expect(session.state == .memorizing)
        
        // 正解を入力 (促音 'っ' + 拗音 'きっさ')
        session.appendInput("harunokissa")
        session.submitCurrentInput()
        
        // 次のカードへ進むはず
        #expect(session.currentIndex == 1)
        #expect(session.state == .playing)
    }

    @Test func testMemorizationRequirementWithOneCard() {
        let cards = [Card(id: 1, kamiNoKu: "k", shimoNoKu: "s", kamiNoKuKana: "k", shimoNoKuKana: "s", color: .blue, kimariji: 1)]
        let session = GameSession(cards: cards, timeLimit: 10)
        session.giveUp()
        
        #expect(session.state == .memorizing)
        session.submitMemorizationInput("s")
        
        #expect(session.state == .finished)
    }
}
