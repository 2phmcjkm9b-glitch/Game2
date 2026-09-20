import Foundation

final class SaveManager {
    static let shared = SaveManager()
    private let key = "school13.save.v2"
    private let defaults = UserDefaults.standard

    struct Data: Codable {
        var completedTrials: Set<Int> = []
        var completedHundred: Set<Int> = []
        var bestTime: [Int: Double] = [:]
        var ending: Int? = nil
        var seenIntro: Bool = false
        var actTwoUnlocked: Bool = false
        var signedNotebook: Bool? = nil
        var puzzlePieces: Set<Int> = []
    }

    private(set) var data: Data

    private init() {
        if let raw = defaults.data(forKey: key) {
            if let decoded = try? JSONDecoder().decode(Data.self, from: raw) {
                data = decoded
            } else {
                // Migrate older saves that do not contain the puzzlePieces field.
                data = Data()
            }
        } else {
            data = Data()
        }
        recomputeUnlocks()
    }

    func save() {
        if let raw = try? JSONEncoder().encode(data) { defaults.set(raw, forKey: key) }
    }

    func completeHundred(_ level: Int) {
        data.completedHundred.insert(level)
        save()
    }

    func complete(_ trial: Int, time: Double? = nil) {
        data.completedTrials.insert(trial)
        if let t = time, (data.bestTime[trial] ?? .infinity) > t { data.bestTime[trial] = t }
        recomputeUnlocks()
        save()
    }

    func collectPuzzlePiece(_ piece: Int) {
        guard (1...5).contains(piece) else { return }
        data.puzzlePieces.insert(piece)
        save()
    }

    func hasPuzzlePiece(_ piece: Int) -> Bool {
        data.puzzlePieces.contains(piece)
    }

    func setEnding(_ id: Int) { data.ending = id; save() }
    func setSignedNotebook(_ signed: Bool) { data.signedNotebook = signed; save() }

    private func recomputeUnlocks() {
        let firstAct = Trial.storyOrder.filter { $0.act == 1 }
        data.actTwoUnlocked = firstAct.allSatisfy { data.completedTrials.contains($0.rawValue) }
    }

    func reset() { data = Data(); save() }

    var progressActOne: Double {
        let levels = Trial.storyOrder.filter { $0.act == 1 }
        return Double(levels.filter { data.completedTrials.contains($0.rawValue) }.count) / Double(max(1, levels.count))
    }
    var progressActTwo: Double {
        let levels = Trial.storyOrder.filter { $0.act == 2 }
        return Double(levels.filter { data.completedTrials.contains($0.rawValue) }.count) / Double(max(1, levels.count))
    }
    var progress: Double {
        let levels = Trial.storyOrder
        return Double(levels.filter { data.completedTrials.contains($0.rawValue) }.count) / Double(max(1, levels.count))
    }
}
