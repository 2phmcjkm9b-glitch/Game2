import SpriteKit

final class HubScene: SKScene {
    private var act: Int = 1

    init(size: CGSize, act: Int = 1) {
        super.init(size: size)
        self.act = act
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.act = 1
    }

    override func didMove(to view: SKView) {
        backgroundColor = Palette.bg

        let title = SKLabelNode(text: act == 1 ? "КАРТА ШКОЛЫ" : "ПОДВАЛ")
        title.fontName = "AvenirNext-Bold"
        title.fontSize = 24
        title.fontColor = .white
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.82)
        addChild(title)

        let info = SKLabelNode(text: "Выбери уровень")
        info.fontName = "AvenirNext-Medium"
        info.fontSize = 18
        info.fontColor = Palette.textDim
        info.position = CGPoint(x: size.width / 2, y: size.height * 0.74)
        addChild(info)

        let back = SKLabelNode(text: "← НАЗАД")
        back.fontName = "AvenirNext-Bold"
        back.fontSize = 20
        back.fontColor = .white
        back.name = "back"
        back.position = CGPoint(x: 70, y: 42)
        addChild(back)

        let first = SKLabelNode(text: act == 1 ? "УРОВЕНЬ 1" : "УРОВЕНЬ 8")
        first.fontName = "AvenirNext-Bold"
        first.fontSize = 28
        first.fontColor = Palette.cyan
        first.name = "testLevel"
        first.position = CGPoint(x: size.width / 2, y: size.height * 0.58)
        addChild(first)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        if nodes(at: point).contains(where: { $0.name == "back" }) {
            let menu = MenuScene(size: size)
            menu.scaleMode = scaleMode
            view?.presentScene(menu)
        }
    }
}