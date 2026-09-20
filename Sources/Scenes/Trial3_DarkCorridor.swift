import SpriteKit

final class Trial3_DarkCorridor: SKScene {
    private var player: SKShapeNode!
    private var obstacles: [(CGPoint, CGFloat)] = []
    private var exitNode: SKShapeNode!
    private var started = false
    private var startTime: TimeInterval = 0
    private var lastTime: TimeInterval = 0

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
    }

    private func buildCorridor() {
        let start = CGPoint(x: size.width * 0.5, y: size.height * 0.12)
        let exit = CGPoint(x: size.width * 0.5, y: size.height * 0.82)

        let world = SKNode()
        world.name = "world"
        addChild(world)

        let walls = SKShapeNode(
            rectOf: CGSize(width: size.width * 0.7, height: size.height * 0.78),
            cornerRadius: 30
        )
        walls.position = CGPoint(x: size.width / 2, y: size.height * 0.47)
        walls.fillColor = SKColor(white: 0.08, alpha: 1)
        walls.strokeColor = SKColor(white: 0.15, alpha: 1)
        walls.lineWidth = 2
        world.addChild(walls)

        for _ in 0..<9 {
            let px = CGFloat.random(in: size.width * 0.22...size.width * 0.78)
            let py = CGFloat.random(in: size.height * 0.22...size.height * 0.72)
            let r = CGFloat.random(in: 22...38)
            obstacles.append((CGPoint(x: px, y: py), r))

            let obstacle = SKShapeNode(circleOfRadius: r)
            obstacle.position = CGPoint(x: px, y: py)
            obstacle.fillColor = SKColor(white: 0.02, alpha: 1)
            obstacle.strokeColor = Palette.blood.withAlphaComponent(0.0)
            obstacle.lineWidth = 2
            obstacle.name = "shadow"
            world.addChild(obstacle)
        }

        exitNode = SKShapeNode(circleOfRadius: 26)
        exitNode.position = exit
        exitNode.fillColor = Palette.amber.withAlphaComponent(0.25)
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

        let light = SKLightNode()
        light.categoryBitMask = 0x1
        light.falloff = 2.0
        light.ambientColor = SKColor(white: 0.0, alpha: 1)
        light.lightColor = SKColor(white: 0.9, alpha: 1)
        light.position = player.position
        light.name = "playerLight"
        world.addChild(light)

        walls.lightingBitMask = 0x1
        for node in world.children where node.name == "shadow" {
            (node as? SKShapeNode)?.lightingBitMask = 0x1
        }
        exitNode.lightingBitMask = 0x1
        player.lightingBitMask = 0x1
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        if !started {
            started = true
            startTime = lastTime
            Audio.shared.drone(freq: 40, duration: 3.0, volume: 0.12)
        }

        movePlayer(to: touch.location(in: self))
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        movePlayer(to: touch.location(in: self))
    }

    private func movePlayer(to point: CGPoint) {
        guard let world = childNode(withName: "world"),
              let light = world.childNode(withName: "playerLight") else { return }

        player.run(.move(to: point, duration: 0.06))
        light.run(.move(to: point, duration: 0.06))

        for (center, radius) in obstacles {
            if hypot(center.x - point.x, center.y - point.y) < radius + 10 {
                hit()
                return
            }
        }

        if hypot(exitNode.position.x - point.x, exitNode.position.y - point.y) < 28 {
            win()
        }
    }

    private func hit() {
        started = false
        Haptics.error()
        FX.flash(on: self, color: Palette.blood, duration: 0.45)
        FX.shake(camera ?? self, intensity: 18, duration: 0.5)
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
        guard started else { return }
        started = false
        FX.flash(on: self, color: Palette.amber, duration: 0.3)
        GameFlow.completeAndReturn(self, trial: .darkCorridor, time: max(0, lastTime - startTime))
    }

    override func update(_ currentTime: TimeInterval) {
        lastTime = currentTime
    }
}
