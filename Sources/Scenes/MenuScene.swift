import SpriteKit

final class MenuScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = .black

        let title = SKLabelNode(text: "ШКОЛА №13")
        title.fontName = "AvenirNext-Bold"
        title.fontSize = 34
        title.fontColor = .white
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.68)
        addChild(title)

        let start = SKShapeNode(rectOf: CGSize(width: 240, height: 60), cornerRadius: 12)
        start.position = CGPoint(x: size.width / 2, y: size.height * 0.48)
        start.fillColor = SKColor(white: 0.08, alpha: 1)
        start.strokeColor = .white
        start.lineWidth = 2
        start.name = "start"
        addChild(start)

        let startLabel = SKLabelNode(text: "НАЧАТЬ")
        startLabel.fontName = "AvenirNext-Bold"
        startLabel.fontSize = 22
        startLabel.fontColor = .white
        startLabel.verticalAlignmentMode = .center
        startLabel.name = "start"
        start.addChild(startLabel)

        let hundred = SKShapeNode(rectOf: CGSize(width: 240, height: 52), cornerRadius: 12)
        hundred.position = CGPoint(x: size.width / 2, y: size.height * 0.32)
        hundred.fillColor = SKColor(white: 0.08, alpha: 1)
        hundred.strokeColor = SKColor(red: 0.9, green: 0.1, blue: 0.18, alpha: 1)
        hundred.lineWidth = 2
        hundred.name = "hundred"
        addChild(hundred)

        let hundredLabel = SKLabelNode(text: "100 ИСПЫТАНИЙ")
        hundredLabel.fontName = "AvenirNext-Bold"
        hundredLabel.fontSize = 18
        hundredLabel.fontColor = .white
        hundredLabel.verticalAlignmentMode = .center
        hundredLabel.name = "hundred"
        hundred.addChild(hundredLabel)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        var node: SKNode? = atPoint(point)

        while let current = node {
            if current.name == "start" {
                let hub = HubScene(size: size, act: 1)
                hub.scaleMode = scaleMode
                view?.presentScene(hub, transition: .fade(withDuration: 0.3))
                return
            }

            if current.name == "hundred" {
                let scene = HundredLevelsScene(size: size)
                scene.scaleMode = scaleMode
                view?.presentScene(scene, transition: .fade(withDuration: 0.3))
                return
            }

            node = current.parent
        }
    }
}
