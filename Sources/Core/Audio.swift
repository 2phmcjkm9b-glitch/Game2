import AVFoundation

final class Audio {
    static let shared = Audio()
    private let engine = AVAudioEngine()
    private var started = false
    private let lock = NSLock()

    private init() {}

    func start() {
        lock.lock()
        defer { lock.unlock() }
        guard !started else { return }
        started = true
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            try engine.start()
        } catch {
            print("Audio start failed:", error)
            started = false
        }
    }

    func tone(freq: Double, duration: Double = 0.15, volume: Float = 0.25,
              type: Waveform = .sine) {
        guard engine.isRunning else { return }
        let format = engine.mainMixerNode.outputFormat(forBus: 0)
        let sr = format.sampleRate
        let frames = AVAudioFrameCount(sr * duration)
        guard let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames) else { return }
        buf.frameLength = frames

        if let channels = buf.floatChannelData {
            let count = Int(frames)
            for ch in 0..<Int(format.channelCount) {
                let data = channels[ch]
                for i in 0..<count {
                    let t = Double(i) / sr
                    let env = exp(-t * 6.0)
                    let value: Double
                    switch type {
                    case .sine: value = sin(2 * .pi * freq * t)
                    case .square: value = sin(2 * .pi * freq * t) >= 0 ? 1 : -1
                    case .noise: value = Double.random(in: -1...1)
                    }
                    data[i] = Float(value * env) * volume
                }
            }
        }

        let player = AVAudioPlayerNode()
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        player.scheduleBuffer(buf, at: nil, options: []) { [weak self, weak player] in
            guard let self, let player else { return }
            self.engine.detach(player)
        }
        player.play()
    }

    func drone(freq: Double = 55, duration: Double = 2, volume: Float = 0.12) {
        tone(freq: freq, duration: duration, volume: volume)
    }

    func whisper() {
        tone(freq: 200, duration: 0.6, volume: 0.08, type: .noise)
    }

    enum Waveform { case sine, square, noise }
}
