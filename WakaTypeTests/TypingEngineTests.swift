import Testing
@testable import WakaType

struct TypingEngineTests {
    
    private let engine = TypingEngine()

    @Test func testBasicMatching() {
        let target = "あいうえお"
        #expect(engine.check(input: "aiueo", target: target).isComplete)
    }
    
    @Test func testRomajiMappings() {
        // 'chi' vs 'ti'
        #expect(engine.check(input: "chi", target: "ち").isComplete)
        #expect(engine.check(input: "ti", target: "ち").isComplete)
        
        // 'nn' vs 'n'
        #expect(engine.check(input: "nn", target: "ん").isComplete)
        // 'n'単体は次に母音や'y'、'n'が来ない場合のみ「ん」になるが、単体チェックでは 'nn' を基本にする
    }
    
    @Test func testOldKanaDirectMappings() {
        // ゐ -> i (い)
        #expect(engine.check(input: "i", target: "ゐ").isComplete)
        #expect(engine.check(input: "wi", target: "ゐ").isComplete)
        
        // ゑ -> e (え)
        #expect(engine.check(input: "e", target: "ゑ").isComplete)
        #expect(engine.check(input: "we", target: "ゑ").isComplete)
        
        // を -> o (お)
        #expect(engine.check(input: "o", target: "を").isComplete)
        #expect(engine.check(input: "wo", target: "を").isComplete)

        // ぢ -> ji
        #expect(engine.check(input: "ji", target: "ぢ").isComplete)
        #expect(engine.check(input: "di", target: "ぢ").isComplete)

        // づ -> zu
        #expect(engine.check(input: "zu", target: "づ").isComplete)
        #expect(engine.check(input: "du", target: "づ").isComplete)
    }

    @Test func testPronunciationMappings() {
        // wa と読ませる「は」
        #expect(engine.check(input: "wa", target: "は").isComplete)
        #expect(engine.check(input: "ha", target: "は").isComplete)
        
        // e と読ませる「へ」
        #expect(engine.check(input: "e", target: "へ").isComplete)
        #expect(engine.check(input: "he", target: "へ").isComplete)
        
        // nn と読ませる「む」 (特に語末や撥音化)
        #expect(engine.check(input: "nn", target: "む").isComplete)
        #expect(engine.check(input: "n", target: "む").isComplete)
        #expect(engine.check(input: "mu", target: "む").isComplete)
        
        // o と読ませる「ほ」
        #expect(engine.check(input: "o", target: "ほ").isComplete)
        #expect(engine.check(input: "ho", target: "ほ").isComplete)
        
        // i と読ませる「ひ」
        #expect(engine.check(input: "i", target: "ひ").isComplete)
        #expect(engine.check(input: "hi", target: "ひ").isComplete)
        
        // u と読ませる「ふ」
        #expect(engine.check(input: "u", target: "ふ").isComplete)
        #expect(engine.check(input: "fu", target: "ふ").isComplete)
        #expect(engine.check(input: "hu", target: "ふ").isComplete)
    }

    @Test func testLongVowelAndDiphthongMappings() {
        // けふ -> きょう (kyou)
        #expect(engine.check(input: "kyou", target: "けふ").isComplete)
        #expect(engine.check(input: "kefu", target: "けふ").isComplete)
        
        // てふ -> ちょう (chou/tyou)
        #expect(engine.check(input: "chou", target: "てふ").isComplete)
        #expect(engine.check(input: "tyou", target: "てふ").isComplete)
        #expect(engine.check(input: "tefu", target: "てふ").isComplete)

        // あふ -> おう (ou) e.g. あふみがわ -> おうみがわ
        #expect(engine.check(input: "ou", target: "あふ").isComplete)
        #expect(engine.check(input: "afu", target: "あふ").isComplete)

        // かふ -> こう (kou)
        #expect(engine.check(input: "kou", target: "かふ").isComplete)
        #expect(engine.check(input: "kafu", target: "かふ").isComplete)

        // いう -> ゆう (yuu) e.g. うつくしう -> うつくしゅう
        #expect(engine.check(input: "yuu", target: "いう").isComplete)
        #expect(engine.check(input: "iu", target: "いう").isComplete)
    }

    @Test func testKwaGwaMappings() {
        // くわ -> ka
        #expect(engine.check(input: "ka", target: "くわ").isComplete)
        #expect(engine.check(input: "kuwa", target: "くわ").isComplete)

        // ぐわ -> ga
        #expect(engine.check(input: "ga", target: "ぐわ").isComplete)
        #expect(engine.check(input: "guwa", target: "ぐわ").isComplete)
    }
    
    @Test func testConsonantFeedback() {
        // 「ち」に対して 'c' を入力したとき、表示は "c"
        let result = engine.check(input: "c", target: "ち")
        #expect(result.displayString == "c")
        #expect(!result.isComplete)
        
        // 'ch' まで入力
        let result2 = engine.check(input: "ch", target: "ち")
        #expect(result2.displayString == "ch")
        #expect(!result2.isComplete)
        
        // 'chi' で完成
        let result3 = engine.check(input: "chi", target: "ち")
        #expect(result3.isComplete)
    }

    @Test func testSentenceMatching() {
        // 実際の百人一首のフレーズでのテスト
        // 「ころもほすてふ」 -> "koromohosuchou" など
        let target = "ころもほすてふ"
        #expect(engine.check(input: "koromohosuchou", target: target).isComplete)
        #expect(engine.check(input: "koromohosutefu", target: target).isComplete)
    }
}
