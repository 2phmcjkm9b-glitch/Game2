import SpriteKit

final class Trial14_LastDesk: SKScene {
    private var finished = false
    private var selected: Bool?

    override func didMove(to view: SKView) {
        backgroundColor = Palette.bgDeep
        Audio.shared.start()
        Audio.shared.drone(freq: 44, duration: 2.0, volume: 0.10)

        let title = SKLabelNode(text: "14. ПОСЛЕДНЯЯ ПАРТА")
        title.fontName = "AvenirNext-Heavy"
        title.fontSize = 23
        title.fontColor = Palette.blood
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.82)
        addChild(title)

        let hint = SKLabelNode(text: "Реши и подпиши тетрадь")
        hint.fontName = "AvenirNext-Regular"
        hint.fontSize = 15
        hint.fontColor = Palette.textDim
        hint.position = CGPoint(x: size.width / 2, y: size.height * 0.75)
        addChild(hint)

        let note = SKShapeNode(rectOf: CGSize(width: size.width * 0.76, height: 125), cornerRadius: 14)
        note.position = CGPoint(x: size.width / 2, y: size.height * 0.56)
        note.fillColor = SKColor(white: 0.07, alpha: 1)
        note.strokeColor = Palette.amber
        note.lineWidth = 2
        addChild(note)

        let riddle = SKLabelNode(text: "13 + 1 = ?")
        riddle.fontName = "AvenirNext-Heavy"
        riddle.fontSize = 28
        riddle.fontColor = Palette.text
        riddle.verticalAlignmentMode = .center
        note.addChild(riddle)

        let correct = makeChoice("14 — ПОДПИСАТЬ", x: size.width * 0.30, signed: true)
        let wrong = makeChoice("12 — НЕ ПОДПИСЫВАТЬ", x: size.width * 0.70, signed: false)
        addChild(correct)
        addChild(wrong)

        let back = SKShapeNode(rectOf: CGSize(width: 120, height: 42), cornerRadius: 10)
        back.position = CGPoint(x: 70, y: 35)
        back.fillColor = SKColor(white: 0.06, alpha: 1)
        back.strokeColor = Palette.textDim
        back.name = "backButton"
        let label = SKLabelNode(text: "← НАЗАД")
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 13
        label.fontColor = Palette.text
        label.verticalAlignmentMode = .center
        back.addChild(label)
        addChild(back)
    }

    private func makeChoice(_ text: String, x: CGFloat, signed: Bool) -> SKShapeNode {
        let button = SKShapeNode(rectOf: CGSize(width: size.width * 0.40, height: 90), cornerRadius: 12)
        button.position = CGPoint(x: x, y: size.height * 0.36)
        button.fillColor = SKColor(white: 0.06, alpha: 1)
        button.strokeColor = signed ? Palette.cyan : Palette.blood
        button.lineWidth = 2
        button.name = signed ? "signed_yes" : "signed_no"

        let label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 12
        label.fontColor = Palette.text
        label.verticalAlignmentMode = .center
        button.addChild(label)
        return button
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }

        var current: SKNode? = atPoint(point)
        while let node = current {
            if node.name == "backButton" {
                goBack()
                return
            }
            if node.name == "signed_yes" {
                finish(signed: true)
                return
            }
            if node.name == "signed_no" {
                finish(signed: false)
                return
            }
            current = node.parent
        }
    }

    private func finish(signed: Bool) {
        guard !finished else { return }
        finished = true
        selected = signed

        SaveManager.shared.setSignedNotebook(signed)

        let firstChoice = UserDefaults.standard.integer(forKey: "school13.firstChoice")
        let base = firstChoice == 2 ? 3 : 1
        let ending = signed ? base : base + 1
        SaveManager.shared.setEnding(ending)
        SaveManager.shared.complete(14)

        Haptics.success()
        Audio.shared.tone(freq: signed ? 880 : 120, duration: 0.45, volume: 0.25)
        FX.flash(on: self, color: signed ? Palette.cyan : Palette.blood, duration: 0.4)

        run(.sequence([
            .wait(forDuration: 0.8),
            .run { [weak self] in self?.showEnding() }
        ]))
    }

    private func showEnding() {
        let ending = EndingScene(size: size)
        ending.scaleMode = scaleMode
        view?.presentScene(ending, transition: .fade(withDuration: 0.7))
    }

    private func goBack() {
        let hub = HubScene(size: size, act: 2)
        hub.scaleMode = scaleMode
        view?.presentScene(hub, transition: .fade(withDuration: 0.25))
    }
}
