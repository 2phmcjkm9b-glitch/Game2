import SpriteKit

final class HubScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = Palette.bg

        let title = SKLabelNode(text: "ИСПЫТАНИЯ")
        title.fontName = "AvenirNext-Bold"
        title.fontSize = 30
        title.fontColor = Palette.cyan
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.86)
        title.verticalAlignmentMode = .center
        addChild(title)

        let info = SKLabelNode(text: "Выберите испытание")
        info.fontName = "AvenirNext-Regular"
        info.fontSize = 18
        info.fontColor = Palette.textDim
        info.position = CGPoint(x: size.width / 2, y: size.height * 0.76)
        info.verticalAlignmentMode = .center
        addChild(info)

        let start = SKLabelNode(text: "ИСПЫТАНИЕ 1  —  ЗЕРКАЛО")
        start.fontName = "AvenirNext-Bold"
        start.fontSize = 20
        start.fontColor = Palette.text
        start.name = "trial1"
        start.position = CGPoint(x: size.width / 2, y: size.height * 0.55)
        start.verticalAlignmentMode = .center
        addChild(start)

        let back = SKLabelNode(text: "← НАЗАД")
        back.fontName = "AvenirNext-Bold"
        back.fontSize = 18
        back.fontColor = Palette.textDim
        back.name = "back"
        back.position = CGPoint(x: size.width / 2, y: size.height * 0.18)
        back.verticalAlignmentMode = .center
        addChild(back)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }

        for node in nodes(at: point) {
            if node.name == "back" {
                let menu = MenuScene(size: size)
                menu.scaleMode = .resizeFill
                view?.presentScene(menu)
                return
            }

            if node.name == "trial1" {
                // Пока проверяем сам переход отдельно от сложных игровых сцен.
                let scene = Trial1_Mirror(size: size)
                scene.scaleMode = .resizeFill
                view?.presentScene(scene)
                return
            }
        }
    }
}
