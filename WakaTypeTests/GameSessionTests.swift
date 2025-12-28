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
        let session = createSession()
        
        // 不正解を入力
        session.submitInput("wrong")
        #expect(session.wrongCount == 1)
        #expect(session.state == .playing) // 時間があれば再入力可能
        
        // 正解を入力
        let correctStr = session.currentCard?.shimoNoKuKana ?? ""
        // ここではTypingEngineが必要だが、Sessionの責務としてsubmitをテスト
        session.submitInput(correctStr)
        #expect(session.correctCount == 1)
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
        #expect(session2.targetString == "kk1")
    }
}
