import SpriteKit

final class MenuScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = Palette.bgDeep

        let title = SKLabelNode(text: "ШКОЛА №13")
        title.fontName = "AvenirNext-Bold"
        title.fontSize = 34
        title.fontColor = Palette.text
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.68)
        addChild(title)

        let subtitle = SKLabelNode(text: "Семь испытаний. Один выход.")
        subtitle.fontName = "AvenirNext-Regular"
        subtitle.fontSize = 16
        subtitle.fontColor = Palette.textDim
        subtitle.position = CGPoint(x: size.width / 2, y: size.height * 0.61)
        addChild(subtitle)

        let button = NeonButton(title: "НАЧАТЬ", size: CGSize(width: 220, height: 58), color: Palette.cyan)
        button.position = CGPoint(x: size.width / 2, y: size.height * 0.48)
        button.action = { [weak self] in
            guard let self = self, let skView = self.view else { return }
            Haptics.medium()
            let hub = HubScene(size: skView.bounds.size)
            hub.scaleMode = .resizeFill
            skView.presentScene(hub, transition: .doorsOpenVertical(withDuration: 0.5))
        }
        addChild(button)

        addChild(FX.vignette(size: size))
        FX.dust(in: self, count: 25)
    }
}
