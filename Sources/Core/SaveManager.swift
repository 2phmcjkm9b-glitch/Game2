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
    }

    private(set) var data: Data

    private init() {
        if let raw = defaults.data(forKey: key), let decoded = try? JSONDecoder().decode(Data.self, from: raw) {
            data = decoded
        } else { data = Data() }
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

    func setEnding(_ id: Int) { data.ending = id; save() }
    func setSignedNotebook(_ signed: Bool) { data.signedNotebook = signed; save() }

    private func recomputeUnlocks() {
        data.actTwoUnlocked = Trial.actOne.allSatisfy { data.completedTrials.contains($0.rawValue) }
    }

    func reset() { data = Data(); save() }

    var progressActOne: Double { Double(Trial.actOne.filter { data.completedTrials.contains($0.rawValue) }.count) / 7.0 }
    var progressActTwo: Double { Double(Trial.actTwo.filter { data.completedTrials.contains($0.rawValue) }.count) / 7.0 }
    var progress: Double { Double(data.completedTrials.count) / 14.0 }
}
