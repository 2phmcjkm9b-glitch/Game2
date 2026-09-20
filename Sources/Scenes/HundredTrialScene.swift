import SpriteKit

final class HundredTrialScene: SKScene {
    private let level: Level
    private var target = 0
    private var sequence:[Int] = []
    private var input:[Int] = []
    private var cells:[SKShapeNode] = []
    private var status = SKLabelNode()
    private var started = false
    private var solved = false

    init(size:CGSize, level:Level) { self.level=level; super.init(size:size) }
    required init?(coder:NSCoder){ fatalError() }

    override func didMove(to view:SKView) {
        backgroundColor=Palette.bgDeep
        Audio.shared.start()
        Audio.shared.drone(freq:34,duration:2.0,volume:0.10)

        let title=SKLabelNode(text:"\(String(format:"%02d",level.id)). \(level.title.uppercased())")
        title.fontName="AvenirNext-Heavy"; title.fontSize=21; title.fontColor=Palette.blood
        title.position=CGPoint(x:size.width/2,y:size.height*0.84); addChild(title)

        let info=SKLabelNode(text: level.hint ?? typeHint())
        info.fontName="AvenirNext-Regular"; info.fontSize=13; info.fontColor=Palette.textDim
        info.position=CGPoint(x:size.width/2,y:size.height*0.77); addChild(info)

        status=SKLabelNode(text:"ИСПЫТАНИЕ \(level.difficulty)/10")
        status.fontName="AvenirNext-Bold"; status.fontSize=13; status.fontColor=Palette.cyan
        status.position=CGPoint(x:size.width/2,y:size.height*0.70); addChild(status)

        buildGame()

        let back=SKShapeNode(rectOf:CGSize(width:120,height:42),cornerRadius:10)
        back.position=CGPoint(x:70,y:35); back.fillColor=Palette.panel; back.strokeColor=Palette.textDim; back.name="back"
        let bl=SKLabelNode(text:"← НАЗАД"); bl.fontName="AvenirNext-Bold"; bl.fontSize=13; bl.fontColor=Palette.text; bl.verticalAlignmentMode = .center; bl.name="back"; back.addChild(bl); addChild(back)
        addChild(FX.vignette(size:size,intensity:0.68))
    }

    private func typeHint()->String {
        switch level.type {
        case .findOdd:return "Найди лишний элемент"
        case .lightsOut:return "Погаси все огни"
        case .sequence:return "Запомни последовательность"
        case .memoryGrid:return "Запомни клетки"
        case .mirrorMatch:return "Найди нужное отражение"
        case .shadows:return "Найди лишнюю тень"
        case .wordChain:return "Собери слово"
        case .choice:return "Выбери верную дверь"
        case .reversedInput:return "Правило перевёрнуто"
        case .countTrap:return "Посчитай объекты"
        }
    }

    private func buildGame() {
        switch level.type {
        case .findOdd,.mirrorMatch,.shadows,.reversedInput: buildGrid()
        case .lightsOut: buildLights()
        case .sequence: buildSequence()
        case .memoryGrid: buildMemory()
        case .wordChain: buildWord()
        case .choice: buildChoice()
        case .countTrap: buildCount()
        }
    }

    private func makeCell(_ text:String,_ name:String,_ x:CGFloat,_ y:CGFloat)->SKShapeNode {
        let b=SKShapeNode(rectOf:CGSize(width:62,height:52),cornerRadius:10)
        b.position=CGPoint(x:x,y:y); b.fillColor=Palette.panel; b.strokeColor=Palette.cyanSoft; b.lineWidth=1.5; b.name=name; b.zPosition=10
        let l=SKLabelNode(text:text); l.fontName="AvenirNext-Bold"; l.fontSize=18; l.fontColor=Palette.text; l.verticalAlignmentMode = .center; l.name=name; b.addChild(l); addChild(b)
        return b
    }

    private func buildGrid() {
        let cols=min(6,max(3,Int(level.params["cols"] ?? 4)))
        let rows=min(7,max(3,Int(level.params["rows"] ?? 4)))
        let count=cols*rows
        target=Int.random(in:0..<count)
        let sx=CGFloat(cols-1)*36
        let sy=CGFloat(rows-1)*30
        for i in 0..<count {
            let c=i%cols,r=i/cols
            let x=size.width/2 + CGFloat(c)*72-sx*1.0
            let y=size.height*0.48 + (CGFloat(rows-1-r)*60)-sy
            let symbol = level.type == .shadows ? "◐" : (level.type == .mirrorMatch ? "◇" : "■")
            let b=makeCell(symbol,"g_\(i)",x,y)
            if i==target { b.alpha=0.92 }
            cells.append(b)
        }
        status.text="НАЙДИ ОТЛИЧИЕ"
    }

    private func buildLights() {
        let cols=min(6,max(3,Int(level.params["cols"] ?? 3)))
        let rows=min(6,max(3,Int(level.params["rows"] ?? 3)))
        let count=cols*rows
        target=Int.random(in:0..<count)
        for i in 0..<count {
            let c=i%cols,r=i/cols
            let x=size.width/2 + CGFloat(c-(cols-1)/2)*62
            let y=size.height*0.47 + CGFloat((rows-1)/2-r)*58
            let b=makeCell(i==target ? "●":"○","l_\(i)",x,y)
            b.strokeColor=i==target ? Palette.candle : Palette.cyanSoft
            cells.append(b)
        }
        status.text="ПОГАСИ ВСЕ"
    }

    private func buildSequence() {
        let len=min(10,max(3,Int(level.params["len"] ?? Double(3+level.difficulty/2))))
        sequence=(0..<len).map{ _ in Int.random(in:0..<4) }
        for i in 0..<4 {
            let x=size.width/2+(CGFloat(i) - 1.5)*78
            _=makeCell(["◆","●","▲","■"][i],"s_\(i)",x,size.height*0.45)
        }
        status.text="СМОТРИ..."
        var actions:[SKAction]=[]
        for (i,v) in sequence.enumerated() {
            actions += [.wait(forDuration:0.18),.run{[weak self] in
                guard let self else{return}
                if let n=self.childNode(withName:"//s_\(v)") as? SKShapeNode {
                    n.run(.sequence([.scale(to:1.16,duration:0.10),.wait(forDuration:0.18),.scale(to:1,duration:0.10)]))
                }
                Audio.shared.tone(freq:180+Double(v)*70,duration:0.12,volume:0.16)
                if i==self.sequence.count-1 { self.started=true; self.status.text="ПОВТОРИ • 0/\(self.sequence.count)" }
            }]
        }
        run(.sequence(actions))
    }

    private func buildMemory() {
        let cols=4,rows=4,count=16
        let amount=min(12,max(3,Int(level.params["cells"] ?? Double(3+level.difficulty/2))))
        let chosen=Array(Set((0..<count).shuffled().prefix(amount)))
        sequence=chosen
        for i in 0..<count {
            let c=i%cols,r=i/cols
            let x=size.width/2+(CGFloat(c) - 1.5)*68
            let y=size.height*0.48+CGFloat(1-r)*62
            let b=makeCell(chosen.contains(i) ? "●":"·","m_\(i)",x,y)
            cells.append(b)
        }
        status.text="ЗАПОМНИ"
        run(.sequence([.wait(forDuration:max(0.7,1.5-Double(level.difficulty)*0.06)),.run{[weak self] in
            guard let self else{return}; self.started=true
            for b in self.cells { b.children.compactMap{$0 as? SKLabelNode}.forEach{$0.text="?"} }
            self.status.text="ПОВТОРИ • 0/\(self.sequence.count)"
        }]))
    }

    private func buildWord() {
        let words=["ШКОЛА","ТЕНЬ","ЭХО","ЗЕРКАЛО","ПОДВАЛ","МЕЛОДИЯ","ПАМЯТЬ","ТИШИНА"]
        let word=words[(level.id-1)%words.count]
        sequence=word.utf8.map{Int($0)}
        let letters=Array(word).shuffled()
        for (i,ch) in letters.enumerated() {
            _=makeCell(String(ch),"w_\(Int(ch.asciiValue ?? 65))_\(i)",size.width/2+CGFloat(i-letters.count/2)*58,size.height*0.45)
        }
        status.text="СОБЕРИ: \(word.count) БУКВ"
    }

    private func buildChoice() {
        let count=min(5,max(3,Int(level.params["options"] ?? 3)))
        target=Int.random(in:0..<count)
        for i in 0..<count {
            let y=size.height*0.52-CGFloat(i)*58
            let b=makeCell("ДВЕРЬ \(i+1)","c_\(i)",size.width/2,y)
            b.strokeColor=Palette.textDim
        }
        status.text="ОДНА ДВЕРЬ ВЕРНА"
    }

    private func buildCount() {
        let amount=min(18,max(4,Int(level.params["objects"] ?? 6)))
        target=amount
        for i in 0..<amount {
            let angle=Double(i)*Double.pi*2/Double(amount)
            let x=size.width/2+CGFloat(cos(angle))*95
            let y=size.height*0.47+CGFloat(sin(angle))*95
            let b=SKShapeNode(circleOfRadius:10); b.position=CGPoint(x:x,y:y); b.fillColor=Palette.candle; b.strokeColor=Palette.amber; b.zPosition=10; addChild(b)
        }
        status.text="СКОЛЬКО ОГНЕЙ?"
        let start=amount-2
        for i in 0..<4 {
            let b=makeCell("\(start+i)","n_\(start+i)",size.width/2+(CGFloat(i) - 1.5)*68,size.height*0.25)
            b.name="n_\(start+i)"
        }
    }

    override func touchesEnded(_ touches:Set<UITouch>,with event:UIEvent?) {
        guard let p=touches.first?.location(in:self) else{return}
        var n:SKNode?=atPoint(p)
        while let node=n {
            guard let name=node.name else {n=node.parent;continue}
            if name=="back" { back(); return }
            if name.hasPrefix("g_"),let i=Int(name.dropFirst(2)) { solve(i==target); return }
            if name.hasPrefix("l_"),let i=Int(name.dropFirst(2)) { solve(i==target); return }
            if name.hasPrefix("s_"),let i=Int(name.dropFirst(2)),started { input.append(i); status.text="ПОВТОРИ • \(input.count)/\(sequence.count)"; checkSequence(); return }
            if name.hasPrefix("m_"),let i=Int(name.dropFirst(2)),started { input.append(i); checkMemory(); return }
            if name.hasPrefix("w_"),let raw=name.split(separator:"_").dropFirst().first,let v=Int(raw) { input.append(v); if input.last==sequence[input.count-1] && input.count==sequence.count { solve(true) } else if input.last != sequence[input.count-1] { solve(false) }; return }
            if name.hasPrefix("c_"),let i=Int(name.dropFirst(2)) { solve(i==target); return }
            if name.hasPrefix("n_"),let i=Int(name.dropFirst(2)) { solve(i==target); return }
            n=node.parent
        }
    }

    private func checkSequence() {
        guard input.count<=sequence.count else {solve(false);return}
        for i in input.indices where input[i] != sequence[i] {solve(false);return}
        if input.count==sequence.count {solve(true)}
    }
    private func checkMemory() {
        if input.contains(where:{!sequence.contains($0)}) {solve(false);return}
        if input.count==sequence.count && Set(input)==Set(sequence) {solve(true)}
    }
    private func solve(_ ok:Bool) {
        guard !solved else{return}
        if ok { solved=true; SaveManager.shared.completeHundred(level.id); Haptics.success(); Audio.shared.tone(freq:720,duration:0.2,volume:0.22); status.text="ИСПЫТАНИЕ ПРОЙДЕНО"; FX.successBurst(in:self,at:CGPoint(x:size.width/2,y:size.height*0.48)); run(.sequence([.wait(forDuration:0.8),.run{[weak self] in self?.backToMap()}])) }
        else { Haptics.error(); Audio.shared.tone(freq:90,duration:0.12,volume:0.16); status.text="ОШИБКА • ПОПРОБУЙ ЕЩЁ"; run(.sequence([.scale(to:1.02,duration:0.06),.scale(to:1,duration:0.06)])) }
    }
    private func back() { backToMap() }
    private func backToMap() {
        let s=HundredLevelsScene(size:size); s.scaleMode=scaleMode; view?.presentScene(s,transition:.fade(withDuration:0.25))
    }
}
