import SpriteKit

final class Trial5_DontLookAway: SKScene {
    private var label: SKLabelNode!
    private var blinkCount = 0
    private var finished = false

    override func didMove(to view: SKView) {
        backgroundColor = Palette.bg
        Audio.shared.start()
        Audio.shared.drone(freq: 42, duration: 2.0, volume: 0.07)
        Audio.shared.drone(freq: 48, duration: 2.0, volume: 0.08)

        let title = SKLabelNode(text: "НЕ ОТВОДИ ВЗГЛЯД")
        title.fontName = "AvenirNext-Heavy"
        title.fontSize = 24
        title.fontColor = Palette.blood
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.86)
        addChild(title)

        label = SKLabelNode(text: "Смотри на точку")
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 20
        label.fontColor = Palette.text
        label.position = CGPoint(x: size.width / 2, y: size.height * 0.58)
        addChild(label)

        let target = SKShapeNode(circleOfRadius: 46)
        target.position = CGPoint(x: size.width / 2, y: size.height * 0.48)
        target.fillColor = Palette.blood.withAlphaComponent(0.12)
        target.strokeColor = Palette.blood
        target.lineWidth = 3
        target.glowWidth = 8
        target.name = "target"
        addChild(target)

        let back = makeBackButton()
        addChild(back)

        run(.sequence([
            .wait(forDuration: 1.5),
            .run { [weak self] in self?.label.text = "Нажми 3 раза" }
        ]))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        if point.y < 80 && point.x < 150 {
            goBack()
            return
        }
        guard !finished else { return }
        if nodes(at: point).contains(where: { $0.name == "target" || $0.parent?.name == "target" }) {
            blinkCount += 1
            label.text = "Фиксация \(blinkCount) / 3"
            if blinkCount >= 3 {
                finished = true
                SaveManager.shared.complete(5)
                run(.sequence([
                    .wait(forDuration: 0.5),
                    .run { [weak self] in self?.goBack() }
                ]))
            }
        }
    }

    private func makeBackButton() -> SKShapeNode {
        let b = SKShapeNode(rectOf: CGSize(width: 120, height: 42), cornerRadius: 10)
        b.position = CGPoint(x: 70, y: 35)
        b.fillColor = SKColor(white: 0.06, alpha: 1)
        b.strokeColor = Palette.textDim
        let l = SKLabelNode(text: "← НАЗАД")
        l.fontName = "AvenirNext-Bold"
        l.fontSize = 13
        l.fontColor = Palette.text
        l.verticalAlignmentMode = .center
        b.addChild(l)
        b.name = "backButton"
        return b
    }

    private func goBack() {
        let hub = HubScene(size: size)
        hub.scaleMode = scaleMode
        view?.presentScene(hub, transition: .fade(withDuration: 0.25))
    }
}
