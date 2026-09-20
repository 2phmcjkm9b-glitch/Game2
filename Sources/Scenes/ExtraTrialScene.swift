import SpriteKit

final class ExtraTrialScene: SKScene {
    private let trial: Trial
    private var startedAt = Date()

    init(size: CGSize, trial: Trial) {
        self.trial = trial
        super.init(size: size)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func didMove(to view: SKView) {
        backgroundColor = Palette.bgDeep
        startedAt = Date()
        Audio.shared.start()

        let title = SKLabelNode(text: "\(trial.rawValue). \(trial.title.uppercased())")
        title.fontName = "AvenirNext-Heavy"
        title.fontSize = 23
        title.fontColor = Palette.blood
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.82)
        addChild(title)

        let hint = SKLabelNode(text: trial.subtitle)
        hint.fontName = "AvenirNext-Regular"
        hint.fontSize = 14
        hint.fontColor = Palette.textDim
        hint.position = CGPoint(x: size.width / 2, y: size.height * 0.75)
        addChild(hint)

        let task = SKShapeNode(
            rectOf: CGSize(width: size.width * 0.78, height: 180),
            cornerRadius: 18
        )
        task.position = CGPoint(x: size.width / 2, y: size.height * 0.48)
        task.fillColor = SKColor(white: 0.05, alpha: 1)
        task.strokeColor = Palette.blood
        task.lineWidth = 2
        task.name = "task"
        addChild(task)

        let instruction = SKLabelNode(text: "Выполни задание")
        instruction.fontName = "AvenirNext-Bold"
        instruction.fontSize = 15
        instruction.fontColor = Palette.text
        instruction.position = CGPoint(x: 0, y: 20)
        task.addChild(instruction)

        let action = SKLabelNode(text: "ВЫПОЛНИТЬ")
        action.fontName = "AvenirNext-Bold"
        action.fontSize = 18
        action.fontColor = Palette.cyan
        action.position = CGPoint(x: 0, y: -40)
        action.name = "action"
        task.addChild(action)

        let back = SKShapeNode(
            rectOf: CGSize(width: 120, height: 42),
            cornerRadius: 10
        )
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

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        var current: SKNode? = atPoint(point)
        while let node = current {
            if node.name == "backButton" {
                goBack()
                return
            }
            if node.name == "action" || node.name == "task" {
                complete()
                return
            }
            current = node.parent
        }
    }

    private func complete() {
        SaveManager.shared.complete(trial.rawValue, time: Date().timeIntervalSince(startedAt))
        Haptics.success()
        Audio.shared.tone(freq: 660, duration: 0.18, volume: 0.2)
        let hub = HubScene(size: size, act: trial.act)
        hub.scaleMode = scaleMode
        run(.wait(forDuration: 0.8)) { [weak self] in
            self?.view?.presentScene(hub, transition: .fade(withDuration: 0.25))
        }
    }

    private func goBack() {
        let hub = HubScene(size: size, act: trial.act)
        hub.scaleMode = scaleMode
        view?.presentScene(hub, transition: .fade(withDuration: 0.25))
    }
}
