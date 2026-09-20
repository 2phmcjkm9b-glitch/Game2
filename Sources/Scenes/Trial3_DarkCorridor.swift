import SpriteKit

final class Trial3_DarkCorridor: SKScene {
    private var player: SKShapeNode!
    private var lightMask: SKShapeNode!
    private var obstacles: [(CGPoint, CGFloat)] = []
    private var exitNode: SKShapeNode!
    private var started = false
    private var finished = false
    private var startTime: TimeInterval = 0

    override func didMove(to view: SKView) {
        backgroundColor = .black

        let header = SKLabelNode(text: "ТЁМНЫЙ КОРИДОР")
        header.fontName = "AvenirNext-Heavy"
        header.fontSize = 22
        header.fontColor = Palette.cyan
        header.position = CGPoint(x: size.width / 2, y: size.height * 0.94)
        header.zPosition = 20000
        addChild(header)

        let hint = SKLabelNode(text: "Веди палец. Не задень тени.")
        hint.fontName = "AvenirNext-Regular"
        hint.fontSize = 13
        hint.fontColor = Palette.textDim
        hint.position = CGPoint(x: size.width / 2, y: size.height * 0.90)
        hint.zPosition = 20000
        addChild(hint)

        buildCorridor()
        Audio.shared.start()
        Audio.shared.drone(freq: 36, duration: 2.5, volume: 0.10)
        addBackButton()
    }

    private func buildCorridor() {
        let start = CGPoint(x: size.width * 0.5, y: size.height * 0.12)
        let exit = CGPoint(x: size.width * 0.5, y: size.height * 0.82)

        let crop = SKCropNode()
        crop.name = "lightCrop"
        crop.zPosition = 100
        addChild(crop)

        let world = SKNode()
        world.name = "world"
        crop.addChild(world)

        let mask = SKShapeNode(circleOfRadius: 112)
        mask.fillColor = .white
        mask.strokeColor = .clear
        crop.maskNode = mask
        lightMask = mask

        let walls = SKShapeNode(
            rectOf: CGSize(width: size.width * 0.70, height: size.height * 0.78),
            cornerRadius: 30
        )
        walls.position = CGPoint(x: size.width / 2, y: size.height * 0.47)
        walls.fillColor = SKColor(white: 0.08, alpha: 1)
        walls.strokeColor = SKColor(white: 0.22, alpha: 1)
        walls.lineWidth = 2
        world.addChild(walls)

        obstacles.removeAll()
        for _ in 0..<9 {
            let px = CGFloat.random(in: size.width * 0.25...size.width * 0.75)
            let py = CGFloat.random(in: size.height * 0.22...size.height * 0.72)
            let r = CGFloat.random(in: 22...38)
            obstacles.append((CGPoint(x: px, y: py), r))

            let obstacle = SKShapeNode(circleOfRadius: r)
            obstacle.position = CGPoint(x: px, y: py)
            obstacle.fillColor = SKColor(white: 0.015, alpha: 1)
            obstacle.strokeColor = Palette.blood.withAlphaComponent(0.18)
            obstacle.lineWidth = 1.5
            obstacle.name = "shadow"
            world.addChild(obstacle)
        }

        exitNode = SKShapeNode(circleOfRadius: 26)
        exitNode.position = exit
        exitNode.fillColor = Palette.amber.withAlphaComponent(0.22)
        exitNode.strokeColor = Palette.amber
        exitNode.lineWidth = 3
        exitNode.glowWidth = 12
        world.addChild(exitNode)
        exitNode.run(.repeatForever(.sequence([
            .scale(to: 1.15, duration: 0.9),
            .scale(to: 1.0, duration: 0.9)
        ])))

        player = SKShapeNode(circleOfRadius: 12)
        player.position = start
        player.fillColor = Palette.cyan
        player.strokeColor = .white
        player.lineWidth = 2
        player.glowWidth = 8
        world.addChild(player)

        lightMask.position = start

        let ring = SKShapeNode(circleOfRadius: 112)
        ring.fillColor = .clear
        ring.strokeColor = Palette.cyan.withAlphaComponent(0.12)
        ring.lineWidth = 2
        ring.zPosition = 500
        ring.name = "lightRing"
        addChild(ring)
    }

    private func addBackButton() {
        let b = SKShapeNode(rectOf: CGSize(width: 120, height: 42), cornerRadius: 10); b.position = CGPoint(x: 70, y: 35); b.fillColor = SKColor(white: 0.06, alpha: 1); b.strokeColor = Palette.textDim; b.name = "backButton"
        let l = SKLabelNode(text: "← НАЗАД"); l.fontName = "AvenirNext-Bold"; l.fontSize = 13; l.fontColor = Palette.text; l.verticalAlignmentMode = .center; b.addChild(l); addChild(b)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let p0 = touch.location(in: self)
        if p0.y < 80 && p0.x < 150 { let hub = HubScene(size: size); hub.scaleMode = scaleMode; view?.presentScene(hub, transition: .fade(withDuration: 0.25)); return }
        guard !finished else { return }
        if !started {
            started = true
            startTime = CACurrentMediaTime()
            Audio.shared.drone(freq: 40, duration: 3.0, volume: 0.12)
        }
        movePlayer(to: touch.location(in: self))
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !finished, let touch = touches.first else { return }
        movePlayer(to: touch.location(in: self))
    }

    private func movePlayer(to point: CGPoint) {
        guard player != nil, lightMask != nil else { return }

        let minX = size.width * 0.15
        let maxX = size.width * 0.85
        let minY = size.height * 0.08
        let maxY = size.height * 0.86
        let p = CGPoint(
            x: min(max(point.x, minX), maxX),
            y: min(max(point.y, minY), maxY)
        )

        player.position = p
        lightMask.position = p
        childNode(withName: "lightRing")?.position = p

        for (center, radius) in obstacles {
            if hypot(center.x - p.x, center.y - p.y) < radius + 10 {
                hit()
                return
            }
        }

        if hypot(exitNode.position.x - p.x, exitNode.position.y - p.y) < 30 {
            win()
        }
    }

    private func hit() {
        guard !finished else { return }
        finished = true
        started = false
        Haptics.error()
        FX.flash(on: self, color: Palette.blood, duration: 0.45)
        FX.shake(self, intensity: 8, duration: 0.3)
        Audio.shared.tone(freq: 90, duration: 0.5, volume: 0.3, type: .noise)

        run(.sequence([
            .wait(forDuration: 1.0),
            .run { [weak self] in
                guard let self else { return }
                let hub = HubScene(size: self.size)
                hub.scaleMode = self.scaleMode
                self.view?.presentScene(hub, transition: .fade(withDuration: 0.6))
            }
        ]))
    }

    private func win() {
        guard started, !finished else { return }
        finished = true
        started = false
        FX.flash(on: self, color: Palette.amber, duration: 0.3)
        GameFlow.completeAndReturn(
            self,
            trial: .darkCorridor,
            time: max(0, CACurrentMediaTime() - startTime)
        )
    }
}
