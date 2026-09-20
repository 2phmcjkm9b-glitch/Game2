import SpriteKit

class ActTwoTrialBase: SKScene {
    let trial: Trial
    private var startTime = Date()
    private var finished = false
    private var targetIndex = 0
    private var candleLit = [Bool]()
    private var clockChanged = false

    init(size: CGSize, trial: Trial) {
        self.trial = trial
        super.init(size: size)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func didMove(to view: SKView) {
        backgroundColor = Palette.bgDeep
        startTime = Date()
        Audio.shared.start()
        Audio.shared.drone(freq: 38, duration: 2.0, volume: 0.11)

        let title = SKLabelNode(text: "(trial.rawValue). (trial.title.uppercased())")
        title.fontName = "AvenirNext-Heavy"
        title.fontSize = 23
        title.fontColor = Palette.blood
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.82)
        addChild(title)

        let hint = SKLabelNode(text: trial.subtitle)
        hint.fontName = "AvenirNext-Regular"
        hint.fontSize = 14
        hint.fontColor = Palette.textDim
        hint.position = CGPoint(x: size.width / 2, y: size.height * 0.75)
        addChild(hint)

        buildPuzzle()

        let back = SKShapeNode(rectOf: CGSize(width: 120, height: 42), cornerRadius: 10)
        back.position = CGPoint(x: 70, y: 35)
        back.fillColor = SKColor(white: 0.06, alpha: 1)
        back.strokeColor = Palette.textDim
        back.name = "backButton"
        let bl = SKLabelNode(text: "← НАЗАД")
        bl.fontName = "AvenirNext-Bold"
        bl.fontSize = 13
        bl.fontColor = Palette.text
        bl.verticalAlignmentMode = .center
        back.addChild(bl)
        addChild(back)
    }

    private func buildPuzzle() {
        switch trial {
        case .mirrorHall:
            buildMirrorPuzzle()
        case .candles:
            buildCandles()
        case .whispers:
            buildWhispers()
        case .shadows:
            buildShadows()
        case .clock:
            buildClock()
        case .rhyme:
            buildRhyme()
        default:
            buildSimpleFallback()
        }
    }

    private func card(_ title: String) -> SKShapeNode {
        let box = SKShapeNode(rectOf: CGSize(width: size.width * 0.82, height: 300), cornerRadius: 18)
        box.position = CGPoint(x: size.width / 2, y: size.height * 0.48)
        box.fillColor = SKColor(white: 0.045, alpha: 1)
        box.strokeColor = Palette.blood
        box.lineWidth = 2
        let label = SKLabelNode(text: title)
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 15
        label.fontColor = Palette.text
        label.position = CGPoint(x: 0, y: 120)
        box.addChild(label)
        addChild(box)
        return box
    }

    private func buildMirrorPuzzle() {
        let box = card("Найди единственное отражение, которое лжёт")
        targetIndex = Int.random(in: 0..<6)
        for i in 0..<6 {
            let c = i % 3
            let r = i / 3
            let m = SKShapeNode(rectOf: CGSize(width: size.width * 0.20, height: 82), cornerRadius: 10)
            m.position = CGPoint(x: CGFloat(c - 1) * size.width * 0.25, y: r == 0 ? 45 : -45)
            m.fillColor = SKColor(white: 0.08, alpha: 1)
            m.strokeColor = Palette.cyan.withAlphaComponent(0.7)
            m.name = "mirror_(i)"
            let line = SKShapeNode()
            let p = CGMutablePath()
            p.move(to: CGPoint(x: -25, y: 25))
            p.addLine(to: CGPoint(x: 0, y: -18))
            p.addLine(to: CGPoint(x: 25, y: 25))
            if i == targetIndex { p.addLine(to: CGPoint(x: 8, y: 8)) }
            else { p.addLine(to: CGPoint(x: -8, y: 8)) }
            line.path = p
            line.strokeColor = Palette.text
            line.lineWidth = 2
            m.addChild(line)
            box.addChild(m)
        }
    }

    private func buildCandles() {
        let box = card("Погаси все 6 свечей")
        candleLit = Array(repeating: true, count: 6)
        for i in 0..<6 {
            let c = i % 3
            let r = i / 3
            let candle = SKShapeNode(rectOf: CGSize(width: 42, height: 90), cornerRadius: 6)
            candle.position = CGPoint(x: CGFloat(c - 1) * size.width * 0.25, y: r == 0 ? 45 : -45)
            candle.fillColor = Palette.amber.withAlphaComponent(0.8)
            candle.strokeColor = Palette.amber
            candle.name = "candle_(i)"
            let flame = SKShapeNode(circleOfRadius: 11)
            flame.position = CGPoint(x: 0, y: 55)
            flame.fillColor = Palette.blood
            flame.strokeColor = .clear
            flame.name = "flame"
            candle.addChild(flame)
            box.addChild(candle)
        }
        let info = SKLabelNode(text: "Нажимай свечи")
        info.fontName = "AvenirNext-Regular"; info.fontSize = 13; info.fontColor = Palette.textDim
        info.position = CGPoint(x: 0, y: -125); box.addChild(info)
    }

    private func buildWhispers() {
        let box = card("Собери слово: ШКОЛА")
        let letters = ["Ш","К","О","Л","А","Т","М","Р"]
        for i in 0..<letters.count {
            let b = SKShapeNode(rectOf: CGSize(width: 58, height: 58), cornerRadius: 10)
            let c = i % 4
            let r = i / 4
            b.position = CGPoint(x: CGFloat(c - 1.5) * 68, y: r == 0 ? 42 : -42)
            b.fillColor = SKColor(white: 0.08, alpha: 1)
            b.strokeColor = Palette.magenta
            b.name = "letter_(i)_(letters[i])"
            let l = SKLabelNode(text: letters[i]); l.fontName = "AvenirNext-Heavy"; l.fontSize = 22
            l.fontColor = Palette.text; l.verticalAlignmentMode = .center; b.addChild(l)
            box.addChild(b)
        }
        let selected = SKLabelNode(text: "Выбрано: ")
        selected.name = "word"
        selected.fontName = "AvenirNext-Bold"; selected.fontSize = 16; selected.fontColor = Palette.cyan
        selected.position = CGPoint(x: 0, y: -125); box.addChild(selected)
    }

    private func buildShadows() {
        let box = card("Одна тень лишняя")
        targetIndex = Int.random(in: 0..<8)
        for i in 0..<8 {
            let c = i % 4
            let r = i / 4
            let s = SKShapeNode(ellipseOf: CGSize(width: 72, height: 54))
            s.position = CGPoint(x: CGFloat(c - 1.5) * 68, y: r == 0 ? 42 : -42)
            s.fillColor = SKColor(white: 0.01, alpha: 1)
            s.strokeColor = Palette.blood.withAlphaComponent(0.6)
            s.name = "shadow_(i)"
            if i == targetIndex {
                s.xScale = 1.25
                s.yScale = 0.75
            }
            box.addChild(s)
        }
    }

    private func buildClock() {
        let box = card("Запомни время. Через 2 секунды оно изменится.")
        let clock = SKLabelNode(text: "13:13")
        clock.name = "clock"
        clock.fontName = "AvenirNext-Heavy"; clock.fontSize = 48; clock.fontColor = Palette.text
        clock.position = CGPoint(x: 0, y: 20); box.addChild(clock)
        run(.sequence([
            .wait(forDuration: 2.0),
            .run { [weak self, weak clock] in
                guard let self, let clock else { return }
                self.clockChanged = true
                clock.text = "13:18"
                Audio.shared.tone(freq: 520, duration: 0.15, volume: 0.18)
            }
        ]))
        let button = SKShapeNode(rectOf: CGSize(width: 180, height: 50), cornerRadius: 10)
        button.position = CGPoint(x: 0, y: -65); button.fillColor = SKColor(white: 0.08, alpha: 1)
        button.strokeColor = Palette.cyan; button.name = "clockButton"
        let l = SKLabelNode(text: "ИЗМЕНИЛОСЬ"); l.fontName = "AvenirNext-Bold"; l.fontSize = 14; l.fontColor = Palette.cyan; l.verticalAlignmentMode = .center
        button.addChild(l); box.addChild(button)
    }

    private func buildRhyme() {
        let box = card("Продолжи считалку")
        let q = SKLabelNode(text: "Раз, два, три — ...")
        q.fontName = "AvenirNext-Heavy"; q.fontSize = 24; q.fontColor = Palette.text
        q.position = CGPoint(x: 0, y: 65); box.addChild(q)
        let answers = ["смотри","четыре","замри","иди"]
        for i in 0..<4 {
            let b = SKShapeNode(rectOf: CGSize(width: 145, height: 48), cornerRadius: 9)
            b.position = CGPoint(x: i % 2 == 0 ? -82 : 82, y: i < 2 ? 5 : -55)
            b.fillColor = SKColor(white: 0.07, alpha: 1)
            b.strokeColor = Palette.cyan.withAlphaComponent(0.7)
            b.name = "rhyme_(i)"
            let l = SKLabelNode(text: answers[i]); l.fontName = "AvenirNext-Bold"; l.fontSize = 14; l.fontColor = Palette.text; l.verticalAlignmentMode = .center
            b.addChild(l); box.addChild(b)
        }
        targetIndex = 2
    }

    private func buildSimpleFallback() {
        let box = card(trial.subtitle)
        let action = SKLabelNode(text: "ВЫПОЛНИТЬ")
        action.fontName = "AvenirNext-Bold"; action.fontSize = 18; action.fontColor = Palette.cyan
        action.name = "action"; action.position = CGPoint.zero; box.addChild(action)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let p = touches.first?.location(in: self) else { return }
        var c: SKNode? = atPoint(p)
        while let n = c {
            if n.name == "backButton" { back(); return }

            if let name = n.name {
                if name.hasPrefix("mirror_"), let i = Int(name.dropFirst(7)) {
                    if i == targetIndex { complete() } else { failPulse(n) }
                    return
                }
                if name.hasPrefix("candle_"), let i = Int(name.dropFirst(7)) {
                    candleLit[i].toggle()
                    if let candle = n as? SKShapeNode {
                        candle.alpha = candleLit[i] ? 1 : 0.3
                        candle.childNode(withName: "flame")?.isHidden = !candleLit[i]
                    }
                    Audio.shared.tone(freq: candleLit[i] ? 280 : 180, duration: 0.10, volume: 0.15)
                    if candleLit.allSatisfy({ !$0 }) { complete() }
                    return
                }
                if name.hasPrefix("letter_") {
                    let parts = name.split(separator: "_")
                    if parts.count >= 3, let letterNode = childNode(withName: "word") as? SKLabelNode {
                        let letter = String(parts[2])
                        let current = letterNode.text?.replacingOccurrences(of: "Выбрано: ", with: "") ?? ""
                        if current.count < 5 {
                            let next = current + letter
                            letterNode.text = "Выбрано: " + next
                            Audio.shared.tone(freq: 300 + Double(next.count) * 70, duration: 0.09, volume: 0.14)
                            if next == "ШКОЛА" { complete() }
                            else if next.count == 5 { letterNode.text = "Выбрано: " }
                        }
                    }
                    return
                }
                if name.hasPrefix("shadow_"), let i = Int(name.dropFirst(7)) {
                    if i == targetIndex { complete() } else { failPulse(n) }
                    return
                }
                if name == "clockButton" {
                    if clockChanged { complete() } else { failPulse(n) }
                    return
                }
                if name.hasPrefix("rhyme_"), let i = Int(name.dropFirst(6)) {
                    if i == targetIndex { complete() } else { failPulse(n) }
                    return
                }
                if name == "action" || name == "task" { complete(); return }
            }
            c = n.parent
        }
    }

    private func failPulse(_ node: SKNode) {
        Haptics.error()
        Audio.shared.tone(freq: 95, duration: 0.12, volume: 0.16)
        node.run(.sequence([.scale(to: 0.92, duration: 0.06), .scale(to: 1.0, duration: 0.06)]))
    }

    private func complete() {
        guard !finished else { return }
        finished = true
        Audio.shared.tone(freq: 660, duration: 0.18, volume: 0.2)
        FX.flash(on: self, color: Palette.cyan, duration: 0.2)
        GameFlow.completeAndReturn(self, trial: trial, time: Date().timeIntervalSince(startTime), delay: 0.9)
    }

    private func back() {
        let h = HubScene(size: size, act: 2)
        h.scaleMode = scaleMode
        view?.presentScene(h, transition: .fade(withDuration: 0.25))
    }
}

final class Trial8_MirrorHall: ActTwoTrialBase {
    init(size: CGSize) { super.init(size: size, trial: .mirrorHall) }
    required init?(coder: NSCoder) { fatalError() }
}
