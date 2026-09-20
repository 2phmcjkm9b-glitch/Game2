import SpriteKit

/// Безопасный каркас дополнительных испытаний 8–14.
/// Каждое испытание имеет свою задачу и может быть расширено отдельной механикой позже.
final class ExtraTrialScene: SKScene {
    private let trial: Trial
    private var progress = 0
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
        Audio.shared.drone(freq: 44, duration: 1.2, volume: 0.08)
        build()
    }

    private func build() {
        let title = SKLabelNode(text: "УРОВЕНЬ (trial.rawValue)")
        title.fontName = "AvenirNext-Heavy"
        title.fontSize = 25
        title.fontColor = Palette.cyan
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.80)
        addChild(title)

        let name = SKLabelNode(text: trial.title.uppercased())
        name.fontName = "AvenirNext-Bold"
        name.fontSize = 20
        name.fontColor = Palette.text
        name.position = CGPoint(x: size.width / 2, y: size.height * 0.74)
        addChild(name)

        let hint = SKLabelNode(text: trial.subtitle)
        hint.fontName = "AvenirNext-Regular"
        hint.fontSize = 14
        hint.fontColor = Palette.textDim
        hint.position = CGPoint(x: size.width / 2, y: size.height * 0.68)
        addChild(hint)

        let task = SKShapeNode(rectOf: CGSize(width: size.width * 0.78, height: 150), cornerRadius: 18)
        task.position = CGPoint(x: size.width / 2, y: size.height * 0.48)
        task.fillColor = SKColor(white: 0.05, alpha: 1)
        task.strokeColor = Palette.magenta
        task.lineWidth = 2
        task.glowWidth = 4
        task.name = "task"
        addChild(task)

        let instruction = SKLabelNode(text: instructionText)
        instruction.fontName = "AvenirNext-Medium"
        instruction.fontSize = 15
        instruction.fontColor = Palette.text
        instruction.position = CGPoint(x: 0, y: 10)
        instruction.name = "instruction"
        task.addChild(instruction)

        let action = SKLabelNode(text: "ПРОВЕРИТЬ")
        action.fontName = "AvenirNext-Bold"
        action.fontSize = 18
        action.fontColor = Palette.cyan
        action.position = CGPoint(x: 0, y: -42)
        action.name = "checkButton"
        task.addChild(action)

        let back = SKShapeNode(rectOf: CGSize(width: 120, height: 42), cornerRadius: 10)
        back.position = CGPoint(x: 76, y: 34)
        back.fillColor = SKColor(white: 0.06, alpha: 1)
        back.strokeColor = Palette.textDim
        back.lineWidth = 1.5
        back.name = "backButton"
        let backLabel = SKLabelNode(text: "←  НАЗАД")
        backLabel.fontName = "AvenirNext-Bold"
        backLabel.fontSize = 13
        backLabel.fontColor = Palette.text
        backLabel.verticalAlignmentMode = .center
        back.addChild(backLabel)
        addChild(back)
    }

    private var instructionText: String {
        switch trial {
        case .whisper: return "Нажми, когда услышишь шёпот."
        case .classroom: return "Найди предмет, которого здесь быть не должно."
        case .clock: return "Нажми три раза, чтобы вернуть стрелки."
        case .shadow: return "Нажми, когда тень остановится."
        case .locker: return "Подбери код из трёх знаков."
        case .footsteps: return "Нажми только после третьего шага."
        case .lastBell: return "Последний звонок уже близко."
        default: return "Продолжай."
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        for node in nodes(at: point) {
            var current: SKNode? = node
            while let candidate = current {
                if candidate.name == "backButton" {
                    goBack()
                    return
                }
                if candidate.name == "checkButton" || candidate.name == "task" {
                    complete()
                    return
                }
                current = candidate.parent
            }
        }
    }

    private func complete() {
        progress += 1
        Audio.shared.tone(freq: 660 + Double(progress * 80), duration: 0.12, volume: 0.2)
        if progress >= 1 {
            SaveManager.shared.complete(trial.rawValue, time: Date().timeIntervalSince(startedAt))
            let label = SKLabelNode(text: "ИСПЫТАНИЕ ПРОЙДЕНО")
            label.fontName = "AvenirNext-Heavy"
            label.fontSize = 19
            label.fontColor = Palette.cyan
            label.position = CGPoint(x: size.width / 2, y: size.height * 0.28)
            label.name = "completed"
            addChild(label)
            Haptics.success()
            run(.wait(forDuration: 0.8)) { [weak self] in self?.goBack() }
        }
    }

    private func goBack() {
        let hub = HubScene(size: size)
        hub.scaleMode = scaleMode
        view?.presentScene(hub, transition: .fade(withDuration: 0.25))
    }
}
