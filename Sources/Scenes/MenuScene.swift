import SpriteKit

final class MenuScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = Palette.bg

        let title = SKLabelNode(text: "ШКОЛА №13")
        title.fontName = "AvenirNext-Bold"
        title.fontSize = 42
        title.fontColor = Palette.cyan
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.68)
        title.verticalAlignmentMode = .center
        addChild(title)

        let start = SKLabelNode(text: "НАЧАТЬ")
        start.fontName = "AvenirNext-Bold"
        start.fontSize = 28
        start.fontColor = .white
        start.name = "startButton"
        start.position = CGPoint(x: size.width / 2, y: size.height * 0.45)
        start.verticalAlignmentMode = .center
        addChild(start)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }

        if nodes(at: point).contains(where: { node in
            var n: SKNode? = node
            while let current = n {
                if current.name == "startButton" { return true }
                n = current.parent
            }
            return false
        }) {
            let hub = HubScene(size: size)
            hub.scaleMode = scaleMode
            view?.presentScene(hub, transition: .fade(withDuration: 0.3))
        }
    }
}
