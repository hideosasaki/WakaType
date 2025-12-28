import Foundation

struct Card: Codable, Identifiable, Equatable {
    let id: Int
    let kamiNoKu: String
    let shimoNoKu: String
    let kamiNoKuKana: String
    let shimoNoKuKana: String
    let color: CardColor
    let kimariji: Int
}

enum CardColor: String, Codable {
    case blue, pink, yellow, green, orange
}
