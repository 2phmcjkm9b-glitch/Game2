import SpriteKit

final class MenuScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = Palette.bgDeep
        FX.atmosphere(in: self, accent: Palette.magenta)

        let title = SKLabelNode(text: "ШКОЛА №13")
        title.fontName = "AvenirNext-Bold"
        title.fontSize = 42
        title.fontColor = .white
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.68)
        title.zPosition = 20
        addChild(title)
        FX.pulse(title, scale: 1.025, duration: 1.8)
        FX.glitchTitle(title)

        let panel = SKShapeNode(rectOf: CGSize(width: 190, height: 64), cornerRadius: 16)
        panel.position = CGPoint(x: size.width / 2, y: size.height * 0.45)
        panel.fillColor = SKColor(white: 0.05, alpha: 0.92)
        panel.strokeColor = Palette.magenta
        panel.lineWidth = 2
        panel.glowWidth = 8
        panel.name = "startButton"
        panel.zPosition = 10
        addChild(panel)
        let start = SKLabelNode(text: "НАЧАТЬ")
        start.fontName = "AvenirNext-Bold"
        start.fontSize = 28
        start.fontColor = .white
        start.name = "startButton"
        start.position = CGPoint(x: 0, y: 0)
        start.verticalAlignmentMode = .center
        start.name = "startButton"
        panel.addChild(start)
        FX.pulse(panel, scale: 1.04, duration: 1.1)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        let hit = nodes(at: point).contains { node in
            var current: SKNode? = node
            while let candidate = current {
                if candidate.name == "startButton" { return true }
                current = candidate.parent
            }
            return false
        }
        if hit {
            let hub = HubScene(size: size, act: 1)
            hub.scaleMode = scaleMode
            view?.presentScene(hub, transition: .fade(withDuration: 0.3))
        }
    }
}
