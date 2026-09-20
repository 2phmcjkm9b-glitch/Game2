import SpriteKit

final class MenuScene: SKScene {
    private var title: SKLabelNode!

    override func didMove(to view: SKView) {
        backgroundColor = Palette.bg
        FX.dust(in: self, count: 50)
        addChild(VignetteNode(size: size, intensity: 0.85))

        title = SKLabelNode(text: "ШКОЛА №13")
        title.fontName = "AvenirNext-Heavy"
        title.fontSize = min(size.width * 0.14, 64)
        title.fontColor = Palette.cyan
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.72)
        title.verticalAlignmentMode = .center
        addChild(title)
        title.run(.repeatForever(.sequence([
            .fadeAlpha(to: 0.6, duration: 0.08),
            .fadeAlpha(to: 1.0, duration: 0.5),
            .wait(forDuration: Double.random(in: 1.0...3.0))
        ])))

        let sub = SKLabelNode(text: "ПОСЛЕДНИЙ ЗВОНОК")
        sub.fontName = "AvenirNext-Medium"
        sub.fontSize = min(size.width * 0.05, 22)
        sub.fontColor = Palette.textDim
        sub.position = CGPoint(x: size.width / 2, y: size.height * 0.72 - title.fontSize * 0.9)
        addChild(sub)

        let start = NeonButton(title: "НАЧАТЬ", size: CGSize(width: size.width * 0.65, height: 60))
        start.position = CGPoint(x: size.width / 2, y: size.height * 0.38)
        start.action = { [weak self] in self?.goToHub() }
        addChild(start)

        let reset = NeonButton(
            title: "СБРОСИТЬ ПРОГРЕСС",
            size: CGSize(width: size.width * 0.65, height: 44),
            color: Palette.magenta
        )
        reset.position = CGPoint(x: size.width / 2, y: size.height * 0.38 - 80)
        reset.action = { [weak self] in
            guard let self else { return }
            SaveManager.shared.reset()
            FX.flash(on: self, color: Palette.magenta, duration: 0.2)
        }
        addChild(reset)

        let p = SaveManager.shared.progress
        let prog = SKLabelNode(text: "ПРОЙДЕНО: (Int(p * 7)) / 7")
        prog.fontName = "AvenirNext-Medium"
        prog.fontSize = 16
        prog.fontColor = Palette.textDim
        prog.position = CGPoint(x: size.width / 2, y: 60)
        addChild(prog)

        Audio.shared.drone(freq: 48, duration: 3.0, volume: 0.08)
    }

    private func goToHub() {
        let hub = HubScene(size: size)
        hub.scaleMode = scaleMode
        view?.presentScene(hub, transition: .fade(withDuration: 0.5))
    }
}
