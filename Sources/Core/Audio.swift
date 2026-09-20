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

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            try engine.start()
            started = true
        } catch {
            print("Audio start failed:", error)
            started = false
        }
    }

    func tone(freq: Double, duration: Double = 0.15, volume: Float = 0.25,
              type: Waveform = .sine) {
        start()
        guard engine.isRunning else { return }

        let format = engine.mainMixerNode.outputFormat(forBus: 0)
        guard format.sampleRate > 0, format.channelCount > 0 else { return }

        let frames = AVAudioFrameCount(max(1, Int(format.sampleRate * duration)))
        guard let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames) else { return }
        buf.frameLength = frames

        guard let channels = buf.floatChannelData else { return }

        for ch in 0..<Int(format.channelCount) {
            let data = channels[ch]
            for i in 0..<Int(frames) {
                let t = Double(i) / format.sampleRate
                let env = exp(-t * 6.0)
                let value: Double
                switch type {
                case .sine:
                    value = sin(2 * .pi * freq * t)
                case .square:
                    value = sin(2 * .pi * freq * t) >= 0 ? 1 : -1
                case .noise:
                    value = Double.random(in: -1...1)
                }
                data[i] = Float(value * env) * volume
            }
        }

        let player = AVAudioPlayerNode()
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        player.scheduleBuffer(buf, at: nil, options: []) { [weak self, weak player] in
            guard let self, let player else { return }
            player.stop()
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
