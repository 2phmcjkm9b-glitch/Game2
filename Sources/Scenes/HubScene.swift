import SpriteKit

final class HubScene: SKScene {
    private let trials: [Trial] = Trial.allCases
    private var didHandleTouch = false

    override func didMove(to view: SKView) {
        backgroundColor = Palette.bg
        buildUI()
        Audio.shared.start()
        Audio.shared.drone(freq: 48, duration: 2.5, volume: 0.08)
    }

    private func buildUI() {
        let title = SKLabelNode(text: "КАРТА ШКОЛЫ")
        title.fontName = "AvenirNext-Heavy"
        title.fontSize = 25
        title.fontColor = Palette.text
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.86)
        title.zPosition = 10
        addChild(title)

        let progress = SKLabelNode(text: "7 испытаний — все доступны")
        progress.fontName = "AvenirNext-Regular"
        progress.fontSize = 12
        progress.fontColor = Palette.textDim
        progress.position = CGPoint(x: size.width / 2, y: size.height * 0.82)
        progress.zPosition = 10
        addChild(progress)

        let cols = 2
        let cardW = size.width * 0.42
        let cardH = min(92.0, size.height * 0.115)
        let gapX = size.width * 0.045
        let startY = size.height * 0.70
        let gapY = cardH + 14

        for (index, trial) in trials.enumerated() {
            let row = index / cols
            let col = index % cols
            let x = col == 0 ? size.width / 2 - cardW / 2 - gapX / 2 : size.width / 2 + cardW / 2 + gapX / 2
            let y = startY - CGFloat(row) * gapY
            let card = makeCard(trial: trial, width: cardW, height: cardH)
            card.position = CGPoint(x: x, y: y)
            card.name = "trial_\(trial.rawValue)"
            addChild(card)
        }

        let back = makeButton(title: "←  НАЗАД", width: 120)
        back.position = CGPoint(x: 76, y: 34)
        back.name = "backButton"
        addChild(back)
    }

    private func makeCard(trial: Trial, width: CGFloat, height: CGFloat) -> SKNode {
        let node = SKNode()
        node.zPosition = 5
        let card = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 12)
        card.fillColor = SKColor(white: 0.055, alpha: 1)
        card.strokeColor = color(for: trial)
        card.lineWidth = 2
        card.glowWidth = 3
        card.name = "card"
        node.addChild(card)

        let number = SKLabelNode(text: "\(trial.rawValue)")
        number.fontName = "AvenirNext-Heavy"
        number.fontSize = 22
        number.fontColor = color(for: trial)
        number.position = CGPoint(x: -width / 2 + 28, y: 8)
        number.verticalAlignmentMode = .center
        node.addChild(number)

        let title = SKLabelNode(text: trial.title)
        title.fontName = "AvenirNext-Bold"
        title.fontSize = 13
        title.fontColor = Palette.text
        title.horizontalAlignmentMode = .left
        title.position = CGPoint(x: -width / 2 + 52, y: 14)
        node.addChild(title)

        let subtitle = SKLabelNode(text: trial.subtitle)
        subtitle.fontName = "AvenirNext-Regular"
        subtitle.fontSize = 10
        subtitle.fontColor = Palette.textDim
        subtitle.horizontalAlignmentMode = .left
        subtitle.position = CGPoint(x: -width / 2 + 52, y: -7)
        node.addChild(subtitle)

        let arrow = SKLabelNode(text: "›")
        arrow.fontName = "AvenirNext-Bold"
        arrow.fontSize = 26
        arrow.fontColor = color(for: trial)
        arrow.position = CGPoint(x: width / 2 - 18, y: 0)
        arrow.verticalAlignmentMode = .center
        node.addChild(arrow)
        return node
    }

    private func makeButton(title: String, width: CGFloat) -> SKShapeNode {
        let button = SKShapeNode(rectOf: CGSize(width: width, height: 42), cornerRadius: 10)
        button.fillColor = SKColor(white: 0.06, alpha: 1)
        button.strokeColor = Palette.textDim
        button.lineWidth = 1.5
        let label = SKLabelNode(text: title)
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 13
        label.fontColor = Palette.text
        label.verticalAlignmentMode = .center
        button.addChild(label)
        return button
    }

    private func color(for trial: Trial) -> SKColor {
        switch trial {
        case .mirror: return Palette.cyan
        case .melody: return Palette.magenta
        case .darkCorridor: return Palette.cyan
        case .doors: return Palette.amber
        case .dontLookAway: return Palette.blood
        case .notes: return Palette.text
        case .finalChoice: return Palette.amber
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !didHandleTouch, let point = touches.first?.location(in: self) else { return }
        didHandleTouch = true
        defer { didHandleTouch = false }
        for node in nodes(at: point) {
            var current: SKNode? = node
            while let candidate = current {
                if candidate.name == "backButton" {
                    let menu = MenuScene(size: size)
                    menu.scaleMode = scaleMode
                    view?.presentScene(menu, transition: .fade(withDuration: 0.25))
                    return
                }
                if let name = candidate.name, name.hasPrefix("trial_"), let raw = Int(name.dropFirst(6)), let trial = Trial(rawValue: raw) {
                    launch(trial)
                    return
                }
                current = candidate.parent
            }
        }
    }

    private func launch(_ trial: Trial) {
        let scene: SKScene
        switch trial {
        case .mirror: scene = Trial1_Mirror(size: size)
        case .melody: scene = Trial2_Melody(size: size)
        case .darkCorridor: scene = Trial3_DarkCorridor(size: size)
        case .doors: scene = Trial4_Doors(size: size)
        case .dontLookAway: scene = Trial5_DontLookAway(size: size)
        case .notes: scene = Trial6_Notes(size: size)
        case .finalChoice: scene = Trial7_FinalChoice(size: size)
        }
        scene.scaleMode = scaleMode
        view?.presentScene(scene, transition: .fade(withDuration: 0.3))
    }
}
