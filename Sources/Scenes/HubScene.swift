import SpriteKit

final class HubScene: SKScene {
    private let rooms: [(CGFloat, CGFloat, Trial)] = [
        (0.20, 0.75, .mirror),
        (0.50, 0.75, .melody),
        (0.80, 0.75, .darkCorridor),
        (0.20, 0.50, .doors),
        (0.50, 0.50, .dontLookAway),
        (0.80, 0.50, .notes),
        (0.50, 0.22, .finalChoice)
    ]

    override func didMove(to view: SKView) {
        backgroundColor = Palette.bg
        FX.dust(in: self, count: 30)
        addChild(VignetteNode(size: size, intensity: 0.8))

        let header = SKLabelNode(text: "КАРТА ШКОЛЫ")
        header.fontName = "AvenirNext-Bold"
        header.fontSize = 26
        header.fontColor = Palette.text
        header.position = CGPoint(x: size.width / 2, y: size.height * 0.92)
        addChild(header)

        for (rx, ry, trial) in rooms {
            let pos = CGPoint(x: size.width * rx, y: size.height * ry)
            let done = SaveManager.shared.data.completedTrials.contains(trial.rawValue)
            let locked = isLocked(trial)

            let door = makeDoor(trial: trial, done: done, locked: locked)
            door.position = pos
            door.name = "trial_\\(trial.rawValue)"
            addChild(door)
        }

        let back = NeonButton(title: "←", size: CGSize(width: 56, height: 44), color: Palette.textDim)
        back.position = CGPoint(x: 46, y: size.height - 44)
        back.action = { [weak self] in
            guard let self else { return }
            let menu = MenuScene(size: self.size)
            menu.scaleMode = self.scaleMode
            self.view?.presentScene(menu, transition: .fade(withDuration: 0.4))
        }
        addChild(back)

        Audio.shared.drone(freq: 52, duration: 2.5, volume: 0.07)
    }

    private func isLocked(_ trial: Trial) -> Bool {
        for i in 1..<trial.rawValue {
            if !SaveManager.shared.data.completedTrials.contains(i) {
                return true
            }
        }
        return false
    }

    private func makeDoor(trial: Trial, done: Bool, locked: Bool) -> SKNode {
        let node = SKNode()

        let w = size.width * 0.26
        let h = size.height * 0.14

        let rect = SKShapeNode(rectOf: CGSize(width: w, height: h), cornerRadius: 12)
        rect.fillColor = SKColor(white: 0.05, alpha: 0.95)
        rect.strokeColor = locked
            ? SKColor(white: 0.25, alpha: 1)
            : (done ? Palette.amber : Palette.cyan)
        rect.lineWidth = 2
        rect.glowWidth = locked ? 0 : (done ? 4 : 8)
        node.addChild(rect)

        let num = SKLabelNode(text: "\\(trial.rawValue)")
        num.fontName = "AvenirNext-Heavy"
        num.fontSize = 22
        num.fontColor = locked ? Palette.textDim : Palette.text
        num.position = CGPoint(x: -w / 2 + 22, y: 0)
        num.verticalAlignmentMode = .center
        node.addChild(num)

        let name = SKLabelNode(text: trial.title)
        name.fontName = "AvenirNext-Bold"
        name.fontSize = 14
        name.fontColor = locked ? Palette.textDim : Palette.text
        name.position = CGPoint(x: 12, y: 8)
        name.verticalAlignmentMode = .center
        node.addChild(name)

        let sub = SKLabelNode(
            text: locked ? "закрыто" : (done ? "✓ пройдено" : trial.subtitle)
        )
        sub.fontName = "AvenirNext-Regular"
        sub.fontSize = 11
        sub.fontColor = locked ? Palette.textDim : (done ? Palette.amber : Palette.textDim)
        sub.position = CGPoint(x: 12, y: -10)
        sub.verticalAlignmentMode = .center
        node.addChild(sub)

        if !locked {
            rect.run(.repeatForever(.sequence([
                .fadeAlpha(to: 0.75, duration: 1.4),
                .fadeAlpha(to: 1.0, duration: 1.4)
            ])))
        }

        return node
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }

        // Ищем комнату среди всех узлов в точке, включая вложенные labels/shape nodes.
        for node in nodes(at: point) {
            var current: SKNode? = node
            while let candidate = current {
                if let name = candidate.name,
                   name.hasPrefix("trial_"),
                   let raw = Int(name.replacingOccurrences(of: "trial_", with: "")),
                   let trial = Trial(rawValue: raw) {
                    guard !isLocked(trial) else {
                        Haptics.error()
                        Audio.shared.tone(freq: 120, duration: 0.15, volume: 0.2, type: .square)
                        return
                    }
                    launch(trial)
                    return
                }
                current = candidate.parent
            }
        }
    }

    private func launch(_ trial: Trial) {
        Haptics.medium()
        Audio.shared.tone(freq: 880, duration: 0.1, volume: 0.2)

        let scene: SKScene
        switch trial {
        case .mirror:       scene = Trial1_Mirror(size: size)
        case .melody:       scene = Trial2_Melody(size: size)
        case .darkCorridor: scene = Trial3_DarkCorridor(size: size)
        case .doors:        scene = Trial4_Doors(size: size)
        case .dontLookAway: scene = Trial5_DontLookAway(size: size)
        case .notes:        scene = Trial6_Notes(size: size)
        case .finalChoice:  scene = Trial7_FinalChoice(size: size)
        }

        scene.scaleMode = scaleMode
        view?.presentScene(scene, transition: .doorsOpenHorizontal(withDuration: 0.6))
    }
}
