import SpriteKit

final class Trial7_FinalChoice: SKScene {
    private var finished = false

    override func didMove(to view: SKView) {
        backgroundColor = Palette.bg
        Audio.shared.start()
        Audio.shared.drone(freq: 42, duration: 2.0, volume: 0.07)
        Audio.shared.drone(freq: 48, duration: 2.0, volume: 0.08)

        let title = SKLabelNode(text: "ПОСЛЕДНИЙ ВЫБОР")
        title.fontName = "AvenirNext-Heavy"
        title.fontSize = 24
        title.fontColor = Palette.amber
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.82)
        addChild(title)

        let hint = SKLabelNode(text: "Выбери одну дверь")
        hint.fontName = "AvenirNext-Regular"
        hint.fontSize = 15
        hint.fontColor = Palette.textDim
        hint.position = CGPoint(x: size.width / 2, y: size.height * 0.75)
        addChild(hint)

        let left = makeChoice(title: "ОСТАТЬСЯ", x: size.width * 0.30, name: "choice_left")
        let right = makeChoice(title: "УЙТИ", x: size.width * 0.70, name: "choice_right")
        addChild(left)
        addChild(right)

        let back = SKShapeNode(rectOf: CGSize(width: 120, height: 42), cornerRadius: 10)
        back.position = CGPoint(x: 70, y: 35)
        back.fillColor = SKColor(white: 0.06, alpha: 1)
        back.strokeColor = Palette.textDim
        back.name = "backButton"
        let backText = SKLabelNode(text: "← НАЗАД")
        backText.fontName = "AvenirNext-Bold"
        backText.fontSize = 13
        backText.fontColor = Palette.text
        backText.verticalAlignmentMode = .center
        back.addChild(backText)
        addChild(back)
    }

    private func makeChoice(title: String, x: CGFloat, name: String) -> SKShapeNode {
        let b = SKShapeNode(rectOf: CGSize(width: size.width * 0.36, height: 110), cornerRadius: 12)
        b.position = CGPoint(x: x, y: size.height * 0.48)
        b.fillColor = SKColor(white: 0.06, alpha: 1)
        b.strokeColor = Palette.amber
        b.lineWidth = 2
        b.glowWidth = 4
        b.name = name

        let l = SKLabelNode(text: title)
        l.fontName = "AvenirNext-Bold"
        l.fontSize = 14
        l.fontColor = Palette.text
        l.verticalAlignmentMode = .center
        b.addChild(l)
        return b
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        if point.y < 80 && point.x < 150 {
            goBack()
            return
        }
        guard !finished else { return }

        for node in nodes(at: point) {
            var current: SKNode? = node
            while let candidate = current {
                if candidate.name == "choice_left" {
                    finish(1)
                    return
                }
                if candidate.name == "choice_right" {
                    finish(2)
                    return
                }
                current = candidate.parent
            }
        }
    }

    private func finish(_ ending: Int) {
        finished = true
        SaveManager.shared.setEnding(ending)
        UserDefaults.standard.set(ending, forKey: "school13.firstChoice")
        SaveManager.shared.complete(7)

        let result = SKLabelNode(text: ending == 1 ? "Ты остался." : "Ты ушёл.")
        result.fontName = "AvenirNext-Bold"
        result.fontSize = 22
        result.fontColor = Palette.amber
        result.position = CGPoint(x: size.width / 2, y: size.height * 0.30)
        addChild(result)

        run(.sequence([
            .wait(forDuration: 1.0),
            .run { [weak self] in self?.goBack() }
        ]))
    }

    private func goBack() {
        let hub = HubScene(size: size)
        hub.scaleMode = scaleMode
        view?.presentScene(hub, transition: .fade(withDuration: 0.25))
    }
}
