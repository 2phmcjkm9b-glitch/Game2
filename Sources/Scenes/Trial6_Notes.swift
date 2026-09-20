import SpriteKit

final class Trial6_Notes: SKScene {
    private var found = 0
    private var counter: SKLabelNode!
    private var finished = false

    override func didMove(to view: SKView) {
        backgroundColor = Palette.bg
        Audio.shared.start()
        Audio.shared.drone(freq: 42, duration: 2.0, volume: 0.07)

        let title = SKLabelNode(text: "ЗАПИСКИ")
        title.fontName = "AvenirNext-Heavy"
        title.fontSize = 24
        title.fontColor = Palette.text
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.88)
        addChild(title)

        counter = SKLabelNode(text: "Найдено: 0 / 5")
        counter.fontName = "AvenirNext-Bold"
        counter.fontSize = 17
        counter.fontColor = Palette.cyan
        counter.position = CGPoint(x: size.width / 2, y: size.height * 0.81)
        addChild(counter)

        let cols = 2
        let w = size.width * 0.36
        let h = size.height * 0.14
        for i in 0..<6 {
            let row = i / cols
            let col = i % cols
            let x = col == 0 ? size.width * 0.29 : size.width * 0.71
            let y = size.height * 0.62 - CGFloat(row) * (h + 18)
            let note = SKShapeNode(rectOf: CGSize(width: w, height: h), cornerRadius: 10)
            note.position = CGPoint(x: x, y: y)
            note.fillColor = SKColor(white: 0.08, alpha: 1)
            note.strokeColor = Palette.cyan.withAlphaComponent(0.65)
            note.lineWidth = 2
            note.name = "note_\(i)"
            let text = SKLabelNode(text: "???")
            text.fontName = "AvenirNext-Bold"
            text.fontSize = 13
            text.fontColor = Palette.text
            text.verticalAlignmentMode = .center
            note.addChild(text)
            addChild(note)
        }

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
                if let name = candidate.name, name.hasPrefix("note_"),
                   _ = Int(name.dropFirst(5)) {
                    if candidate.alpha > 0.5 {
                        candidate.alpha = 0.35
                        if let text = candidate.children.compactMap({ $0 as? SKLabelNode }).first {
                            text.text = "НАЙДЕНО"
                        }
                        found += 1
                        counter.text = "Найдено: \(found) / 5"
                        if found >= 5 {
                            finished = true
                            SaveManager.shared.complete(6)
                            run(.sequence([
                                .wait(forDuration: 0.5),
                                .run { [weak self] in self?.goBack() }
                            ]))
                        }
                    }
                    return
                }
                current = candidate.parent
            }
        }
    }

    private func goBack() {
        let hub = HubScene(size: size)
        hub.scaleMode = scaleMode
        view?.presentScene(hub, transition: .fade(withDuration: 0.25))
    }
}
