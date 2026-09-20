import SpriteKit

final class HubScene: SKScene {
    private let act: Int

    init(size: CGSize, act: Int = 1) {
        self.act = act
        super.init(size: size)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func didMove(to view: SKView) {
        backgroundColor = Palette.bg
        buildHeader()
        buildRooms()
        buildBackButton()
        buildActSwitch()
    }

    private func buildHeader() {
        let header = SKLabelNode(text: act == 1 ? "КАРТА ШКОЛЫ" : "ПОДВАЛ")
        header.fontName = "AvenirNext-Bold"
        header.fontSize = 24
        header.fontColor = act == 1 ? Palette.text : Palette.blood
        header.position = CGPoint(x: size.width * 0.5, y: size.height * 0.84)
        header.zPosition = 10
        addChild(header)
    }

    private func buildRooms() {
        let trials = act == 1 ? Trial.actOne : Trial.actTwo
        let positions: [CGPoint] = [
            CGPoint(x: size.width * 0.20, y: size.height * 0.70),
            CGPoint(x: size.width * 0.50, y: size.height * 0.70),
            CGPoint(x: size.width * 0.80, y: size.height * 0.70),
            CGPoint(x: size.width * 0.20, y: size.height * 0.48),
            CGPoint(x: size.width * 0.50, y: size.height * 0.48),
            CGPoint(x: size.width * 0.80, y: size.height * 0.48),
            CGPoint(x: size.width * 0.50, y: size.height * 0.26)
        ]

        for (index, trial) in trials.enumerated() {
            guard index < positions.count else { continue }

            let locked = isLocked(trial)
            let done = SaveManager.shared.data.completedTrials.contains(trial.rawValue)

            let node = SKShapeNode(rectOf: CGSize(width: size.width * 0.25, height: 70), cornerRadius: 10)
            node.position = positions[index]
            node.name = "trial_\(trial.rawValue)"
            node.fillColor = SKColor(white: 0.06, alpha: 1)
            node.strokeColor = locked ? Palette.textDim : (done ? Palette.amber : Palette.cyan)
            node.lineWidth = 2
            node.zPosition = 5

            let number = SKLabelNode(text: "\(trial.rawValue)")
            number.fontName = "AvenirNext-Bold"
            number.fontSize = 20
            number.fontColor = locked ? Palette.textDim : Palette.text
            number.position = CGPoint(x: -size.width * 0.25 / 2 + 20, y: 0)
            number.verticalAlignmentMode = .center
            number.name = "trial_\(trial.rawValue)"
            node.addChild(number)

            let title = SKLabelNode(text: locked ? "ЗАКРЫТО" : trial.title)
            title.fontName = "AvenirNext-Bold"
            title.fontSize = 11
            title.fontColor = locked ? Palette.textDim : Palette.text
            title.position = CGPoint(x: 8, y: 4)
            title.verticalAlignmentMode = .center
            title.name = "trial_\(trial.rawValue)"
            node.addChild(title)

            addChild(node)
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
            self.view?.presentScene(menu, transition: .fade(withDuration: 0.3))
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
            self.view?.presentScene(next, transition: .fade(withDuration: 0.3))
        }
        addChild(button)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        var current: SKNode? = atPoint(point)

        while let node = current {
            if let name = node.name,
               name.hasPrefix("trial_"),
               let raw = Int(name.dropFirst(6)),
               let trial = Trial(rawValue: raw) {
                guard !isLocked(trial) else {
                    Haptics.error()
                    return
                }
                launch(trial)
                return
            }
            current = node.parent
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
        case .mirrorHall: scene = Trial8_MirrorHall(size: size)
        case .candles: scene = Trial9_Candles(size: size)
        case .whispers: scene = Trial10_Whispers(size: size)
        case .shadows: scene = Trial11_Shadows(size: size)
        case .clock: scene = Trial12_Clock(size: size)
        case .rhyme: scene = Trial13_Rhyme(size: size)
        case .lastDesk: scene = Trial14_LastDesk(size: size)
        }

        scene.scaleMode = scaleMode
        view?.presentScene(scene, transition: .fade(withDuration: 0.25))
    }
}