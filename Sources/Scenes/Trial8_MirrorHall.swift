import SpriteKit

class ActTwoTrialBase: SKScene {
    let trial: Trial
    private var startTime = Date()
    private var finished = false
    private var targetIndex = 0
    private var candleLit = [Bool]()
    private var clockChanged = false
    private var wordLabel: SKLabelNode?
    private var wordProgress = ""
    private var usedLetters: Set<Int> = []

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

        let title = SKLabelNode(text: "\(String(format: "%02d", trial.displayNumber)). \(trial.title.uppercased())")
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
        bl.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
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
        let box = SKShapeNode(rectOf: CGSize(width: size.width * 0.82, height: 330), cornerRadius: 18)
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
        let box = card("Найди единственное отражение, которое слегка врёт")
        let count = 12
        targetIndex = Int.random(in: 0..<count)

        for i in 0..<count {
            let col = i % 4
            let row = i / 4
            let m = SKShapeNode(rectOf: CGSize(width: size.width * 0.16, height: 58), cornerRadius: 9)
            m.position = CGPoint(x: CGFloat(col) - 1.5 * size.width * 0.205, y: 92 - CGFloat(row) * 68)
            m.fillColor = SKColor(white: 0.08, alpha: 1)
            m.strokeColor = Palette.cyan.withAlphaComponent(0.65)
            m.name = "mirror_\\(i)"

            let line = SKShapeNode()
            let p = CGMutablePath()
            p.move(to: CGPoint(x: -18, y: 17))
            p.addLine(to: CGPoint(x: 0, y: -13))
            p.addLine(to: CGPoint(x: 18, y: 17))
            p.addLine(to: CGPoint(x: 0, y: 0))
            line.path = p
            line.strokeColor = Palette.text
            line.lineWidth = 1.7

            let inner = SKShapeNode()
            let ip = CGMutablePath()
            if i == targetIndex {
                ip.move(to: CGPoint(x: -6, y: -3))
                ip.addLine(to: CGPoint(x: 6, y: 7))
                ip.addLine(to: CGPoint(x: -5, y: 12))
            } else {
                ip.move(to: CGPoint(x: -6, y: 7))
                ip.addLine(to: CGPoint(x: 6, y: -3))
                ip.addLine(to: CGPoint(x: 5, y: 12))
            }
            inner.path = ip
            inner.strokeColor = Palette.textDim
            inner.lineWidth = 1.2

            m.addChild(line)
            m.addChild(inner)
            addChild(m)
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
            candle.name = "candle_\(i)"
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
        let target = "ШКОЛАТРИНАДЦАТЬСКРЫВАЕТСВОЮТАЙНУНАВСЕГДА"
        var letters = Array(target)
        while letters.count < 40 { letters.append(["А","О","Е","И","Т","Р","Н","С"].randomElement()!) }
        letters.shuffle()

        let box = card("Собери мистическое послание • 40 БУКВ")
        usedLetters.removeAll()
        for i in 0..<letters.count {
            let col = i % 5
            let row = i / 5
            let b = SKShapeNode(rectOf: CGSize(width: 48, height: 34), cornerRadius: 7)
            b.position = CGPoint(x: (CGFloat(col) - 2) * 57, y: 80 - CGFloat(row) * 31)
            b.fillColor = SKColor(white: 0.08, alpha: 1)
            b.strokeColor = Palette.magenta
            b.name = "letter_\(i)_\(letters[i])"
            let l = SKLabelNode(text: String(letters[i]))
            l.fontName = "AvenirNext-Heavy"; l.fontSize = 17; l.fontColor = Palette.text
            l.verticalAlignmentMode = .center
            b.addChild(l)
            box.addChild(b)
        }
        let selected = SKLabelNode(text: "Выбрано: ")
        selected.name = "word"; selected.fontName = "AvenirNext-Bold"; selected.fontSize = 13
        selected.fontColor = Palette.cyan; selected.position = CGPoint(x: 0, y: -155)
        box.addChild(selected)
        wordLabel = selected
        wordProgress = ""
    }

    private func buildShadows() {
        let box = card("Найди одну тень, которая отличается")
        targetIndex = Int.random(in: 0..<15)
        for i in 0..<15 {
            let col = i % 5
            let row = i / 5
            let s = SKShapeNode(ellipseOf: CGSize(width: 48, height: 40))
            s.position = CGPoint(x: CGFloat(col - 2) * 58, y: 76 - CGFloat(row) * 58)
            s.fillColor = SKColor(white: 0.01, alpha: 1)
            s.strokeColor = Palette.blood.withAlphaComponent(0.55)
            s.name = "shadow_\(i)"
            if i == targetIndex {
                s.xScale = 1.09
                s.yScale = 0.93
                let notch = SKShapeNode(circleOfRadius: 3)
                notch.position = CGPoint(x: 12, y: 8)
                notch.fillColor = Palette.bgDeep
                notch.strokeColor = .clear
                s.addChild(notch)
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
        let box = card("Продолжи закономерность")
        let q = SKLabelNode(text: "2 • 5 • 10 • 17 • 26 • ?")
        q.fontName = "AvenirNext-Heavy"; q.fontSize = 23; q.fontColor = Palette.text
        q.position = CGPoint(x: 0, y: 65); box.addChild(q)
        let answers = ["31","35","37","39","42","45"]
        for i in 0..<answers.count {
            let b = SKShapeNode(rectOf: CGSize(width: 115, height: 42), cornerRadius: 9)
            b.position = CGPoint(x: (i % 2 == 0 ? -78 : 78), y: 10 - CGFloat(i / 2) * 52)
            b.fillColor = SKColor(white: 0.07, alpha: 1)
            b.strokeColor = Palette.cyan.withAlphaComponent(0.7)
            b.name = "rhyme_\(i)"
            let l = SKLabelNode(text: answers[i]); l.fontName = "AvenirNext-Bold"; l.fontSize = 14
            l.fontColor = Palette.text; l.verticalAlignmentMode = .center
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
                    if parts.count >= 3, let index = Int(parts[1]), let letterNode = wordLabel {
                        guard !usedLetters.contains(index) else { return }
                        let letter = String(parts[2])
                        let target = "ШКОЛАТРИНАДЦАТЬСКРЫВАЕТСВОЮТАЙНУНАВСЕГДА"
                        let next = wordProgress + letter
                        if target.hasPrefix(next) {
                            usedLetters.insert(index)
                            n.alpha = 0.28
                            wordProgress = next
                            letterNode.text = "Выбрано: " + next
                            Audio.shared.tone(freq: 300 + Double(next.count) * 18, duration: 0.09, volume: 0.14)
                            if next == target { complete() }
                        } else {
                            wordProgress = ""
                            usedLetters.removeAll()
                            letterNode.text = "ОШИБКА • начни заново"
                            failPulse(n)
                            self.enumerateChildNodes(withName: "//letter_*") { node, _ in node.alpha = 1.0 }
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
