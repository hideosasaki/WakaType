import Foundation

struct MatchResult {
    let displayString: String
    let isComplete: Bool
    let progress: Int
}

class TypingEngine {
    // 基本的なかな-ローマ字テーブル
    private let baseTable: [String: [String]] = [
        "あ": ["a"], "い": ["i"], "う": ["u"], "え": ["e"], "お": ["o"],
        "か": ["ka"], "き": ["ki"], "く": ["ku"], "け": ["ke"], "こ": ["ko"],
        "さ": ["sa"], "し": ["shi", "si"], "す": ["su"], "せ": ["se"], "そ": ["so"],
        "た": ["ta"], "ち": ["chi", "ti"], "つ": ["tsu", "tu"], "て": ["te"], "と": ["to"],
        "な": ["na"], "に": ["ni"], "ぬ": ["nu"], "ね": ["ne"], "の": ["no"],
        "は": ["ha", "wa"], "ひ": ["hi", "i"], "ふ": ["fu", "hu", "u"], "へ": ["he", "e"], "ほ": ["ho", "o"],
        "ま": ["ma"], "み": ["mi"], "む": ["mu", "n", "nn"], "め": ["me"], "も": ["mo"],
        "や": ["ya"], "ゆ": ["yu"], "よ": ["yo"],
        "ら": ["ra"], "り": ["ri"], "る": ["ru"], "れ": ["re"], "ろ": ["ro"],
        "わ": ["wa"], "を": ["wo", "o"], "ん": ["nn", "n"],
        "が": ["ga"], "ぎ": ["gi"], "ぐ": ["gu"], "げ": ["ge"], "ご": ["go"],
        "ざ": ["za"], "じ": ["ji", "zi"], "ず": ["zu"], "ぜ": ["ze"], "ぞ": ["zo"],
        "だ": ["da"], "ぢ": ["ji", "di"], "づ": ["zu", "du"], "で": ["de"], "ど": ["do"],
        "ば": ["ba"], "び": ["bi"], "ぶ": ["bu"], "べ": ["be"], "ぼ": ["bo"],
        "ぱ": ["pa"], "ぴ": ["pi"], "ぷ": ["pu"], "ぺ": ["pe"], "ぽ": ["po"],
        "きゃ": ["kya"], "きゅ": ["kyu"], "きょ": ["kyo"],
        "しゃ": ["sha", "sya"], "しゅ": ["shu", "syu"], "しょ": ["sho", "syo"],
        "ちゃ": ["cha", "tya"], "ちゅ": ["chu", "tyu"], "ちょ": ["cho", "tyo"],
        "にゃ": ["nya"], "にゅ": ["nyu"], "にょ": ["nyo"],
        "ひゃ": ["hya"], "ひゅ": ["hyu"], "ひょ": ["hyo"],
        "みゃ": ["mya"], "みゅ": ["myu"], "みょ": ["myo"],
        "りゃ": ["rya"], "りゅ": ["ryu"], "りょ": ["ryo"],
        "ぎゃ": ["gya"], "ぎゅ": ["gyu"], "ぎょ": ["gyo"],
        "じゃ": ["ja", "zya"], "じゅ": ["ju", "zyu"], "じょ": ["jo", "zyo"],
        "ぢゃ": ["ja", "dya"], "ぢゅ": ["ju", "dyu"], "ぢょ": ["jo", "dyo"],
        "びゃ": ["bya"], "びゅ": ["byu"], "びょ": ["byo"],
        "ぴゃ": ["pya"], "ぴゅ": ["pyu"], "ぴょ": ["pyo"],
        "ゐ": ["i", "wi"], "ゑ": ["e", "we"], "っ": ["-"] // っは別ロジックだが一応
    ]

    // 歴史的仮名遣いの二重母音・連母音による長音化マッピング
    // targetの2文字以上の並びに対して、一括で許容する配列
    private let specialLongVowels: [String: [String]] = [
        "けふ": ["kyou", "kefu"],
        "てふ": ["chou", "tyou", "tefu"],
        "あふ": ["ou", "afu"],
        "かふ": ["kou", "kafu"],
        "いう": ["yuu", "iu"],
        "くわ": ["ka", "kuwa"],
        "ぐわ": ["ga", "guwa"]
    ]

    func check(input: String, target: String) -> MatchResult {
        // 新しい再帰的マッチングロジックを使用
        if canMatch(input: input, target: target) {
            return MatchResult(displayString: input, isComplete: true, progress: target.count)
        }

        // 入力途中のフィードバック (子音チェック)
        if target == "ち" {
            if input == "c" || input == "t" { return MatchResult(displayString: input, isComplete: false, progress: 0) }
            if input == "ch" { return MatchResult(displayString: "ch", isComplete: false, progress: 0) }
        }

        return MatchResult(displayString: input, isComplete: false, progress: 0)
    }
    
    private func expandTargetRules(_ target: String) -> [String] {
        var results = [target]
        // 特殊な「てふ」などの置換を試す
        for (key, values) in specialLongVowels {
            if target.contains(key) {
                for v in values {
                    // かなをローマ字に置換した中間状態を作るなどの処理が必要
                }
            }
        }
        return results
    }

    private let romajiToKanaTable: [String: String] = [
        "a": "あ", "i": "い", "u": "う", "e": "え", "o": "お",
        "ka": "か", "ki": "き", "ku": "く", "ke": "け", "ko": "こ",
        "sa": "さ", "shi": "し", "si": "し", "su": "す", "se": "せ", "so": "そ",
        "ta": "た", "chi": "ち", "ti": "ち", "tsu": "つ", "tu": "つ", "te": "て", "to": "と",
        "na": "な", "ni": "に", "nu": "ぬ", "ne": "ね", "no": "の",
        "ha": "は", "hi": "ひ", "fu": "ふ", "hu": "ふ", "he": "へ", "ho": "ほ",
        "ma": "ま", "mi": "み", "mu": "む", "me": "め", "mo": "も",
        "ya": "や", "yu": "ゆ", "yo": "よ",
        "ra": "ら", "ri": "り", "ru": "る", "re": "れ", "ro": "ろ",
        "wa": "わ", "wo": "を", "nn": "ん", "n": "ん",
        "xa": "ぁ", "xi": "ぃ", "xu": "ぅ", "xe": "ぇ", "xo": "ぉ",
        "kya": "きゃ", "kyu": "きゅ", "kyo": "きょ",
        "sha": "しゃ", "shu": "しゅ", "sho": "しょ",
        "cha": "ちゃ", "chu": "ちゅう", "cho": "ちょ",
        "nya": "にゃ", "nyu": "にゅ", "nyo": "にょ",
        "hya": "ひゃ", "hyu": "ひゅ", "hyo": "ひょ",
        "mya": "みゃ", "myu": "みゅ", "myo": "みょ",
        "rya": "りゃ", "ryu": "りゅ", "ryo": "りょ",
        "ga": "が", "gi": "ぎ", "gu": "ぐ", "ge": "げ", "go": "ご",
        "za": "ざ", "ji": "じ", "zi": "じ", "zu": "ず", "ze": "ぜ", "zo": "ぞ",
        "da": "だ", "di": "ぢ", "du": "づ", "de": "で", "do": "ど",
        "ba": "ば", "bi": "び", "bu": "ぶ", "be": "べ", "bo": "ぼ",
        "pa": "ぱ", "pi": "ぴ", "pu": "ぷ", "pe": "ぺ", "po": "ぽ",
        "gya": "ぎゃ", "gyu": "ぎゅ", "gyo": "ぎょ",
        "ja": "じゃ", "ju": "じゅ", "jo": "じょ",
        "bya": "びゃ", "byu": "びゅ", "byo": "びょ",
        "pya": "ぴゃ", "pyu": "ぴゅ", "pyo": "ぴょ",
        "wi": "ゐ", "we": "ゑ", "va": "ヴぁ", "vi": "ヴぃ", "vu": "ヴ", "ve": "ヴぇ", "vo": "ヴぉ"
    ]

    func convertToKana(_ romaji: String) -> String {
        var result = ""
        let chars = Array(romaji.lowercased())
        var i = 0
        
        while i < chars.count {
            var matched = false
            for len in (1...3).reversed() {
                if i + len <= chars.count {
                    let substr = String(chars[i..<i+len])
                    if let kana = romajiToKanaTable[substr] {
                        result += kana
                        i += len
                        matched = true
                        break
                    }
                }
            }
            
            if !matched {
                if i + 1 < chars.count && chars[i] == chars[i+1] && !"aiueon".contains(chars[i]) {
                    result += "っ"
                    i += 1
                } else {
                    result += String(chars[i])
                    i += 1
                }
            }
        }
        
        return result
    }

    func removeLastKanaBlock(from romaji: String) -> String {
        guard !romaji.isEmpty else { return "" }
        
        var segments: [String] = []
        let chars = Array(romaji.lowercased())
        var i = 0
        
        while i < chars.count {
            var matched = false
            for len in (1...3).reversed() {
                if i + len <= chars.count {
                    let substr = String(chars[i..<i+len])
                    if romajiToKanaTable[substr] != nil {
                        segments.append(substr)
                        i += len
                        matched = true
                        break
                    }
                }
            }
            
            if !matched {
                if i + 1 < chars.count && chars[i] == chars[i+1] && !"aiueon".contains(chars[i]) {
                    segments.append(String(chars[i]))
                    i += 1
                } else {
                    segments.append(String(chars[i]))
                    i += 1
                }
            }
        }
        
        if !segments.isEmpty {
            segments.removeLast()
        }
        
        return segments.joined()
    }

    private func isMatch(input: String, target: String) -> Bool {
        return canMatch(input: input, target: target)
    }

    private func canMatch(input: String, target: String) -> Bool {
        // 入力とターゲットが共に空なら完全一致
        if input.isEmpty && target.isEmpty { return true }
        if target.isEmpty { return false }

        // 1. 特殊な複数文字の並び (履歴的仮名遣いの長音など) をチェック
        for (key, romajis) in specialLongVowels {
            if target.hasPrefix(key) {
                for r in romajis {
                    if input.hasPrefix(r) {
                        let nextInput = String(input.dropFirst(r.count))
                        let nextTarget = String(target.dropFirst(key.count))
                        if canMatch(input: nextInput, target: nextTarget) {
                            return true
                        }
                    }
                }
            }
        }

        // 2. 「拗音」などの複数文字かなのチェック (きゃ, しゃ等)
        if target.count >= 2 {
            let prefix2 = String(target.prefix(2))
            if let romajis = baseTable[prefix2] {
                for r in romajis {
                    if input.hasPrefix(r) {
                        if canMatch(input: String(input.dropFirst(r.count)), target: String(target.dropFirst(2))) {
                            return true
                        }
                    }
                }
            }
        }

        // 2.5 促音「っ」のチェック
        if target.hasPrefix("っ") {
            // "xtsu", "ltu" なども許容する場合
            let sokuonRomajis = ["xtsu", "ltu", "tsu", "tu"]
            for r in sokuonRomajis {
                if input.hasPrefix(r) {
                    if canMatch(input: String(input.dropFirst(r.count)), target: String(target.dropFirst(1))) {
                        return true
                    }
                }
            }

            // 次に文字がある場合の子音重ね
            if target.count >= 2 {
                // 拗音（きゃ等）の可能性を先にチェック
                if target.count >= 3 {
                    let yoonStr = String(target.dropFirst(1).prefix(2))
                    if let yoonRomajis = baseTable[yoonStr] {
                        for yr in yoonRomajis {
                            if let firstC = yr.first, input.hasPrefix(String(firstC) + yr) {
                                if canMatch(input: String(input.dropFirst(1 + yr.count)), target: String(target.dropFirst(3))) {
                                    return true
                                }
                            }
                        }
                    }
                }
                
                // 1文字の通常かな
                let nextChar = String(target.dropFirst(1).prefix(1))
                if let nextRomajis = baseTable[nextChar] {
                    for nr in nextRomajis {
                        if let firstC = nr.first, input.hasPrefix(String(firstC) + nr) {
                            if canMatch(input: String(input.dropFirst(1 + nr.count)), target: String(target.dropFirst(2))) {
                                return true
                            }
                        }
                    }
                }
            }
        }

        // 3. 基本的な1文字かなのチェック
        let firstChar = String(target.prefix(1))
        if let romajis = baseTable[firstChar] {
            for r in romajis {
                if input.hasPrefix(r) {
                    let nextInput = String(input.dropFirst(r.count))
                    let nextTarget = String(target.dropFirst(1))
                    if canMatch(input: nextInput, target: nextTarget) {
                        return true
                    }
                }
            }
        }

        // 4. フォールバック: テーブルにない文字 (記号など) の直接比較
        if !input.isEmpty && input.prefix(1) == target.prefix(1) {
            let nextInput = String(input.dropFirst(1))
            let nextTarget = String(target.dropFirst(1))
            if canMatch(input: nextInput, target: nextTarget) {
                return true
            }
        }

        return false
    }
}
