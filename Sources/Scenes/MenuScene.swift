import SpriteKit

final class MenuScene: SKScene {
    private var title: SKLabelNode!

    override func didMove(to view: SKView) {
        backgroundColor = Palette.bg

        title = SKLabelNode(text: "ШКОЛА №13")
        title.fontName = "AvenirNext-Heavy"
        title.fontSize = min(size.width * 0.14, 64)
        title.fontColor = Palette.cyan
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.72)
        title.verticalAlignmentMode = .center
        addChild(title)

        let sub = SKLabelNode(text: "ПОСЛЕДНИЙ ЗВОНОК")
        sub.fontName = "AvenirNext-Medium"
        sub.fontSize = min(size.width * 0.05, 22)
        sub.fontColor = Palette.textDim
        sub.position = CGPoint(x: size.width / 2, y: size.height * 0.72 - title.fontSize * 0.9)
        sub.verticalAlignmentMode = .center
        addChild(sub)

        let start = NeonButton(title: "НАЧАТЬ", size: CGSize(width: size.width * 0.65, height: 60))
        start.position = CGPoint(x: size.width / 2, y: size.height * 0.38)
        start.name = "startButton"
        addChild(start)

        let reset = NeonButton(title: "СБРОСИТЬ ПРОГРЕСС", size: CGSize(width: size.width * 0.65, height: 44), color: Palette.magenta)
        reset.position = CGPoint(x: size.width / 2, y: size.height * 0.38 - 80)
        reset.name = "resetButton"
        addChild(reset)

        let p = SaveManager.shared.progress
        let prog = SKLabelNode(text: "ПРОЙДЕНО: \(Int(p * 7)) / 7")
        prog.fontName = "AvenirNext-Medium"
        prog.fontSize = 16
        prog.fontColor = Palette.textDim
        prog.position = CGPoint(x: size.width / 2, y: 60)
        prog.verticalAlignmentMode = .center
        addChild(prog)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }

        for node in nodes(at: point) {
            var current: SKNode? = node
            while let candidate = current {
                if candidate.name == "startButton" {
                    goToHub()
                    return
                }
                if candidate.name == "resetButton" {
                    SaveManager.shared.reset()
                    return
                }
                current = candidate.parent
            }
        }
    }

    private func goToHub() {
        guard view != nil else { return }
        let hub = HubScene(size: size)
        hub.scaleMode = scaleMode
        view?.presentScene(hub, transition: .fade(withDuration: 0.35))
    }
}
