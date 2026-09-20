import SpriteKit

final class HundredTrialScene: SKScene {
    private let level: Level
    private let mainTrial: Trial?

    private var target = 0
    private var sequence: [Int] = []
    private var input: [Int] = []
    private var cells: [SKShapeNode] = []
    private var started = false
    private var solved = false
    private var selectedMatch: Int?
    private var lights: [Bool] = []
    private var choiceRule = ""

    init(size: CGSize, level: Level, mainTrial: Trial? = nil) {
        self.level = level
        self.mainTrial = mainTrial
        super.init(size: size)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func didMove(to view: SKView) {
        backgroundColor = Palette.bgDeep
        Audio.shared.start()
        Audio.shared.drone(freq: 34, duration: 2.0, volume: 0.10)

        let title = SKLabelNode(text: "\(String(format: "%02d", level.id)). \(level.title.uppercased())")
        title.fontName = "AvenirNext-Heavy"
        title.fontSize = 21
        title.fontColor = Palette.blood
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.84)
        addChild(title)

        let info = SKLabelNode(text: level.hint ?? typeHint())
        info.fontName = "AvenirNext-Regular"
        info.fontSize = 13
        info.fontColor = Palette.textDim
        info.position = CGPoint(x: size.width / 2, y: size.height * 0.77)
        addChild(info)

        let status = SKLabelNode(text: "ИСПЫТАНИЕ \(level.difficulty)/10")
        status.name = "status"
        status.fontName = "AvenirNext-Bold"
        status.fontSize = 13
        status.fontColor = Palette.cyan
        status.position = CGPoint(x: size.width / 2, y: size.height * 0.70)
        addChild(status)

        buildGame()
        addBackButton()
        addChild(FX.vignette(size: size, intensity: 0.68))
    }

    private func typeHint() -> String {
        switch level.type {
        case .findOdd: return "Найди единственный изменённый символ"
        case .lightsOut: return "Погаси все огни: тап меняет соседей"
        case .sequence: return "Запомни последовательность"
        case .memoryGrid: return "Запомни клетки и повтори без ошибок"
        case .mirrorMatch: return "Открой две одинаковые карты"
        case .shadows: return "Найди тень, которая отличается"
        case .wordChain: return "Собери слово по порядку"
        case .choice: return "Реши правило и выбери дверь"
        case .reversedInput: return "Повтори последовательность наоборот"
        case .countTrap: return "Посчитай объекты"
        }
    }

    private func setStatus(_ text: String) {
        (childNode(withName: "//status") as? SKLabelNode)?.text = text
    }

    private func addBackButton() {
        let back = SKShapeNode(rectOf: CGSize(width: 120, height: 42), cornerRadius: 10)
        back.position = CGPoint(x: 70, y: 35)
        back.fillColor = Palette.panel
        back.strokeColor = Palette.textDim
        back.lineWidth = 1.5
        back.name = "backButton"
        back.zPosition = 100

        let label = SKLabelNode(text: "← НАЗАД")
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 13
        label.fontColor = Palette.text
        label.verticalAlignmentMode = .center
        label.name = "backButton"
        back.addChild(label)
        addChild(back)
    }

    private func buildGame() {
        switch level.type {
        case .findOdd:
            buildFindOdd()
        case .lightsOut:
            buildLightsOut()
        case .sequence:
            buildSequence(reverse: false)
        case .memoryGrid:
            buildMemory()
        case .mirrorMatch:
            buildMirrorMatch()
        case .shadows:
            buildShadows()
        case .wordChain:
            buildWord()
        case .choice:
            buildChoice()
        case .reversedInput:
            buildSequence(reverse: true)
        case .countTrap:
            buildCount()
        }
    }

    private func makeCell(_ text: String, _ name: String, _ x: CGFloat, _ y: CGFloat, width: CGFloat = 62, height: CGFloat = 52) -> SKShapeNode {
        let b = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 10)
        b.position = CGPoint(x: x, y: y)
        b.fillColor = Palette.panel
        b.strokeColor = Palette.cyanSoft
        b.lineWidth = 1.5
        b.name = name
        b.zPosition = 10

        let l = SKLabelNode(text: text)
        l.fontName = "AvenirNext-Bold"
        l.fontSize = min(18, height * 0.42)
        l.fontColor = Palette.text
        l.verticalAlignmentMode = .center
        l.name = name
        b.addChild(l)
        addChild(b)
        return b
    }

    private func buildFindOdd() {
        let cols = min(8, max(3, Int(level.params["cols"] ?? 4)))
        let rows = min(7, max(3, Int(level.params["rows"] ?? 4)))
        let count = cols * rows
        target = Int.random(in: 0..<count)

        let symbols = ["◆", "◇", "◆", "◆", "●", "○", "■", "□"]
        let base = symbols[(level.id + level.difficulty) % symbols.count]
        let odd = base == "◆" ? "◇" : (base == "●" ? "○" : "□")

        let sx = CGFloat(cols - 1) * 34
        let sy = CGFloat(rows - 1) * 27
        for i in 0..<count {
            let c = i % cols
            let r = i / cols
            let x = size.width / 2 + CGFloat(c) * 68 - sx
            let y = size.height * 0.48 + CGFloat(rows - 1 - r) * 54 - sy
            _ = makeCell(i == target ? odd : base, "g_\(i)", x, y)
        }
        setStatus("НАЙДИ ОТЛИЧИЕ")
    }

    private func buildLightsOut() {
        let cols = min(6, max(3, Int(level.params["cols"] ?? 3)))
        let rows = min(6, max(3, Int(level.params["rows"] ?? 3)))
        let count = cols * rows

        lights = Array(repeating: false, count: count)
        // Start from the solved state and apply random legal moves.
        // This guarantees every generated board has a solution.
        let moves = max(5, level.difficulty + 4)
        for _ in 0..<moves {
            toggleLight(Int.random(in: 0..<count), cols: cols, rows: rows, animate: false)
        }

        for i in 0..<count {
            let c = i % cols
            let r = i / cols
            let x = size.width / 2 + CGFloat(c - (cols - 1) / 2) * 62
            let y = size.height * 0.48 + CGFloat((rows - 1) / 2 - r) * 58
            let b = makeCell(lights[i] ? "●" : "○", "l_\(i)", x, y)
            b.strokeColor = lights[i] ? Palette.candle : Palette.cyanSoft
        }
        setStatus("ПОГАСИ ВСЕ ОГНИ")
    }

    private func toggleLight(_ index: Int, cols: Int, rows: Int, animate: Bool) {
        guard index >= 0, index < lights.count else { return }
        let c = index % cols
        let r = index / cols
        let neighbors = [(c, r), (c - 1, r), (c + 1, r), (c, r - 1), (c, r + 1)]

        for (nc, nr) in neighbors where nc >= 0 && nc < cols && nr >= 0 && nr < rows {
            let i = nr * cols + nc
            lights[i].toggle()
            if animate, let b = childNode(withName: "//l_\(i)") as? SKShapeNode {
                b.run(.sequence([.scale(to: 1.10, duration: 0.06), .scale(to: 1.0, duration: 0.06)]))
            }
        }

        for i in 0..<lights.count {
            if let b = childNode(withName: "//l_\(i)") as? SKShapeNode {
                b.children.compactMap { $0 as? SKLabelNode }.first?.text = lights[i] ? "●" : "○"
                b.strokeColor = lights[i] ? Palette.candle : Palette.cyanSoft
            }
        }
    }

    private func buildSequence(reverse: Bool) {
        let len = min(10, max(3, Int(level.params["len"] ?? Double(3 + level.difficulty / 2))))
        sequence = (0..<len).map { _ in Int.random(in: 0..<4) }
        let displayedSequence = sequence

        let symbols = ["◆", "●", "▲", "■"]
        for i in 0..<4 {
            let x = size.width / 2 + (CGFloat(i) - 1.5) * 78
            _ = makeCell(symbols[i], "s_\(i)", x, size.height * 0.45, width: 70, height: 58)
        }

        setStatus(reverse ? "СМОТРИ — ПОТОМ НАОБОРОТ" : "СМОТРИ...")
        var actions: [SKAction] = []
        for (i, value) in displayedSequence.enumerated() {
            actions.append(.wait(forDuration: 0.18))
            actions.append(.run { [weak self] in
                guard let self else { return }
                if let n = self.childNode(withName: "//s_\(value)") as? SKShapeNode {
                    n.run(.sequence([
                        .scale(to: 1.16, duration: 0.10),
                        .wait(forDuration: 0.18),
                        .scale(to: 1.0, duration: 0.10)
                    ]))
                }
                Audio.shared.tone(freq: 180 + Double(value) * 70, duration: 0.12, volume: 0.16)
                if i == self.sequence.count - 1 {
                    self.started = true
                    self.setStatus("ПОВТОРИ • 0/\(self.sequence.count)")
                }
            })
        }
        run(.sequence(actions))
    }

    private func buildMemory() {
        let cols = 4
        let rows = 4
        let count = cols * rows
        let amount = min(12, max(3, Int(level.params["cells"] ?? Double(3 + level.difficulty / 2))))
        sequence = Array((0..<count).shuffled().prefix(amount))

        for i in 0..<count {
            let c = i % cols
            let r = i / cols
            let x = size.width / 2 + (CGFloat(c) - 1.5) * 68
            let y = size.height * 0.48 + CGFloat(1 - r) * 62
            _ = makeCell(sequence.contains(i) ? "●" : "·", "m_\(i)", x, y)
        }

        setStatus("ЗАПОМНИ")
        let showTime = max(0.7, 1.5 - Double(level.difficulty) * 0.06)
        run(.sequence([
            .wait(forDuration: showTime),
            .run { [weak self] in
                guard let self else { return }
                self.started = true
                for i in 0..<count {
                    if let b = self.childNode(withName: "//m_\(i)") as? SKShapeNode {
                        b.children.compactMap { $0 as? SKLabelNode }.first?.text = "?"
                    }
                }
                self.setStatus("ПОВТОРИ • 0/\(self.sequence.count)")
            }
        ]))
    }

    private func buildMirrorMatch() {
        let pairs = min(8, max(2, Int(level.params["pairs"] ?? 4)))
        var values: [Int] = []
        for i in 0..<pairs {
            values.append(i)
            values.append(i)
        }
        values.shuffle()

        let symbols = ["◆", "●", "▲", "■", "✦", "✚", "◇", "○"]
        for i in 0..<values.count {
            let c = i % 4
            let r = i / 4
            let x = size.width / 2 + (CGFloat(c) - 1.5) * 76
            let y = size.height * 0.53 - CGFloat(r) * 62
            let b = makeCell("?", "p_\(i)", x, y, width: 68, height: 54)
            b.userData = NSMutableDictionary()
            b.userData?["value"] = values[i]
            b.userData?["open"] = false
            b.userData?["matched"] = false
            _ = symbols
        }
        setStatus("НАЙДИ ОДИНАКОВЫЕ ПАРЫ")
    }

    private func buildShadows() {
        let count = min(10, max(5, Int(level.params["items"] ?? 5)))
        target = Int.random(in: 0..<count)
        let shadows = ["◐", "◑", "◒", "◓"]
        let oddIndex = (level.id + 1) % shadows.count

        for i in 0..<count {
            let col = i % 5
            let row = i / 5
            let x = size.width / 2 + (CGFloat(col) - 2) * 62
            let y = size.height * 0.50 - CGFloat(row) * 70
            let symbol = i == target ? shadows[oddIndex] : shadows[(oddIndex + 2) % shadows.count]
            _ = makeCell(symbol, "shadow_\(i)", x, y, width: 54, height: 54)
        }
        setStatus("ОДНА ТЕНЬ ЛЖЁТ")
    }

    private func buildWord() {
        let words = ["ШКОЛА", "ТЕНЬ", "ЭХО", "ЗЕРКАЛО", "ПОДВАЛ", "МЕЛОДИЯ", "ПАМЯТЬ", "ТИШИНА"]
        let word = Array(words[(level.id - 1) % words.count])
        sequence = Array(0..<word.count)
        let order = sequence.shuffled()

        for (slot, originalIndex) in order.enumerated() {
            let x = size.width / 2 + (CGFloat(slot) - CGFloat(word.count - 1) / 2) * 58
            let b = makeCell(String(word[originalIndex]), "w_\(originalIndex)", x, size.height * 0.45, width: 52, height: 54)
            b.userData = NSMutableDictionary()
            b.userData?["index"] = originalIndex
        }
        setStatus("СОБЕРИ: \(word.count) БУКВ")
    }

    private func buildChoice() {
        let count = min(5, max(3, Int(level.params["options"] ?? 3)))
        let base = max(3, level.id + level.difficulty)
        var candidates: [Int]
        if level.id % 2 == 0 {
            // Exactly one even number; all other doors are odd.
            let evenValue = base % 2 == 0 ? base : base + 1
            candidates = [evenValue]
            var value = evenValue + 1
            while candidates.count < count {
                if value % 2 != 0 {
                    candidates.append(value)
                }
                value += 1
            }
            candidates.shuffle()
            target = candidates.firstIndex(of: evenValue) ?? 0
            choiceRule = "Выбери единственное чётное число"
        } else {
            // Exactly one prime number; the remaining numbers are guaranteed composite.
            let prime = nextPrime(after: base + 10)
            candidates = [prime]
            var value = prime * 2
            while candidates.count < count {
                if !isPrime(value) {
                    candidates.append(value)
                }
                value += 1
            }
            candidates.shuffle()
            target = candidates.firstIndex(of: prime) ?? 0
            choiceRule = "Выбери единственное простое число"
        }

        for i in 0..<count {
            let y = size.height * 0.54 - CGFloat(i) * 58
            let b = makeCell("ДВЕРЬ • \(candidates[i])", "c_\(i)", size.width / 2, y, width: 180, height: 48)
            b.strokeColor = Palette.textDim
        }
        setStatus(choiceRule)
    }

    private func nextPrime(after value: Int) -> Int {
        var n = max(2, value)
        while !isPrime(n) { n += 1 }
        return n
    }

    private func isPrime(_ n: Int) -> Bool {
        guard n >= 2 else { return false }
        if n == 2 { return true }
        if n % 2 == 0 { return false }
        var d = 3
        while d * d <= n {
            if n % d == 0 { return false }
            d += 2
        }
        return true
    }

    private func buildCount() {
        let amount = min(18, max(4, Int(level.params["objects"] ?? 6)))
        target = amount

        for i in 0..<amount {
            let angle = Double(i) * Double.pi * 2 / Double(amount)
            let x = size.width / 2 + CGFloat(cos(angle)) * 95
            let y = size.height * 0.47 + CGFloat(sin(angle)) * 95
            let b = SKShapeNode(circleOfRadius: 10)
            b.position = CGPoint(x: x, y: y)
            b.fillColor = Palette.candle
            b.strokeColor = Palette.amber
            b.zPosition = 10
            addChild(b)
        }

        setStatus("СКОЛЬКО ОГНЕЙ?")
        let start = amount - 2
        for i in 0..<4 {
            _ = makeCell("\(start + i)", "n_\(start + i)", size.width / 2 + (CGFloat(i) - 1.5) * 68, size.height * 0.25)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }

        var node: SKNode? = atPoint(point)
        while let current = node {
            if current.name == "backButton" {
                backToMap()
                return
            }

            guard let name = current.name else {
                node = current.parent
                continue
            }

            if name.hasPrefix("g_"), let i = Int(name.dropFirst(2)) {
                solve(i == target)
                return
            }

            if name.hasPrefix("l_"), let i = Int(name.dropFirst(2)) {
                let cols = min(6, max(3, Int(level.params["cols"] ?? 3)))
                let rows = min(6, max(3, Int(level.params["rows"] ?? 3)))
                toggleLight(i, cols: cols, rows: rows, animate: true)
                if lights.allSatisfy({ !$0 }) {
                    solve(true)
                }
                return
            }

            if name.hasPrefix("s_"), let i = Int(name.dropFirst(2)), started {
                input.append(i)
                setStatus("ПОВТОРИ • \(input.count)/\(sequence.count)")
                checkSequence()
                return
            }

            if name.hasPrefix("m_"), let i = Int(name.dropFirst(2)), started {
                if input.contains(i) {
                    fail()
                    return
                }
                input.append(i)
                checkMemory()
                return
            }

            if name.hasPrefix("p_"), let i = Int(name.dropFirst(2)) {
                handlePairTap(i)
                return
            }

            if name.hasPrefix("shadow_"), let i = Int(name.dropFirst(7)) {
                solve(i == target)
                return
            }

            if name.hasPrefix("w_"), let i = Int(name.dropFirst(2)) {
                guard input.count < sequence.count else { return }
                if i != sequence[input.count] {
                    fail()
                } else {
                    input.append(i)
                    setStatus("СЛОВО • \(input.count)/\(sequence.count)")
                    if input.count == sequence.count {
                        solve(true)
                    }
                }
                return
            }

            if name.hasPrefix("c_"), let i = Int(name.dropFirst(2)) {
                solve(i == target)
                return
            }

            if name.hasPrefix("n_"), let i = Int(name.dropFirst(2)) {
                solve(i == target)
                return
            }

            node = current.parent
        }
    }

    private func checkSequence() {
        guard input.count <= sequence.count else {
            fail()
            return
        }
        for i in input.indices where input[i] != sequence[i] {
            fail()
            return
        }
        if input.count == sequence.count {
            solve(true)
        }
    }

    private func checkMemory() {
        for value in input where !sequence.contains(value) {
            fail()
            return
        }
        if input.count == sequence.count {
            solve(Set(input) == Set(sequence))
        } else {
            setStatus("ПОВТОРИ • \(input.count)/\(sequence.count)")
        }
    }

    private func handlePairTap(_ index: Int) {
        guard let card = childNode(withName: "//p_\(index)") as? SKShapeNode else { return }
        guard let data = card.userData,
              let value = data["value"] as? Int,
              let open = data["open"] as? Bool,
              let matched = data["matched"] as? Bool,
              !open, !matched else { return }

        data["open"] = true
        reveal(card, value: value)

        if let first = selectedMatch {
            guard let firstCard = childNode(withName: "//p_\(first)") as? SKShapeNode,
                  let firstValue = firstCard.userData?["value"] as? Int else {
                selectedMatch = nil
                return
            }

            if firstValue == value {
                firstCard.userData?["matched"] = true
                card.userData?["matched"] = true
                firstCard.strokeColor = Palette.amber
                card.strokeColor = Palette.amber
                selectedMatch = nil
                if allPairsMatched() {
                    solve(true)
                } else {
                    setStatus("ПАРА НАЙДЕНА")
                }
            } else {
                selectedMatch = nil
                setStatus("НЕ ПАРА")
                run(.sequence([
                    .wait(forDuration: 0.45),
                    .run { [weak self, weak firstCard, weak card] in
                        guard let self, let firstCard, let card else { return }
                        firstCard.userData?["open"] = false
                        card.userData?["open"] = false
                        self.hide(firstCard)
                        self.hide(card)
                    }
                ]))
            }
        } else {
            selectedMatch = index
            setStatus("ВЫБЕРИ ВТОРУЮ КАРТУ")
        }
    }

    private func reveal(_ card: SKShapeNode, value: Int) {
        let symbols = ["◆", "●", "▲", "■", "✦", "✚", "◇", "○"]
        card.children.compactMap { $0 as? SKLabelNode }.first?.text = symbols[value % symbols.count]
        card.run(.sequence([.scale(to: 1.06, duration: 0.06), .scale(to: 1.0, duration: 0.06)]))
    }

    private func hide(_ card: SKShapeNode) {
        guard let matched = card.userData?["matched"] as? Bool, !matched else { return }
        card.children.compactMap { $0 as? SKLabelNode }.first?.text = "?"
    }

    private func allPairsMatched() -> Bool {
        let cards = (0..<20).compactMap { childNode(withName: "//p_\($0)") as? SKShapeNode }
        return !cards.isEmpty && cards.allSatisfy { ($0.userData?["matched"] as? Bool) == true }
    }

    private func solve(_ ok: Bool) {
        guard !solved else { return }
        if ok {
            solved = true
            if let mainTrial {
                SaveManager.shared.complete(mainTrial.rawValue)
            } else {
                SaveManager.shared.completeHundred(level.id)
            }
            Haptics.success()
            Audio.shared.tone(freq: 720, duration: 0.2, volume: 0.22)
            setStatus("ИСПЫТАНИЕ ПРОЙДЕНО")
            FX.successBurst(in: self, at: CGPoint(x: size.width / 2, y: size.height * 0.48))
            run(.sequence([
                .wait(forDuration: 0.8),
                .run { [weak self] in self?.backToMap() }
            ]))
        } else {
            fail()
        }
    }

    private func fail() {
        guard !solved else { return }
        input.removeAll()
        Haptics.error()
        Audio.shared.tone(freq: 90, duration: 0.12, volume: 0.16)
        setStatus("ОШИБКА • ПОПРОБУЙ ЕЩЁ")
        run(.sequence([.scale(to: 1.02, duration: 0.06), .scale(to: 1.0, duration: 0.06)]))
    }

    private func backToMap() {
        if mainTrial != nil {
            let map = HubScene(size: size, act: 2)
            map.scaleMode = scaleMode
            view?.presentScene(map, transition: .fade(withDuration: 0.25))
        } else {
            let map = HundredLevelsScene(size: size)
            map.scaleMode = scaleMode
            view?.presentScene(map, transition: .fade(withDuration: 0.25))
        }
    }
}
