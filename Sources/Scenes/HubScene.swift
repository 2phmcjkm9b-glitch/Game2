import SpriteKit

final class HubScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = Palette.bg
        isUserInteractionEnabled = true

        let title = SKLabelNode(text: "ИСПЫТАНИЯ")
        title.fontName = "AvenirNext-Bold"
        title.fontSize = 30
        title.fontColor = Palette.text
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.86)
        addChild(title)

        for trial in Trial.allCases {
            let button = NeonButton(
                title: "\(trial.rawValue). \(trial.title)",
                size: CGSize(width: min(size.width - 48, 330), height: 48),
                color: trial.rawValue == 7 ? Palette.magenta : Palette.cyan
            )

            button.position = CGPoint(
                x: size.width / 2,
                y: size.height * 0.75 - CGFloat(trial.rawValue - 1) * 58
            )

            // Все 7 испытаний доступны для тестирования.
            button.setEnabled(true)

            button.action = { [weak self, weak button] in
                guard let self, let button, button.isEnabled else { return }
                self.open(trial)
            }

            addChild(button)
        }

        addChild(FX.vignette(size: size))
    }

    private func open(_ trial: Trial) {
        guard let skView = view else { return }

        let scene: SKScene
        switch trial {
        case .mirror:
            scene = Trial1_Mirror(size: skView.bounds.size)
        case .melody:
            scene = Trial2_Melody(size: skView.bounds.size)
        case .darkCorridor:
            scene = Trial3_DarkCorridor(size: skView.bounds.size)
        case .doors:
            scene = Trial4_Doors(size: skView.bounds.size)
        case .dontLookAway:
            scene = Trial5_DontLookAway(size: skView.bounds.size)
        case .notes:
            scene = Trial6_Notes(size: skView.bounds.size)
        case .finalChoice:
            scene = Trial7_FinalChoice(size: skView.bounds.size)
        }

        scene.scaleMode = .resizeFill
        Haptics.medium()
        skView.presentScene(scene, transition: .fade(withDuration: 0.35))
    }
}
