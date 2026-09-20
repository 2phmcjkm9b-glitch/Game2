import SpriteKit

final class Trial4_Doors: SKScene {
    private var doors: [SKShapeNode] = []
    private var sequence: [Int] = []
    private var inputIndex = 0
    private var round = 0
    private let maxRounds = 3
    private var hintLabel: SKLabelNode!
    private var roundLabel: SKLabelNode!
    private let symbols = ["☾", "✦", "◈", "✶"]
    private var accepting = false

    override func didMove(to view: SKView) {
        backgroundColor = Palette.bgDeep
        addChild(VignetteNode(size: size, intensity: 0.9))

        let header = SKLabelNode(text: "ДВЕРИ")
        header.fontName = "AvenirNext-Heavy"
        header.fontSize = 24
        header.fontColor = Palette.amber
        header.position = CGPoint(x: size.width / 2, y: size.height * 0.93)
        addChild(header)

        hintLabel = SKLabelNode(text: "")
        hintLabel.fontName = "AvenirNext-Bold"
        hintLabel.fontSize = 30
        hintLabel.fontColor = Palette.cyan
        hintLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.85)
        addChild(hintLabel)

        roundLabel = SKLabelNode(text: "Раунд 1 / 3")
        roundLabel.fontName = "AvenirNext-Regular"
        roundLabel.fontSize = 14
        roundLabel.fontColor = Palette.textDim
        roundLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.80)
        addChild(roundLabel)

        buildDoors()
        nextRound()
    }

    private func buildDoors() {
        let w = size.width * 0.40
        let h = size.height * 0.22
        let positions = [
            CGPoint(x: size.width * 0.28, y: size.height * 0.60),
            CGPoint(x: size.width * 0.72, y: size.height * 0.60),
            CGPoint(x: size.width * 0.28, y: size.height * 0.32),
            CGPoint(x: size.width * 0.72, y: size.height * 0.32)
        ]

        for (i, position) in positions.enumerated() {
            let door = SKShapeNode(rectOf: CGSize(width: w, height: h), cornerRadius: 10)
            door.position = position
            door.fillColor = SKColor(white: 0.05, alpha: 1)
            door.strokeColor = Palette.amber.withAlphaComponent(0.7)
            door.lineWidth = 2
            door.glowWidth = 4
            door.name = "door_(i)"

            let symbol = SKLabelNode(text: symbols[i])
            symbol.fontName = "AvenirNext-Bold"
            symbol.fontSize = 48
            symbol.fontColor = Palette.text
            symbol.verticalAlignmentMode = .center
            door.addChild(symbol)

            addChild(door)
            doors.append(door)
        }
    }

    private func nextRound() {
        round += 1
        if round > maxRounds {
            win()
            return
        }

        roundLabel.text = "Раунд (round) / (maxRounds)"
        sequence = (0..<(2 + round)).map { _ in Int.random(in: 0..<4) }
        inputIndex = 0
        accepting = false

        let preview = sequence.map { symbols[$0] }.joined(separator: "  ")
        hintLabel.text = preview
        hintLabel.alpha = 0
        hintLabel.run(.sequence([
            .fadeIn(withDuration: 0.3),
            .wait(forDuration: 1.4),
            .fadeOut(withDuration: 0.4),
            .run { [weak self] in
                self?.hintLabel.text = "?"
                self?.hintLabel.alpha = 1
                self?.accepting = true
            }
        ]))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard accepting, let point = touches.first?.location(in: self) else { return }

        var index: Int?
        for node in nodes(at: point) {
            if let name = node.name, name.hasPrefix("door_") {
                index = Int(name.replacingOccurrences(of: "door_", with: ""))
                break
            }
            if let name = node.parent?.name, name.hasPrefix("door_") {
                index = Int(name.replacingOccurrences(of: "door_", with: ""))
                break
            }
        }

        guard let idx = index, idx >= 0, idx < doors.count else { return }

        let door = doors[idx]
        Audio.shared.tone(freq: 440 + Double(idx) * 80, duration: 0.15, volume: 0.25)
        door.run(.sequence([
            .scale(to: 0.96, duration: 0.08),
            .scale(to: 1.0, duration: 0.08)
        ]))

        if sequence[inputIndex] == idx {
            door.strokeColor = Palette.cyan
            door.run(.sequence([
                .wait(forDuration: 0.3),
                .run { [weak self, weak door] in
                    guard let self, let door else { return }
                    door.strokeColor = Palette.amber.withAlphaComponent(0.7)
                }
            ]))
            inputIndex += 1

            if inputIndex == sequence.count {
                accepting = false
                run(.sequence([
                    .wait(forDuration: 0.5),
                    .run { [weak self] in self?.nextRound() }
                ]))
            }
        } else {
            accepting = false
            Haptics.error()
            FX.flash(on: self, color: Palette.blood, duration: 0.4)
            door.strokeColor = Palette.blood

            run(.sequence([
                .wait(forDuration: 0.9),
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
        FX.flash(on: self, color: Palette.amber, duration: 0.3)
        GameFlow.completeAndReturn(self, trial: .doors)
    }
}
