import Testing
import Foundation
@testable import WakaType

@MainActor
struct KanaConversionTests {
    
    let engine = TypingEngine()
    
    @Test func testBasicFiveOn() {
        // あいうえお
        #expect(engine.convertToKana("a") == "あ")
        #expect(engine.convertToKana("i") == "い")
        #expect(engine.convertToKana("u") == "う")
        #expect(engine.convertToKana("e") == "え")
        #expect(engine.convertToKana("o") == "お")
    }
    
    @Test func testConsonantConversion() {
        // かきくけこ
        #expect(engine.convertToKana("ka") == "か")
        #expect(engine.convertToKana("ki") == "き")
        #expect(engine.convertToKana("ku") == "く")
        #expect(engine.convertToKana("ke") == "け")
        #expect(engine.convertToKana("ko") == "こ")
        
        // さしすせそ
        #expect(engine.convertToKana("sa") == "さ")
        #expect(engine.convertToKana("shi") == "し")
        #expect(engine.convertToKana("si") == "し")
        #expect(engine.convertToKana("su") == "す")
        #expect(engine.convertToKana("se") == "せ")
        #expect(engine.convertToKana("so") == "そ")
    }
    
    @Test func testDoubleConsonantsAndComplex() {
        // っち、っさ 等 (xtu / tsu / double consonant)
        // 今回は単純な変換のみを対象とするが、タイピングゲームとしては打鍵中の暫定表示も重要
        #expect(engine.convertToKana("ta") == "た")
        #expect(engine.convertToKana("chi") == "ち")
        #expect(engine.convertToKana("ti") == "ち")
        #expect(engine.convertToKana("tsu") == "つ")
        #expect(engine.convertToKana("tu") == "つ")
    }
    
    @Test func testDiphthongs() {
        // きゃ、きゅ、きょ
        #expect(engine.convertToKana("kya") == "きゃ")
        #expect(engine.convertToKana("kyu") == "きゅ")
        #expect(engine.convertToKana("kyo") == "きょ")
    }
    
    @Test func testCombinedInput() {
        // 連続入力の変換
        #expect(engine.convertToKana("akita") == "あきた")
        #expect(engine.convertToKana("sushi") == "すし")
    }
    
    @Test func testUnfinishedInput() {
        // 変換途中の文字はそのまま残るべきか、あるいは空か？
        // IMEのように表示するなら、"k" は "k" のまま、"ka" で "か" になる必要がある
        #expect(engine.convertToKana("k") == "k")
        #expect(engine.convertToKana("sa") == "さ")
        #expect(engine.convertToKana("s") == "s")
        #expect(engine.convertToKana("sh") == "sh")
        #expect(engine.convertToKana("shi") == "し")
    }
    
    @Test func testNn() {
        #expect(engine.convertToKana("nn") == "ん")
        // n だけで次が母音でない場合の「ん」は、タイピングゲームの表示としては「n」のままの方が自然な場合もあるが、
        // ユーザーの要望は「aiueo -> あいうえお」なので、確定したものは変換する
    }

    @Test func testBackspaceConversion() {
        var input = "ka"
        #expect(engine.convertToKana(input) == "か")
        
        // 【要件変更】1文字削除 (aを消すと、'か'そのものが消える)
        // ロジック側（GameSession）で、表示上の1文字分に相当するローマ字を一括削除する必要がある
        // ここでは、その削除後の期待値をテストする
        input = engine.removeLastKanaBlock(from: "ka")
        #expect(input == "")
        
        // 複雑なケース: sh
        input = "shi"
        #expect(engine.convertToKana(input) == "し")
        input = engine.removeLastKanaBlock(from: "shi")
        #expect(input == "")
        
        // 連続入力のケース: akita
        input = "akita"
        #expect(engine.convertToKana(input) == "あきた")
        input = engine.removeLastKanaBlock(from: "akita")
        #expect(engine.convertToKana(input) == "あき")
        #expect(input == "aki")
        
        // 変換途中のケース: k
        input = "ak"
        #expect(engine.convertToKana(input) == "あk")
        input = engine.removeLastKanaBlock(from: "ak")
        #expect(engine.convertToKana(input) == "あ")
        #expect(input == "a")
    }
}
