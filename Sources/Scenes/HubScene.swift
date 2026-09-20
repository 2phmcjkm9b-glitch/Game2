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
        let accent = act == 2 ? Palette.blood : Palette.cyan
        FX.atmosphere(in: self, accent: accent)
        FX.scanline(in: self, color: accent)
        buildHeader()
        buildLevels()
        buildBackButton()
        addChild(FX.vignette(size: size, intensity: 0.68))
    }

    private func buildHeader() {
        let tag = SKLabelNode(text: act == 1 ? "ЗАПАДНОЕ КРЫЛО" : "НИЖНИЙ УРОВЕНЬ")
        tag.fontName = "AvenirNext-Bold"
        tag.fontSize = 10
        tag.fontColor = act == 1 ? Palette.cyan : Palette.blood
        tag.position = CGPoint(x: size.width / 2, y: size.height * 0.86)
        tag.zPosition = 20
        addChild(tag)

        let title = SKLabelNode(text: act == 1 ? "КАРТА ШКОЛЫ" : "ПОДВАЛ")
        title.fontName = "AvenirNext-Heavy"
        title.fontSize = 26
        title.fontColor = Palette.text
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.775)
        title.zPosition = 20
        addChild(title)
        FX.pulse(title, scale: 1.018, duration: 1.8)
        FX.glitchTitle(title)

        let subtitle = SKLabelNode(text: act == 1 ? "АКТ I • ЗДЕСЬ ВСЁ НАЧАЛОСЬ" : "АКТ II • НИЖЕ УЖЕ НЕКУДА")
        subtitle.fontName = "AvenirNext-Medium"
        subtitle.fontSize = 11
        subtitle.fontColor = Palette.textDim
        subtitle.position = CGPoint(x: size.width / 2, y: size.height * 0.735)
        subtitle.zPosition = 20
        addChild(subtitle)

        let rule = SKShapeNode(rectOf: CGSize(width: size.width * 0.72, height: 1))
        rule.position = CGPoint(x: size.width / 2, y: size.height * 0.705)
        rule.fillColor = act == 1 ? Palette.cyan : Palette.blood
        rule.strokeColor = .clear
        rule.alpha = 0.35
        addChild(rule)
    }

    private func buildLevels() {
        levelNodes.removeAll()

        let trials = act == 1
            ? Array(Trial.allCases.filter { $0.rawValue <= 10 })
            : Array(Trial.allCases.filter { $0.rawValue >= 11 })

        let positions: [CGPoint] = [
            CGPoint(x: size.width * 0.17, y: size.height * 0.60),
            CGPoint(x: size.width * 0.39, y: size.height * 0.60),
            CGPoint(x: size.width * 0.61, y: size.height * 0.60),
            CGPoint(x: size.width * 0.83, y: size.height * 0.60),
            CGPoint(x: size.width * 0.17, y: size.height * 0.445),
            CGPoint(x: size.width * 0.39, y: size.height * 0.445),
            CGPoint(x: size.width * 0.61, y: size.height * 0.445),
            CGPoint(x: size.width * 0.83, y: size.height * 0.445),
            CGPoint(x: size.width * 0.28, y: size.height * 0.285),
            CGPoint(x: size.width * 0.50, y: size.height * 0.285),
            CGPoint(x: size.width * 0.72, y: size.height * 0.285)
        ]

        for (index, trial) in trials.enumerated() where index < positions.count {
            let completed = SaveManager.shared.data.completedTrials.contains(trial.rawValue)
            let accent = act == 1 ? Palette.cyan : Palette.blood

            let node = SKShapeNode(rectOf: CGSize(width: size.width * 0.205, height: 67), cornerRadius: 13)
            node.position = positions[index]
            node.name = "level_\(trial.rawValue)"
            node.fillColor = Palette.panel
            node.strokeColor = completed ? Palette.amber : accent
            node.lineWidth = completed ? 2.5 : 1.3
            node.glowWidth = completed ? 7 : 3
            node.zPosition = 5

            let marker = SKShapeNode(circleOfRadius: 5)
            marker.position = CGPoint(x: -size.width * 0.078, y: 22)
            marker.fillColor = completed ? Palette.amber : accent
            marker.strokeColor = .clear
            marker.name = node.name
            node.addChild(marker)

            let number = SKLabelNode(text: String(format: "%02d", trial.rawValue))
            number.fontName = "AvenirNext-Heavy"
            number.fontSize = 23
            number.fontColor = Palette.text
            number.position = CGPoint(x: 0, y: 10)
            number.verticalAlignmentMode = .center
            number.name = node.name
            node.addChild(number)

            let label = SKLabelNode(text: trial.title.uppercased())
            label.fontName = "AvenirNext-Bold"
            label.fontSize = 8.5
            label.fontColor = Palette.textDim
            label.position = CGPoint(x: 0, y: -17)
            label.verticalAlignmentMode = .center
            label.name = node.name
            node.addChild(label)

            if completed {
                let done = SKLabelNode(text: "✓")
                done.fontName = "AvenirNext-Heavy"
                done.fontSize = 13
                done.fontColor = Palette.amber
                done.position = CGPoint(x: size.width * 0.075, y: 20)
                done.name = node.name
                node.addChild(done)
            }

            addChild(node)
            FX.cardGlow(node, color: completed ? Palette.amber : accent, radius: completed ? 7 : 4)
            levelNodes.append(node)
        }

        let progress = SKLabelNode(text: "21 СЕКТОРОВ • ВСЕ ДОСТУПНЫ")
        progress.fontName = "AvenirNext-Medium"
        progress.fontSize = 9
        progress.fontColor = Palette.textFaint
        progress.position = CGPoint(x: size.width / 2, y: size.height * 0.19)
        progress.zPosition = 20
        addChild(progress)
    }

    private func buildBackButton() {
        let back = SKLabelNode(text: "← МЕНЮ")
        back.fontName = "AvenirNext-Bold"
        back.fontSize = 16
        back.fontColor = Palette.text
        back.name = "back"
        back.position = CGPoint(x: 58, y: 34)
        back.zPosition = 30
        addChild(back)

        let switchButton = SKLabelNode(text: act == 1 ? "АКТ II  →" : "←  АКТ I")
        switchButton.fontName = "AvenirNext-Bold"
        switchButton.fontSize = 16
        switchButton.fontColor = act == 1 ? Palette.blood : Palette.cyan
        switchButton.name = "switchAct"
        switchButton.position = CGPoint(x: size.width - 58, y: 34)
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
                let hub = HubScene(size: size, act: act == 1 ? 2 : 1)
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
