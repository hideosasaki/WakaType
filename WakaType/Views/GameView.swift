import SwiftUI

struct GameView: View {
    @Bindable var session: GameSession
    @FocusState private var isFocused: Bool
    @State private var blink: Bool = true
    
    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 30) {
            // タイマーメーター
            ProgressView(value: session.remainingTime, total: Double(session.timeLimit))
                .progressViewStyle(.linear)
                .tint(session.remainingTime < 3 ? .red : .accentColor)
                .frame(height: 4)
                .padding(.horizontal)

            if let card = session.currentCard {
                VStack(spacing: 20) {
                    // 出題エリア
                    Text(displayQuestion(card))
                        .font(.system(size: 48, weight: .medium, design: .serif))
                        .multilineTextAlignment(.center)
                        .frame(height: 100)
                    
                    if session.state == .memorizing {
                        VStack(spacing: 8) {
                            Text("正解を入力してください")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                            Text(session.targetString)
                                .font(.system(size: 48, weight: .bold, design: .serif))
                                .foregroundStyle(.primary)
                        }
                    }

                    // 入力エリア（直接表示）
                    HStack(spacing: 0) {
                        Text(session.displayedInput)
                            .accessibilityIdentifier("currentInputText")
                            .font(.system(size: 32, design: .monospaced))
                            .foregroundStyle(.primary)
                        
                        // カーソル
                        Rectangle()
                            .fill(Color.accentColor)
                            .frame(width: 2, height: 35)
                            .opacity(blink ? 1 : 0)
                            .onReceive(timer) { _ in
                                blink.toggle()
                            }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(0.1)))
                    .contentShape(Rectangle())
                    .accessibilityIdentifier("inputArea")
                    .onTapGesture {
                        isFocused = true
                    }
                }
            }
            
            // スコア表示
            HStack(spacing: 20) {
                Text("正解: \(session.correctCount)")
                    .foregroundStyle(.green)
                Text("間違い: \(session.wrongCount)")
                    .foregroundStyle(.red)
                Text("タイムアウト: \(session.giveUpCount)")
                    .foregroundStyle(.orange)
            }
            .font(.headline)
        }
        .padding(40)
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear {
            isFocused = true
        }
        .focusable()
        .focused($isFocused)
        .onKeyPress { press in
            handleKeyPress(press)
            return .handled
        }
    }
    
    private func displayQuestion(_ card: Card) -> String {
        switch session.mode {
        case .kamiToShimo: return card.kamiNoKuKana
        case .shimoToKami: return card.shimoNoKuKana
        case .all: return card.kamiNoKuKana + "\n" + card.shimoNoKuKana
        }
    }
    
    private func handleKeyPress(_ press: KeyPress) {
        let key = press.key
        let chars = press.characters
        
        if key == .return {
            session.submitCurrentInput()
            isFocused = true
        } else if key == .delete || key == .deleteForward || chars == "\u{7f}" || chars == "\u{08}" {
            session.backspace()
        } else {
            if chars.rangeOfCharacter(from: .alphanumerics.union(.punctuationCharacters).union(.symbols)) != nil {
                session.appendInput(chars)
            }
        }
    }
}
