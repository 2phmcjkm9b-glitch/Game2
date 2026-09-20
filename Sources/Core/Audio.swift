import AVFoundation

final class Audio {
    static let shared = Audio()

    private var players: [AVAudioPlayer] = []
    private let lock = NSLock()
    private var started = false

    private init() {}

    func start() {
        lock.lock()
        defer { lock.unlock() }
        guard !started else { return }
        started = true
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            // Sound is non-fatal: the game must continue if audio is unavailable.
        }
    }

    func tone(
        freq: Double,
        duration: Double = 0.15,
        volume: Float = 0.25,
        type: Waveform = .sine
    ) {
        start()

        let sampleRate = 44_100.0
        let count = max(1, Int(sampleRate * max(0.03, duration)))
        let channels = 1
        let bytesPerSample = 2
        let dataSize = count * channels * bytesPerSample

        var wav = Data()
        wav.append(contentsOf: [UInt8]("RIFF".utf8))
        appendLE32(to: &wav, UInt32(36 + dataSize))
        wav.append(contentsOf: [UInt8]("WAVE".utf8))
        wav.append(contentsOf: [UInt8]("fmt ".utf8))
        appendLE32(to: &wav, 16)
        appendLE16(to: &wav, 1)
        appendLE16(to: &wav, UInt16(channels))
        appendLE32(to: &wav, UInt32(sampleRate))
        appendLE32(to: &wav, UInt32(Int(sampleRate) * channels * bytesPerSample))
        appendLE16(to: &wav, UInt16(channels * bytesPerSample))
        appendLE16(to: &wav, 16)
        wav.append(contentsOf: [UInt8]("data".utf8))
        appendLE32(to: &wav, UInt32(dataSize))

        let safeFreq = max(20.0, min(freq, sampleRate / 2.0 - 100.0))
        let safeVolume = max(0.0, min(volume, 1.0))

        for i in 0..<count {
            let t = Double(i) / sampleRate
            let envelope = min(1.0, t / 0.015) * min(1.0, (duration - t) / 0.04)
            let wave: Double

            switch type {
            case .sine:
                wave = sin(2.0 * .pi * safeFreq * t)
            case .square:
                wave = sin(2.0 * .pi * safeFreq * t) >= 0 ? 1.0 : -1.0
            case .noise:
                wave = Double.random(in: -1.0...1.0)
            }

            let shaped = wave * safeVolume
            let faded = shaped * max(0.0, envelope)
            let clipped = max(-1.0, min(1.0, faded))
            let sampleValue = clipped * 32767.0
            let sample = Int16(sampleValue)
            appendLE16(to: &wav, UInt16(bitPattern: sample))
        }

        do {
            let player = try AVAudioPlayer(data: wav)
            player.prepareToPlay()
            player.volume = safeVolume
            player.play()

            lock.lock()
            players.removeAll { !$0.isPlaying }
            players.append(player)
            lock.unlock()
        } catch {
            // Never let an audio failure crash gameplay.
        }
    }

    func drone(freq: Double = 55, duration: Double = 2, volume: Float = 0.12) {
        tone(freq: freq, duration: duration, volume: volume)
    }

    func whisper() {
        tone(freq: 200, duration: 0.6, volume: 0.08, type: .noise)
    }

    enum Waveform {
        case sine
        case square
        case noise
    }

    private func appendLE16(to data: inout Data, _ value: UInt16) {
        data.append(UInt8(value & 0xff))
        data.append(UInt8((value >> 8) & 0xff))
    }

    private func appendLE32(to data: inout Data, _ value: UInt32) {
        data.append(UInt8(value & 0xff))
        data.append(UInt8((value >> 8) & 0xff))
        data.append(UInt8((value >> 16) & 0xff))
        data.append(UInt8((value >> 24) & 0xff))
    }
}
