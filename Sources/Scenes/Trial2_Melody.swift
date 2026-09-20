import SpriteKit

final class Trial2_Melody: SKScene {
    private var pads: [SKShapeNode] = []
    private let freqs: [Double] = [261.63, 329.63, 392.00, 523.25]
    private var sequence: [Int] = []
    private var inputIndex = 0
    private var round = 0
    private var acceptingInput = false
    private let maxRounds = 5

    override func didMove(to view: SKView) {
        backgroundColor = Palette.bgDeep
        addChild(VignetteNode(size: size, intensity: 0.85))

        let header = SKLabelNode(text: "МЕЛОДИЯ")
        header.fontName = "AvenirNext-Heavy"
        header.fontSize = 24
        header.fontColor = Palette.magenta
        header.position = CGPoint(x: size.width / 2, y: size.height * 0.92)
        addChild(header)

        let hint = SKLabelNode(text: "Повтори последовательность")
        hint.fontName = "AvenirNext-Regular"
        hint.fontSize = 14
        hint.fontColor = Palette.textDim
        hint.position = CGPoint(x: size.width / 2, y: size.height * 0.87)
        addChild(hint)

        buildPads()
        nextRound()
    }

    private func buildPads() {
        let w = size.width * 0.35
        let h = size.height * 0.18
        let positions = [
            CGPoint(x: size.width * 0.30, y: size.height * 0.60),
            CGPoint(x: size.width * 0.70, y: size.height * 0.60),
            CGPoint(x: size.width * 0.30, y: size.height * 0.38),
            CGPoint(x: size.width * 0.70, y: size.height * 0.38)
        ]
        let colors: [SKColor] = [Palette.cyan, Palette.magenta, Palette.amber, Palette.blood]

        for (i, position) in positions.enumerated() {
            let pad = SKShapeNode(rectOf: CGSize(width: w, height: h), cornerRadius: 16)
            pad.position = position
            pad.fillColor = colors[i].withAlphaComponent(0.15)
            pad.strokeColor = colors[i]
            pad.lineWidth = 2
            pad.glowWidth = 6
            pad.name = "pad_\\(i)"
            addChild(pad)
            pads.append(pad)
        }
    }

    private func nextRound() {
        round += 1
        if round > maxRounds {
            win()
            return
        }

        sequence.append(Int.random(in: 0..<4))
        inputIndex = 0
        acceptingInput = false
        playSequence()
    }

    private func playSequence() {
        var actions: [SKAction] = [.wait(forDuration: 0.4)]

        for idx in sequence {
            let pad = pads[idx]
            actions.append(.run { [weak self, weak pad] in
                guard let self, let pad else { return }
                Audio.shared.tone(freq: self.freqs[idx], duration: 0.28, volume: 0.3)
                pad.run(.sequence([
                    .scale(to: 1.08, duration: 0.12),
                    .scale(to: 1.0, duration: 0.12)
                ]))
                pad.fillColor = pad.strokeColor.withAlphaComponent(0.7)
                pad.run(.sequence([
                    .wait(forDuration: 0.2),
                    .run { [weak pad] in
                        guard let pad else { return }
                        pad.fillColor = pad.strokeColor.withAlphaComponent(0.15)
                    }
                ]))
            })
            actions.append(.wait(forDuration: 0.45))
        }

        actions.append(.run { [weak self] in self?.acceptingInput = true })
        run(.sequence(actions))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard acceptingInput, let point = touches.first?.location(in: self) else { return }

        var index: Int?
        for node in nodes(at: point) {
            if let name = node.name, name.hasPrefix("pad_") {
                index = Int(name.replacingOccurrences(of: "pad_", with: ""))
                break
            }
        }

        guard let idx = index, idx >= 0, idx < pads.count else { return }

        let pad = pads[idx]
        Audio.shared.tone(freq: freqs[idx], duration: 0.22, volume: 0.3)
        pad.run(.sequence([
            .scale(to: 1.08, duration: 0.08),
            .scale(to: 1.0, duration: 0.08)
        ]))
        pad.fillColor = pad.strokeColor.withAlphaComponent(0.7)
        pad.run(.sequence([
            .wait(forDuration: 0.15),
            .run { [weak pad] in
                guard let pad else { return }
                pad.fillColor = pad.strokeColor.withAlphaComponent(0.15)
            }
        ]))

        if sequence[inputIndex] == idx {
            inputIndex += 1
            if inputIndex == sequence.count {
                acceptingInput = false
                run(.sequence([
                    .wait(forDuration: 0.6),
                    .run { [weak self] in self?.nextRound() }
                ]))
            }
        } else {
            acceptingInput = false
            Haptics.error()
            FX.flash(on: self, color: Palette.blood, duration: 0.4)
            FX.shake(camera ?? self, intensity: 12, duration: 0.4)
            run(.sequence([
                .wait(forDuration: 0.8),
                .run { [weak self] in
                    guard let self else { return }
                    let hub = HubScene(size: self.size)
                    hub.scaleMode = self.scaleMode
                    self.view?.presentScene(hub, transition: .fade(withDuration: 0.5))
                }
            ]))
        }
    }

    private func win() {
        FX.flash(on: self, color: Palette.magenta, duration: 0.3)
        GameFlow.completeAndReturn(self, trial: .melody)
    }
}
