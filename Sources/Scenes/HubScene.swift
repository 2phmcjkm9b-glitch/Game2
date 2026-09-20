import SpriteKit

final class HubScene: SKScene {
    private let act: Int
    private let layout: [(CGFloat, CGFloat)] = [
        (0.20, 0.72), (0.50, 0.72), (0.80, 0.72),
        (0.20, 0.48), (0.50, 0.48), (0.80, 0.48),
        (0.50, 0.23)
    ]

    init(size: CGSize, act: Int = 1) {
        self.act = act
        super.init(size: size)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func didMove(to view: SKView) {
        backgroundColor = Palette.bg
        FX.dust(in: self, count: 30)
        addChild(VignetteNode(size: size, intensity: act == 1 ? 0.8 : 0.92))
        buildHeader()
        buildRooms()
        buildBackButton()
        buildActSwitch()
        Audio.shared.start()
        Audio.shared.drone(
            freq: act == 1 ? 52 : 38,
            duration: 2.5,
            volume: act == 1 ? 0.07 : 0.11
        )
    }

    private func buildHeader() {
        let header = SKLabelNode(text: act == 1 ? "КАРТА ШКОЛЫ" : "ПОДВАЛ")
        header.fontName = "AvenirNext-Bold"
        header.fontSize = 24
        header.fontColor = act == 1 ? Palette.text : Palette.blood
        header.position = CGPoint(x: size.width / 2, y: size.height * 0.84)
        addChild(header)
    }

    private func buildRooms() {
        let trials = act == 1 ? Trial.actOne : Trial.actTwo
        for (index, trial) in trials.enumerated() {
            let p = CGPoint(
                x: size.width * layout[index].0,
                y: size.height * layout[index].1
            )
            let done = SaveManager.shared.data.completedTrials.contains(trial.rawValue)
            let locked = isLocked(trial)
            let door = makeDoor(trial, done: done, locked: locked)
            door.position = p
            door.name = "trial_(trial.rawValue)"
            addChild(door)
        }
    }

    private func isLocked(_ trial: Trial) -> Bool {
        if trial.act == 2 {
            return !SaveManager.shared.data.actTwoUnlocked
        }
        if trial.rawValue == 1 {
            return false
        }
        return !SaveManager.shared.data.completedTrials.contains(trial.rawValue - 1)
    }

    private func makeDoor(_ trial: Trial, done: Bool, locked: Bool) -> SKNode {
        let node = SKNode()
        let width = size.width * 0.26
        let height = size.height * 0.14

        let rect = SKShapeNode(
            rectOf: CGSize(width: width, height: height),
            cornerRadius: 12
        )
        rect.fillColor = SKColor(white: 0.05, alpha: 0.95)
        rect.strokeColor = locked
            ? SKColor(white: 0.25, alpha: 1)
            : (done ? Palette.amber : (act == 1 ? Palette.cyan : Palette.blood))
        rect.lineWidth = 2
        rect.glowWidth = locked ? 0 : (done ? 4 : 8)
        node.addChild(rect)

        let number = SKLabelNode(text: "(trial.rawValue)")
        number.fontName = "AvenirNext-Heavy"
        number.fontSize = 22
        number.fontColor = locked ? Palette.textDim : Palette.text
        number.position = CGPoint(x: -width / 2 + 22, y: 0)
        number.verticalAlignmentMode = .center
        node.addChild(number)

        let name = SKLabelNode(text: trial.title)
        name.fontName = "AvenirNext-Bold"
        name.fontSize = 12
        name.fontColor = locked ? Palette.textDim : Palette.text
        name.position = CGPoint(x: 12, y: 8)
        name.verticalAlignmentMode = .center
        node.addChild(name)

        let subtitle = SKLabelNode(
            text: locked ? "закрыто" : (done ? "✓ пройдено" : trial.subtitle)
        )
        subtitle.fontName = "AvenirNext-Regular"
        subtitle.fontSize = 9
        subtitle.fontColor = locked ? Palette.textDim : (done ? Palette.amber : Palette.textDim)
        subtitle.position = CGPoint(x: 12, y: -10)
        subtitle.verticalAlignmentMode = .center
        node.addChild(subtitle)

        return node
    }

    private func buildBackButton() {
        let button = NeonButton(
            title: "←",
            size: CGSize(width: 56, height: 44),
            color: Palette.textDim
        )
        button.position = CGPoint(x: 46, y: 34)
        button.action = { [weak self] in
            guard let self else { return }
            let menu = MenuScene(size: self.size)
            menu.scaleMode = self.scaleMode
            self.view?.presentScene(menu, transition: .fade(withDuration: 0.4))
        }
        addChild(button)
    }

    private func buildActSwitch() {
        guard SaveManager.shared.data.actTwoUnlocked else { return }

        let button = NeonButton(
            title: act == 1 ? "СПУСТИТЬСЯ В ПОДВАЛ ↓" : "ВЕРНУТЬСЯ НАВЕРХ ↑",
            size: CGSize(width: size.width * 0.72, height: 46),
            color: act == 1 ? Palette.blood : Palette.cyan
        )
        button.position = CGPoint(x: size.width / 2, y: 70)
        button.action = { [weak self] in
            guard let self else { return }
            let nextAct = self.act == 1 ? 2 : 1
            let next = HubScene(size: self.size, act: nextAct)
            next.scaleMode = self.scaleMode
            let transition = nextAct == 2
                ? SKTransition.doorsOpenVertical(withDuration: 0.7)
                : SKTransition.doorsCloseVertical(withDuration: 0.7)
            self.view?.presentScene(next, transition: transition)
        }
        addChild(button)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        var current: SKNode? = atPoint(point)

        while let node = current {
            if let name = node.name,
               name.hasPrefix("trial_"),
               let raw = Int(name.dropFirst(6)),
               let trial = Trial(rawValue: raw) {
                guard !isLocked(trial) else {
                    Haptics.error()
                    Audio.shared.tone(freq: 120, duration: 0.15, volume: 0.2, type: .square)
                    return
                }
                launch(trial)
                return
            }
            current = node.parent
        }
    }

    private func launch(_ trial: Trial) {
        Haptics.medium()
        Audio.shared.tone(freq: 880, duration: 0.1, volume: 0.2)

        let scene: SKScene
        switch trial {
        case .mirror:
            scene = Trial1_Mirror(size: size)
        case .melody:
            scene = Trial2_Melody(size: size)
        case .darkCorridor:
            scene = Trial3_DarkCorridor(size: size)
        case .doors:
            scene = Trial4_Doors(size: size)
        case .dontLookAway:
            scene = Trial5_DontLookAway(size: size)
        case .notes:
            scene = Trial6_Notes(size: size)
        case .finalChoice:
            scene = Trial7_FinalChoice(size: size)
        case .mirrorHall:
            scene = Trial8_MirrorHall(size: size)
        case .candles:
            scene = Trial9_Candles(size: size)
        case .whispers:
            scene = Trial10_Whispers(size: size)
        case .shadows:
            scene = Trial11_Shadows(size: size)
        case .clock:
            scene = Trial12_Clock(size: size)
        case .rhyme:
            scene = Trial13_Rhyme(size: size)
        case .lastDesk:
            scene = Trial14_LastDesk(size: size)
        }

        scene.scaleMode = scaleMode
        let transition = trial.act == 2
            ? SKTransition.doorsOpenVertical(withDuration: 0.6)
            : SKTransition.doorsOpenHorizontal(withDuration: 0.6)
        view?.presentScene(scene, transition: transition)
    }
}
