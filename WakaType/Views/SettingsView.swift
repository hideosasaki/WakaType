import SwiftUI

struct SettingsView: View {
    @Binding var selectedColor: CardColor?
    @Binding var timeLimit: Int
    @Binding var mode: InputMode
    var onStart: () -> Void
    
    var body: some View {
        Form {
            Section("練習設定") {
                Picker("色の選択", selection: $selectedColor) {
                    Text("すべて").tag(CardColor?(nil))
                    Text("青").tag(CardColor?.some(.blue))
                    Text("ピンク").tag(CardColor?.some(.pink))
                    Text("黄色").tag(CardColor?.some(.yellow))
                    Text("緑").tag(CardColor?.some(.green))
                    Text("オレンジ").tag(CardColor?.some(.orange))
                }
                
                Stepper("制限時間: \(timeLimit)秒", value: $timeLimit, in: 3...60)
                
                Picker("入力モード", selection: $mode) {
                    Text("上の句 → 下の句").tag(InputMode.kamiToShimo)
                    Text("下の句 → 上の句").tag(InputMode.shimoToKami)
                    Text("全部タイピング").tag(InputMode.all)
                }
            }
            
            Button(action: onStart) {
                Text("練習開始")
                    .frame(maxWidth: .infinity)
                    .padding(8)
            }
            .accessibilityIdentifier("startButton")
            .buttonStyle(.borderedProminent)
            .padding(.top)
        }
        .padding()
        .frame(width: 300)
    }
}
