import Foundation

final class SaveManager {
    static let shared = SaveManager()
    private let key = "school13.save.v1"
    private let defaults = UserDefaults.standard

    struct Data: Codable {
        var completedTrials: Set<Int> = []
        var bestTime: [Int: Double] = [:]
        var ending: Int? = nil
        var seenIntro: Bool = false
    }

    private(set) var data: Data

    private init() {
        if let raw = defaults.data(forKey: key),
           let decoded = try? JSONDecoder().decode(Data.self, from: raw) {
            data = decoded
        } else {
            data = Data()
        }
    }

    func save() {
        if let raw = try? JSONEncoder().encode(data) {
            defaults.set(raw, forKey: key)
        }
    }

    func setEnding(_ ending: Int) {
        data.ending = ending
        save()
    }

    func complete(_ trial: Int, time: Double? = nil) {
        data.completedTrials.insert(trial)
        if let t = time, (data.bestTime[trial] ?? .infinity) > t {
            data.bestTime[trial] = t
        }
        save()
    }

    func reset() {
        data = Data()
        save()
    }

    var progress: Double {
        Double(data.completedTrials.count) / 7.0
    }
}
