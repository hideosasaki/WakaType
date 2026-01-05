import SwiftUI

struct ContentView: View {
    @State private var session: GameSession? = nil
    @State private var selectedColor: CardColor? = nil
    @State private var timeLimit: Int = 10
    @State private var mode: InputMode = .kamiToShimo
    
    var body: some View {
        Group {
            if let session = session {
                if session.state == .finished {
                    ResultView(session: session) {
                        self.session = nil
                    }
                } else {
                    GameView(session: session)
                }
            } else {
                SettingsView(selectedColor: $selectedColor, timeLimit: $timeLimit, mode: $mode) {
                    startSession()
                }
            }
        }
        .frame(minWidth: 500, minHeight: 400)
        .onAppear {
            setupAlwaysOnTop()
        }
    }
    
    private func startSession() {
        let repository = CardRepository.loadFromBundle()
        let cards = repository.getRandomCards(count: 10, color: selectedColor)
        session = GameSession(cards: cards, timeLimit: timeLimit, mode: mode)
    }
    
    private func setupAlwaysOnTop() {
        // macOS向けのAlways on Top設定
        #if os(macOS)
        if let window = NSApplication.shared.windows.first {
            window.level = .floating
        }
        #endif
    }
}
