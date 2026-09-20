import SpriteKit

final class EndingScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = Palette.bgDeep
        Audio.shared.start()

        let ending = max(1, min(4, SaveManager.shared.data.ending ?? 1))
        let titles = [
            1: "ТЫ ОСТАЛСЯ",
            2: "ТЫ УШЁЛ, НО ШКОЛА ПОМНИТ",
            3: "ТЫ ВЫБРАЛ СВОБОДУ",
            4: "ТЫ СТАЛ ЧАСТЬЮ ШКОЛЫ"
        ]
        let texts = [
            1: "Ты подписал тетрадь. За последней партой стало тихо.",
            2: "Ты отказался подписывать. Дверь закрылась сама.",
            3: "Ты ушёл, не оставив имени. Но услышал звонок вслед.",
            4: "Ты остался в коридоре навсегда. Теперь здесь ждут другого."
        ]

        let title = SKLabelNode(text: titles[ending] ?? "КОНЕЦ")
        title.fontName = "AvenirNext-Heavy"
        title.fontSize = 25
        title.fontColor = Palette.blood
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.66)
        title.numberOfLines = 2
        addChild(title)

        let body = SKLabelNode(text: texts[ending] ?? "")
        body.fontName = "AvenirNext-Regular"
        body.fontSize = 15
        body.fontColor = Palette.textDim
        body.position = CGPoint(x: size.width / 2, y: size.height * 0.52)
        body.numberOfLines = 0
        addChild(body)

        let again = SKShapeNode(rectOf: CGSize(width: 190, height: 52), cornerRadius: 12)
        again.position = CGPoint(x: size.width / 2, y: size.height * 0.30)
        again.fillColor = SKColor(white: 0.06, alpha: 1)
        again.strokeColor = Palette.cyan
        again.name = "again"

        let label = SKLabelNode(text: "В МЕНЮ")
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 15
        label.fontColor = Palette.text
        label.verticalAlignmentMode = .center
        again.addChild(label)
        addChild(again)

        Audio.shared.tone(freq: 70, duration: 1.0, volume: 0.18, type: .noise)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        var current: SKNode? = atPoint(point)
        while let node = current {
            if node.name == "again" {
                let menu = MenuScene(size: size)
                menu.scaleMode = scaleMode
                view?.presentScene(menu, transition: .fade(withDuration: 0.5))
                return
            }
            current = node.parent
        }
    }
}
