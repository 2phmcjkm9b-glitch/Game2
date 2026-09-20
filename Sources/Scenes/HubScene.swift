import SpriteKit

final class HubScene: SKScene {
    private var act: Int = 1
    private var levelNodes: [SKNode] = []

    init(size: CGSize, act: Int = 1) {
        super.init(size: size)
        self.act = act
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.act = 1
    }

    override func didMove(to view: SKView) {
        removeAllChildren()
        backgroundColor = Palette.bg
        FX.atmosphere(in: self, accent: act == 2 ? Palette.blood : Palette.cyan)
        buildHeader()
        buildLevels()
        buildBackButton()
    }

    private func buildHeader() {
        let title = SKLabelNode(text: act == 1 ? "КАРТА ШКОЛЫ" : "ПОДВАЛ")
        title.fontName = "AvenirNext-Bold"
        title.fontSize = 24
        title.fontColor = act == 1 ? Palette.text : Palette.blood
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.76)
        title.zPosition = 20
        addChild(title)
        FX.pulse(title, scale: 1.025, duration: 1.6)
        FX.glitchTitle(title)

        let subtitle = SKLabelNode(text: "АКТ \(act) • выбери доступный уровень")
        subtitle.fontName = "AvenirNext-Medium"
        subtitle.fontSize = 15
        subtitle.fontColor = Palette.textDim
        subtitle.position = CGPoint(x: size.width / 2, y: size.height * 0.71)
        subtitle.zPosition = 20
        addChild(subtitle)
    }

    private func buildLevels() {
        levelNodes.removeAll()

        let trials = act == 1 ? Array(Trial.allCases.filter { $0.rawValue <= 10 }) : Array(Trial.allCases.filter { $0.rawValue >= 11 })
        let positions: [CGPoint] = [
            CGPoint(x: size.width * 0.22, y: size.height * 0.64),
            CGPoint(x: size.width * 0.50, y: size.height * 0.64),
            CGPoint(x: size.width * 0.78, y: size.height * 0.64),
            CGPoint(x: size.width * 0.22, y: size.height * 0.47),
            CGPoint(x: size.width * 0.50, y: size.height * 0.47),
            CGPoint(x: size.width * 0.78, y: size.height * 0.47),
            CGPoint(x: size.width * 0.50, y: size.height * 0.30)
        ]

        for (index, trial) in trials.enumerated() where index < positions.count {
            let completed = SaveManager.shared.data.completedTrials.contains(trial.rawValue)
            // Все уровни открыты сразу для тестирования.
            let unlocked = true

            let node = SKShapeNode(rectOf: CGSize(width: size.width * 0.24, height: 76), cornerRadius: 12)
            node.position = positions[index]
            node.name = "level_\(trial.rawValue)"
            node.fillColor = SKColor(white: 0.07, alpha: 1)
            node.strokeColor = unlocked ? (completed ? Palette.amber : Palette.cyan) : Palette.textDim
            node.lineWidth = 2
            node.zPosition = 5

            let number = SKLabelNode(text: "\(trial.rawValue)")
            number.fontName = "AvenirNext-Heavy"
            number.fontSize = 25
            number.fontColor = unlocked ? Palette.text : Palette.textDim
            number.position = CGPoint(x: 0, y: 12)
            number.verticalAlignmentMode = .center
            number.name = node.name
            node.addChild(number)

            let label = SKLabelNode(text: unlocked ? trial.title : "ЗАКРЫТО")
            label.fontName = "AvenirNext-Bold"
            label.fontSize = 10
            label.fontColor = unlocked ? Palette.text : Palette.textDim
            label.position = CGPoint(x: 0, y: -18)
            label.verticalAlignmentMode = .center
            label.name = node.name
            node.addChild(label)

            addChild(node)
            FX.pulse(node, scale: 1.025, duration: 1.7 + Double(index % 3) * 0.2)
            node.run(.fadeAlpha(to: 0.82, duration: 0.01))
            levelNodes.append(node)
        }
    }

    private func buildBackButton() {
        let back = SKLabelNode(text: "← НАЗАД")
        back.fontName = "AvenirNext-Bold"
        back.fontSize = 20
        back.fontColor = Palette.text
        back.name = "back"
        back.position = CGPoint(x: 68, y: 40)
        back.zPosition = 30
        addChild(back)

        let switchButton = SKLabelNode(text: act == 1 ? "АКТ II →" : "← АКТ I")
        switchButton.fontName = "AvenirNext-Bold"
        switchButton.fontSize = 18
        switchButton.fontColor = Palette.blood
        switchButton.name = "switchAct"
        switchButton.position = CGPoint(x: size.width - 68, y: 40)
        switchButton.zPosition = 30
        addChild(switchButton)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }

        var node: SKNode? = atPoint(point)
        while let current = node {
            if current.name == "back" {
                let menu = MenuScene(size: size)
                menu.scaleMode = scaleMode
                view?.presentScene(menu, transition: .fade(withDuration: 0.25))
                return
            }

            if current.name == "switchAct" {
                let nextAct = act == 1 ? 2 : 1
                let hub = HubScene(size: size, act: nextAct)
                hub.scaleMode = scaleMode
                view?.presentScene(hub, transition: .fade(withDuration: 0.25))
                return
            }

            if let name = current.name, name.hasPrefix("level_"),
               let raw = Int(name.dropFirst(6)),
               let trial = Trial(rawValue: raw) {
                launchIfUnlocked(trial)
                return
            }

            node = current.parent
        }
    }

    private func launchIfUnlocked(_ trial: Trial) {
        // Все уровни временно открыты для тестирования.
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
        case .director: scene = Trial15_Director(size: size)
        case .stairs: scene = Trial16_Stairs(size: size)
                case .classZero: scene = Trial18_ClassZero(size: size)
                case .schoolBell: scene = Trial20_SchoolBell(size: size)
        case .lastDoor: scene = Trial21_LastDoor(size: size)
        }

        scene.scaleMode = scaleMode
        view?.presentScene(scene, transition: .fade(withDuration: 0.25))
    }
}