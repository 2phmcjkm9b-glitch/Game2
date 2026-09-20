import SpriteKit

final class MenuScene: SKScene {
    private var startButton: NeonButton!

    override func didMove(to view: SKView) {
        backgroundColor = Palette.bgDeep
        isUserInteractionEnabled = true

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

        startButton = NeonButton(title: "НАЧАТЬ", size: CGSize(width: 220, height: 58), color: Palette.cyan)
        startButton.name = "startButton"
        startButton.position = CGPoint(x: size.width / 2, y: size.height * 0.48)
        addChild(startButton)

        addChild(FX.vignette(size: size))
        FX.dust(in: self, count: 25)
    }

    private func startGame() {
        guard let skView = view else { return }
        Haptics.medium()
        let hub = HubScene(size: skView.bounds.size)
        hub.scaleMode = .resizeFill
        skView.presentScene(hub, transition: .doorsOpenVertical(withDuration: 0.5))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        guard startButton.calculateAccumulatedFrame().contains(point) else { return }
        startGame()
    }
}
