import SwiftUI

struct ResultView: View {
    let session: GameSession
    var onReset: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Text("練習終了")
                .font(.largeTitle.bold())
            
            VStack(alignment: .leading, spacing: 15) {
                ResultRow(label: "正解数", value: session.correctCount, color: .green)
                ResultRow(label: "間違い数", value: session.wrongCount, color: .red)
                ResultRow(label: "ギブアップ", value: session.giveUpCount, color: .orange)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(0.1)))
            
            Button("トップに戻る", action: onReset)
                .buttonStyle(.bordered)
        }
        .padding(60)
    }
}

struct ResultRow: View {
    let label: String
    let value: Int
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text("\(value)")
                .font(.title2.bold())
                .foregroundStyle(color)
        }
        .frame(width: 200)
    }
}
