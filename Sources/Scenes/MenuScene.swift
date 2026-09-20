import SpriteKit

final class MenuScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = Palette.bg

        let title = SKLabelNode(text: "ШКОЛА №13")
        title.fontName = "AvenirNext-Bold"
        title.fontSize = 42
        title.fontColor = .white
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.68)
        addChild(title)

        let start = SKLabelNode(text: "НАЧАТЬ")
        start.fontName = "AvenirNext-Bold"
        start.fontSize = 28
        start.fontColor = .white
        start.name = "startButton"
        start.position = CGPoint(x: size.width / 2, y: size.height * 0.45)
        addChild(start)
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
