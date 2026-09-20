import SpriteKit

final class Trial1_Mirror: SKScene {
    private var tiles: [SKShapeNode] = []
    private var oddIndex = 0
    private var timeLeft: Double = 25
    private var timerLabel: SKLabelNode!
    private var lastTick: TimeInterval = 0

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
            rect.name = "tile_(i)"

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

        if timeLeft <= 0 {
            fail()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }

        var index: Int?
        for node in nodes(at: point) {
            if let name = node.name, name.hasPrefix("tile_") {
                index = Int(name.replacingOccurrences(of: "tile_", with: ""))
                break
            }
            if let name = node.parent?.name, name.hasPrefix("tile_") {
                index = Int(name.replacingOccurrences(of: "tile_", with: ""))
                break
            }
        }

        guard let idx = index, idx >= 0, idx < tiles.count else { return }

        if idx == oddIndex {
            tiles[idx].strokeColor = Palette.cyan
            tiles[idx].glowWidth = 10
            FX.flash(on: self, color: Palette.cyan, duration: 0.25)
            GameFlow.completeAndReturn(self, trial: .mirror)
        } else {
            timeLeft -= 3
            Haptics.error()
            Audio.shared.tone(freq: 160, duration: 0.2, volume: 0.25, type: .square)
            FX.shake(camera ?? self, intensity: 10, duration: 0.3)
            tiles[idx].run(.sequence([
                .run { [weak self] in self?.tiles[idx].strokeColor = Palette.blood },
                .wait(forDuration: 0.4),
                .run { [weak self] in self?.tiles[idx].strokeColor = SKColor(white: 0.35, alpha: 0.6) }
            ]))
        }
    }

    private func fail() {
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
