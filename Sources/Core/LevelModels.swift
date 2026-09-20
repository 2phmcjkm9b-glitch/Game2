import Foundation

enum LevelType: String, Codable {
    case findOdd, lightsOut, sequence, memoryGrid, mirrorMatch, shadows
    case wordChain, choice, reversedInput, countTrap
}

struct Level {
    let id: Int
    let chapter: Int
    let type: LevelType
    let title: String
    let hint: String?
    let difficulty: Int
    let params: [String: Double]
}
