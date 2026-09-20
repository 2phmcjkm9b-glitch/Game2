import SpriteKit

final class Trial1_Mirror: SKScene {
    private var tiles: [SKShapeNode] = []
    private var oddIndex = 0
    private var timeLeft: Double = 25
    private var timerLabel: SKLabelNode!
    private var holdLabel: SKLabelNode!
    private var lastTick: TimeInterval = 0
    private var holdingIndex: Int?
    private var holdStartTime: TimeInterval = 0
    private let requiredHold: TimeInterval = 5.0

    override func didMove(to view: SKView) {
        backgroundColor = Palette.bgDeep
        addChild(VignetteNode(size: size, intensity: 0.9))

        let header = SKLabelNode(text: "ЗЕРКАЛО")
        header.fontName = "AvenirNext-Heavy"
        header.fontSize = 24
        header.fontColor = Palette.cyan
        header.position = CGPoint(x: size.width / 2, y: size.height * 0.92)
        addChild(header)

        timerLabel = SKLabelNode(text: "25.0")
        timerLabel.fontName = "AvenirNext-Bold"
        timerLabel.fontSize = 28
        timerLabel.fontColor = Palette.text
        timerLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.86)
        addChild(timerLabel)

        holdLabel = SKLabelNode(text: "НАЙДИ ОТЛИЧАЮЩУЮСЯ И УДЕРЖИВАЙ 5.0 СЕК")
        holdLabel.fontName = "AvenirNext-Bold"
        holdLabel.fontSize = 12
        holdLabel.fontColor = Palette.textDim
        holdLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.80)
        addChild(holdLabel)

        buildGrid()
        Audio.shared.drone(freq: 60, duration: 3.0, volume: 0.1)
    }

    private func buildGrid() {
        let cols = 4
        let rows = 5
        let margin: CGFloat = 24
        let gridW = size.width - margin * 2
        let gridH = size.height * 0.55
        let cellW = gridW / CGFloat(cols)
        let cellH = gridH / CGFloat(rows)
        let originY = size.height * 0.15

        let total = cols * rows
        oddIndex = Int.random(in: 0..<total)

        for i in 0..<total {
            let c = i % cols
            let r = i / cols
            let x = margin + cellW * (CGFloat(c) + 0.5)
            let y = originY + cellH * (CGFloat(rows - 1 - r) + 0.5)

            let rect = SKShapeNode(rectOf: CGSize(width: cellW - 8, height: cellH - 8), cornerRadius: 6)
            rect.position = CGPoint(x: x, y: y)
            rect.fillColor = SKColor(white: 0.10, alpha: 1)
            rect.strokeColor = SKColor(white: 0.35, alpha: 0.6)
            rect.lineWidth = 1
            rect.name = "tile_\(i)"

            let crack = SKShapeNode()
            let path = CGMutablePath()
            let w = (cellW - 8) * 0.5
            let h = (cellH - 8) * 0.5

            if i == oddIndex {
                path.move(to: CGPoint(x: -w, y: h))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: -w * 0.4, y: -h))
            } else {
                path.move(to: CGPoint(x: -w, y: h))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: w * 0.4, y: -h))
            }

            crack.path = path
            crack.strokeColor = SKColor(white: 0.65, alpha: 0.75)
            crack.lineWidth = 1.4
            crack.glowWidth = 0.6
            rect.addChild(crack)

            addChild(rect)
            tiles.append(rect)
        }
    }

    override func update(_ currentTime: TimeInterval) {
        if lastTick == 0 {
            lastTick = currentTime
            return
        }

        let dt = currentTime - lastTick
        lastTick = currentTime
        timeLeft -= dt
        timerLabel.text = String(format: "%.1f", max(0, timeLeft))

        if let idx = holdingIndex {
            let held = CACurrentMediaTime() - holdStartTime
            let remaining = max(0, requiredHold - held)
            holdLabel.text = String(format: "ДЕРЖИ... %.1f СЕК", remaining)
            if held < requiredHold {
                tiles[idx].glowWidth = 5 + CGFloat(held / requiredHold) * 10
            }
        }

        if timeLeft <= 0 {
            fail()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard holdingIndex == nil, let point = touches.first?.location(in: self) else { return }

        var index: Int?
        for node in nodes(at: point) {
            var current: SKNode? = node
            while let candidate = current {
                if let name = candidate.name, name.hasPrefix("tile_") {
                    index = Int(name.dropFirst(5))
                    break
                }
                current = candidate.parent
            }
            if index != nil { break }
        }

        guard let idx = index, idx >= 0, idx < tiles.count else { return }

        if idx == oddIndex {
            holdingIndex = idx
            holdStartTime = CACurrentMediaTime()
            holdLabel.text = "ДЕРЖИ... 5.0 СЕК"
            holdLabel.fontColor = Palette.cyan
            tiles[idx].strokeColor = Palette.cyan
            tiles[idx].glowWidth = 5
        } else {
            handleWrongTap(idx)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let idx = holdingIndex else { return }
        holdingIndex = nil

        let heldFor = CACurrentMediaTime() - holdStartTime
        if idx == oddIndex && heldFor >= requiredHold {
            tiles[idx].strokeColor = Palette.cyan
            tiles[idx].glowWidth = 10
            holdLabel.text = "ПРАВИЛЬНО!"
            FX.flash(on: self, color: Palette.cyan, duration: 0.25)
            GameFlow.completeAndReturn(self, trial: .mirror)
        } else {
            holdLabel.text = "СЛИШКОМ РАНО — ОТВЕТ НЕВЕРНЫЙ"
            holdLabel.fontColor = Palette.blood
            handleWrongTap(idx)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let idx = holdingIndex else { return }
        holdingIndex = nil
        holdLabel.text = "ОТПУСТИЛ — ОТВЕТ НЕВЕРНЫЙ"
        holdLabel.fontColor = Palette.blood
        handleWrongTap(idx)
    }

    private func handleWrongTap(_ idx: Int) {
        timeLeft -= 3
        Haptics.error()
        Audio.shared.tone(freq: 160, duration: 0.2, volume: 0.25, type: .square)
        FX.shake(camera ?? self, intensity: 10, duration: 0.3)
        tiles[idx].run(.sequence([
            .run { [weak self] in self?.tiles[idx].strokeColor = Palette.blood },
            .wait(forDuration: 0.4),
            .run { [weak self] in
                guard let self else { return }
                self.tiles[idx].strokeColor = SKColor(white: 0.35, alpha: 0.6)
                if self.holdingIndex == nil {
                    self.holdLabel.text = "НАЙДИ ОТЛИЧАЮЩУЮСЯ И УДЕРЖИВАЙ 5.0 СЕК"
                    self.holdLabel.fontColor = Palette.textDim
                }
            }
        ]))
    }

    private func fail() {
        holdingIndex = nil
        FX.flash(on: self, color: Palette.blood, duration: 0.5)
        Haptics.error()
        run(.sequence([
            .wait(forDuration: 1.0),
            .run { [weak self] in
                guard let self else { return }
                let hub = HubScene(size: self.size)
                hub.scaleMode = self.scaleMode
                self.view?.presentScene(hub, transition: .fade(withDuration: 0.5))
            }
        ]))
    }
}
