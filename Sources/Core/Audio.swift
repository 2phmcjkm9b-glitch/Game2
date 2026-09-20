import AVFoundation

final class Audio {
    static let shared = Audio()
    private var started = false
    private let lock = NSLock()

    private init() {}

    func start() {
        lock.lock()
        defer { lock.unlock() }
        started = true
    }

    func tone(freq: Double, duration: Double = 0.15, volume: Float = 0.25,
              type: Waveform = .sine) {
        // Audio is intentionally guarded while scene transitions are stabilized.
        // This avoids AVAudioEngine attach/connect races that can terminate the app.
    }

    func drone(freq: Double = 55, duration: Double = 2, volume: Float = 0.12) {
        tone(freq: freq, duration: duration, volume: volume)
    }

    func whisper() {
        tone(freq: 200, duration: 0.6, volume: 0.08, type: .noise)
    }

    enum Waveform { case sine, square, noise }
}
