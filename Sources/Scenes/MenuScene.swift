import SpriteKit

final class MenuScene: SKScene {
    override func didMove(to view: SKView) {
        removeAllChildren()
        backgroundColor = Palette.bgDeep
        FX.atmosphere(in: self, accent: Palette.magenta)
        FX.scanline(in: self, color: Palette.magenta)

        let top = SKLabelNode(text: "АРХИВ • 13")
        top.fontName = "AvenirNext-Bold"
        top.fontSize = 12
        top.fontColor = Palette.textDim
        top.position = CGPoint(x: size.width / 2, y: size.height * 0.84)
        top.zPosition = 20
        addChild(top)

        let title = SKLabelNode(text: "ШКОЛА №13")
        title.fontName = "AvenirNext-Heavy"
        title.fontSize = 46
        title.fontColor = Palette.text
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.68)
        title.zPosition = 20
        addChild(title)
        FX.pulse(title, scale: 1.018, duration: 2.0)
        FX.glitchTitle(title)

        let line = SKShapeNode(rectOf: CGSize(width: 155, height: 1))
        line.position = CGPoint(x: size.width / 2, y: size.height * 0.635)
        line.fillColor = Palette.magenta
        line.strokeColor = .clear
        line.alpha = 0.8
        addChild(line)

        let subtitle = SKLabelNode(text: "НЕ ВСЕ ДВЕРИ ВЕДУТ НАРУЖУ")
        subtitle.fontName = "AvenirNext-Medium"
        subtitle.fontSize = 13
        subtitle.fontColor = Palette.textDim
        subtitle.position = CGPoint(x: size.width / 2, y: size.height * 0.59)
        subtitle.zPosition = 20
        addChild(subtitle)

        let panel = SKShapeNode(rectOf: CGSize(width: 230, height: 82), cornerRadius: 18)
        panel.position = CGPoint(x: size.width / 2, y: size.height * 0.43)
        panel.fillColor = Palette.panel
        panel.strokeColor = Palette.magenta
        panel.lineWidth = 1.5
        panel.glowWidth = 9
        panel.name = "startButton"
        panel.zPosition = 10
        addChild(panel)

        let start = SKLabelNode(text: "НАЧАТЬ")
        start.fontName = "AvenirNext-Heavy"
        start.fontSize = 25
        start.fontColor = Palette.text
        start.verticalAlignmentMode = .center
        start.name = "startButton"
        panel.addChild(start)

        let hint = SKLabelNode(text: "ВХОД В ШКОЛУ")
        hint.fontName = "AvenirNext-Medium"
        hint.fontSize = 9
        hint.fontColor = Palette.magenta
        hint.position = CGPoint(x: 0, y: -27)
        hint.name = "startButton"
        panel.addChild(hint)

        FX.pulse(panel, scale: 1.025, duration: 1.5)

        let footer = SKLabelNode(text: "СИСТЕМА НАБЛЮДЕНИЯ • OFFLINE")
        footer.fontName = "AvenirNext-Medium"
        footer.fontSize = 9
        footer.fontColor = Palette.textFaint
        footer.position = CGPoint(x: size.width / 2, y: 28)
        addChild(footer)

        addChild(FX.vignette(size: size, intensity: 0.72))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        let hit = nodes(at: point).contains { node in
            var current: SKNode? = node
            while let candidate = current {
                if candidate.name == "startButton" { return true }
                current = candidate.parent
            }
            return false
        }
        if hit {
            let hub = HubScene(size: size, act: 1)
            hub.scaleMode = scaleMode
            view?.presentScene(hub, transition: .fade(withDuration: 0.3))
        }
    }
}
