import SpriteKit

final class Trial2_Melody: SKScene {
    private var pads: [SKShapeNode] = []
    private let maxRounds = 5
    private let freqs: [Double] = [261.63, 329.63, 392.00, 523.25]
    private var sequence: [Int] = []
    private var inputIndex = 0
    private var round = 0
    private var acceptingInput = false
    private var finished = false

    override func didMove(to view: SKView) {
        backgroundColor = Palette.bgDeep
        addChild(VignetteNode(size: size, intensity: 0.85))
        Audio.shared.start()
        Audio.shared.drone(freq: 52, duration: 2.0, volume: 0.10)

        let header = SKLabelNode(text: "МЕЛОДИЯ")
        header.fontName = "AvenirNext-Heavy"; header.fontSize = 24; header.fontColor = Palette.magenta
        header.position = CGPoint(x: size.width / 2, y: size.height * 0.88); addChild(header)

        let hint = SKLabelNode(text: "Повтори последовательность")
        hint.fontName = "AvenirNext-Regular"; hint.fontSize = 14; hint.fontColor = Palette.textDim
        hint.position = CGPoint(x: size.width / 2, y: size.height * 0.83); addChild(hint)

        buildPads()
        nextRound()
    }

    private func buildPads() {
        let w = size.width * 0.35, h = size.height * 0.15
        let positions = [
            CGPoint(x: size.width * 0.30, y: size.height * 0.57),
            CGPoint(x: size.width * 0.70, y: size.height * 0.57),
            CGPoint(x: size.width * 0.30, y: size.height * 0.38),
            CGPoint(x: size.width * 0.70, y: size.height * 0.38)
        ]
        let colors: [SKColor] = [Palette.cyan, Palette.magenta, Palette.amber, Palette.blood]
        for (i, position) in positions.enumerated() {
            let pad = SKShapeNode(rectOf: CGSize(width: w, height: h), cornerRadius: 16)
            pad.position = position; pad.fillColor = colors[i].withAlphaComponent(0.15)
            pad.strokeColor = colors[i]; pad.lineWidth = 2; pad.glowWidth = 6
            pad.name = "pad_\(i)"
            addChild(pad); pads.append(pad)
        }
    }

    private func nextRound() {
        guard !finished else { return }
        round += 1
        if round > maxRounds { win(); return }
        sequence.append(Int.random(in: 0..<4))
        inputIndex = 0; acceptingInput = false
        playSequence()
    }

    private func playSequence() {
        removeAction(forKey: "sequence")
        var actions: [SKAction] = [.wait(forDuration: 0.4)]
        for idx in sequence {
            let pad = pads[idx]
            actions.append(.run { [weak self, weak pad] in
                guard let self, let pad else { return }
                Audio.shared.tone(freq: self.freqs[idx], duration: 0.30, volume: 0.22, type: .sine)
                pad.run(.sequence([.scale(to: 1.08, duration: 0.12), .scale(to: 1.0, duration: 0.12)]))
                pad.fillColor = pad.strokeColor.withAlphaComponent(0.7)
                pad.run(.sequence([.wait(forDuration: 0.2), .run { [weak pad] in pad?.fillColor = pad?.strokeColor.withAlphaComponent(0.15) }]))
            })
            actions.append(.wait(forDuration: 0.45))
        }
        actions.append(.run { [weak self] in self?.acceptingInput = true })
        run(.sequence(actions), withKey: "sequence")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !finished, acceptingInput, let point = touches.first?.location(in: self) else { return }
        var index: Int?
        for node in nodes(at: point) {
            var current: SKNode? = node
            while let candidate = current {
                if let name = candidate.name, name.hasPrefix("pad_") { index = Int(name.dropFirst(4)); break }
                current = candidate.parent
            }
            if index != nil { break }
        }
        guard let idx = index, idx >= 0, idx < pads.count else { return }
        Audio.shared.tone(freq: freqs[idx], duration: 0.22, volume: 0.25)
        let pad = pads[idx]
        pad.run(.sequence([.scale(to: 1.08, duration: 0.08), .scale(to: 1.0, duration: 0.08)]))
        if sequence[inputIndex] == idx {
            inputIndex += 1
            if inputIndex == sequence.count {
                acceptingInput = false
                Audio.shared.tone(freq: 880, duration: 0.12, volume: 0.12)
                run(.sequence([.wait(forDuration: 0.6), .run { [weak self] in self?.nextRound() }]))
            }
        } else {
            finished = true; acceptingInput = false
            Haptics.error(); Audio.shared.tone(freq: 110, duration: 0.45, volume: 0.28, type: .noise)
            FX.flash(on: self, color: Palette.blood, duration: 0.4)
            run(.sequence([.wait(forDuration: 0.8), .run { [weak self] in self?.goBack() }]))
        }
    }

    private func win() {
        guard !finished else { return }
        finished = true; Audio.shared.tone(freq: 660, duration: 0.4, volume: 0.18)
        FX.flash(on: self, color: Palette.magenta, duration: 0.3)
        GameFlow.completeAndReturn(self, trial: .melody)
    }

    private func goBack() {
        let hub = HubScene(size: size); hub.scaleMode = scaleMode
        view?.presentScene(hub, transition: .fade(withDuration: 0.25))
    }
}
