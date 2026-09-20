import SpriteKit

class ActThreeTrialBase: SKScene {
    let trial: Trial
    private var startTime = Date()
    private var finished = false
    private var target = 0
    private var sequence:[Int] = []
    private var input:[Int] = []
    private var changed = false

    init(size: CGSize, trial: Trial) { self.trial = trial; super.init(size: size) }
    required init?(coder: NSCoder) { fatalError() }

    override func didMove(to view: SKView) {
        backgroundColor = Palette.bgDeep
        startTime = Date()
        Audio.shared.start()
        Audio.shared.drone(freq: 32, duration: 2.5, volume: 0.12)
        let title = SKLabelNode(text: "\(trial.rawValue). \(trial.title.uppercased())")
        title.fontName = "AvenirNext-Heavy"; title.fontSize = 22; title.fontColor = Palette.magenta
        title.position = CGPoint(x:size.width/2,y:size.height*0.82); addChild(title)
        let hint = SKLabelNode(text: trial.subtitle)
        hint.fontName = "AvenirNext-Regular"; hint.fontSize = 14; hint.fontColor = Palette.textDim
        hint.position = CGPoint(x:size.width/2,y:size.height*0.75); addChild(hint)
        build()
        let back = SKShapeNode(rectOf: CGSize(width:120,height:42),cornerRadius:10)
        back.position = CGPoint(x:70,y:35); back.fillColor=SKColor(white:0.06,alpha:1); back.strokeColor=Palette.textDim; back.name="backButton"
        let bl=SKLabelNode(text:"← НАЗАД"); bl.fontName="AvenirNext-Bold"; bl.fontSize=13; bl.fontColor=Palette.text; bl.verticalAlignmentMode = .center
        back.addChild(bl); addChild(back)
    }

    private func box(_ text:String)->SKShapeNode {
        let b=SKShapeNode(rectOf:CGSize(width:size.width*0.84,height:310),cornerRadius:18)
        b.position=CGPoint(x:size.width/2,y:size.height*0.48); b.fillColor=SKColor(white:0.045,alpha:1); b.strokeColor=Palette.magenta; b.lineWidth=2
        let l=SKLabelNode(text:text); l.fontName="AvenirNext-Bold"; l.fontSize=15; l.fontColor=Palette.text; l.position=CGPoint(x:0,y:120); b.addChild(l); addChild(b); return b
    }

    private func build() {
        switch trial {
        case .director: buildCode()
        case .stairs: buildStairs()
        case .bell: buildBell()
        case .classZero: buildClassZero()
        case .notebook: buildNotebook()
        case .schoolBell: buildSchoolBell()
        case .lastDoor: buildLastDoor()
        default: break
        }
    }

    private func button(_ parent:SKNode,_ text:String,_ name:String,_ x:CGFloat,_ y:CGFloat)->SKShapeNode {
        let b=SKShapeNode(rectOf:CGSize(width:125,height:52),cornerRadius:10); b.position=CGPoint(x:x,y:y); b.fillColor=SKColor(white:0.08,alpha:1); b.strokeColor=Palette.cyan; b.name=name
        let l=SKLabelNode(text:text); l.fontName="AvenirNext-Bold"; l.fontSize=15; l.fontColor=Palette.text; l.verticalAlignmentMode = .center; b.addChild(l); parent.addChild(b); return b
    }

    private func buildCode() {
        let b=box("Код скрыт в кабинете. Найди 4 числа.")
        let digits=[1,2,3,4]
        for i in 0..<4 { button(b,"\(digits[i])","code_\(digits[i])",CGFloat(i-1)*70,10) }
        let l=SKLabelNode(text:"Введено: "); l.name="status"; l.fontName="AvenirNext-Bold"; l.fontSize=16; l.fontColor=Palette.cyan; l.position=CGPoint(x:0,y:-75); b.addChild(l)
        target=0; sequence=[1,3,1,3]
    }

    private func buildStairs() {
        let b=box("Запомни безопасную ступень на каждом ряду")
        sequence=[Int.random(in:0..<3),Int.random(in:0..<3),Int.random(in:0..<3),Int.random(in:0..<3)]
        for r in 0..<4 { for c in 0..<3 {
            let n=button(b,"\(c+1)","step_\(r)_\(c)",CGFloat(c-1)*88,CGFloat(75-r*48))
            n.strokeColor = Palette.textDim
            n.alpha = 0.55
        }}
        let l=SKLabelNode(text:"Смотри: безопасные ступени подсветятся"); l.name="status"; l.fontName="AvenirNext-Bold"; l.fontSize=13; l.fontColor=Palette.cyan; l.position=CGPoint(x:0,y:-120); b.addChild(l)
        run(.sequence([
            .wait(forDuration:0.5),
            .run { [weak self] in
                guard let self else { return }
                for r in 0..<4 {
                    let c=self.sequence[r]
                    if let n=self.childNode(withName:"//step_\(r)_\(c)") as? SKShapeNode {
                        n.run(.sequence([
                            .fadeAlpha(to:1,duration:0.12),
                            .scale(to:1.08,duration:0.12),
                            .wait(forDuration:0.45),
                            .scale(to:1,duration:0.10),
                            .fadeAlpha(to:0.55,duration:0.10)
                        ]))
                    }
                    if r < 3 {
                        self.run(.wait(forDuration:0.58))
                    }
                }
            },
            .wait(forDuration:2.9),
            .run { [weak self] in
                (self?.childNode(withName:"//status") as? SKLabelNode)?.text="Теперь выбери 4 ступени"
            }
        ]))
    }

    private func buildBell() {
        let b=box("Слушай и СМОТРИ: колокола загораются по очереди")
        sequence=[0,1,0,2,1]
        for i in 0..<3 {
            let n=button(b,"●","bell_\(i)",CGFloat(i-1)*88,20)
            n.alpha=0.48
        }
        let l=SKLabelNode(text:"Слушай последовательность…"); l.name="status"; l.fontName="AvenirNext-Bold"; l.fontSize=14; l.fontColor=Palette.textDim; l.position=CGPoint(x:0,y:-75); b.addChild(l)
        let actions: [SKAction] = sequence.enumerated().map { pair in
            let i=pair.element
            return .sequence([
                .run { [weak self] in
                    guard let self else { return }
                    if let n=self.childNode(withName:"//bell_\(i)") { n.run(.sequence([.group([.fadeAlpha(to:1,duration:0.08),.scale(to:1.16,duration:0.08)]),.wait(forDuration:0.20),.group([.fadeAlpha(to:0.48,duration:0.10),.scale(to:1,duration:0.10)])])) }
                    Audio.shared.tone(freq:[180.0,240.0,320.0][i],duration:0.22,volume:0.22)
                },
                .wait(forDuration:0.34)
            ])
        }
        run(.sequence(actions)) {
            l.text="Твоя очередь • 5 ударов"
            l.fontColor=Palette.cyan
        }
    }

    private func buildClassZero() {
        let b=box("В кабинете 0 есть одна лишняя вещь")
        target=7
        let items=["ПАРТА","СТУЛ","КНИГА","ЛАМПА","ЧАСЫ","МЕЛ","КАРТА","КУКЛА"]
        for i in 0..<8 {
            let n=button(b,items[i],"item_\(i)",CGFloat(i%4-1)*82, i<4 ? 45 : -35)
            n.strokeColor = i == target ? Palette.magenta : Palette.textDim
        }
        let clue=SKLabelNode(text:"Один предмет не принадлежит классу"); clue.fontName="AvenirNext-Regular"; clue.fontSize=12; clue.fontColor=Palette.textDim; clue.position=CGPoint(x:0,y:-120); b.addChild(clue)
    }

    private func buildNotebook() {
        let b=box("Запомни порядок символов")
        sequence=[2,0,3,1]
        let symbols=["△","○","✕","□"]
        for i in 0..<4 {
            let n=button(b,symbols[i],"note_\(i)",(CGFloat(i) - 1.5)*70,20)
            n.name="note_\(i)"
            n.alpha=0.92
        }
        let l=SKLabelNode(text:"Запомни: 4 символа"); l.name="status"; l.fontName="AvenirNext-Bold"; l.fontSize=14; l.fontColor=Palette.cyan; l.position=CGPoint(x:0,y:-75); b.addChild(l)
        run(.sequence([
            .wait(forDuration:1.8),
            .run { [weak self] in
                guard let self else { return }
                self.changed=true
                for i in 0..<4 {
                    if let n=self.childNode(withName:"//note_\(i)") as? SKShapeNode {
                        n.run(.fadeAlpha(to:0.42,duration:0.18))
                        n.children.compactMap{$0 as? SKLabelNode}.forEach { $0.run(.fadeAlpha(to:0,duration:0.18)) }
                    }
                }
                (self.childNode(withName:"//status") as? SKLabelNode)?.text="Теперь повтори • 0 / 4"
            }
        ]))
    }

    private func buildSchoolBell() {
        let b=box("Останови часы ровно на 13:13")
        let clock=SKLabelNode(text:"13:10"); clock.name="clock"; clock.fontName="AvenirNext-Heavy"; clock.fontSize=46; clock.fontColor=Palette.text; clock.position=CGPoint(x:0,y:25); b.addChild(clock)
        let stop=button(b,"ОСТАНОВИТЬ","stopClock",0,-60)
        let vals=["13:10","13:11","13:12","13:13","13:14","13:15"]
        run(.sequence([
            .wait(forDuration:0.45),
            .run { [weak self,weak clock] in
                guard let self,let clock else{return}
                self.changed=true
                let tick=Int(clock.userData?["tick"] as? Int ?? 0)
                let next=min(tick+1, vals.count-1)
                if clock.userData == nil { clock.userData = NSMutableDictionary() }
                clock.userData?["tick"]=next
                clock.text=vals[next]
            },
            .repeatForever(.sequence([
                .wait(forDuration:0.65),
                .run { [weak self,weak clock] in
                    guard let self,let clock else{return}
                    let tick=Int(clock.userData?["tick"] as? Int ?? 0)
                    let next=(tick+1) % vals.count
                    if clock.userData == nil { clock.userData = NSMutableDictionary() }
                    clock.userData?["tick"]=next
                    clock.text=vals[next]
                    self.changed=true
                }
            ]))
        ]))
        stop.name="stopClock"
    }

    private func buildLastDoor() {
        let b=box("За дверью четыре судьбы. Выбери одну.")
        let endings=["ОСТАТЬСЯ","УЙТИ","СВОБОДА","ШКОЛА"]
        for i in 0..<4 { button(b,endings[i],"ending_\(i+1)", i%2==0 ? -82:82, i<2 ? 35:-45) }
        let l=SKLabelNode(text:"Выбор изменит финал"); l.fontName="AvenirNext-Bold"; l.fontSize=14; l.fontColor=Palette.blood; l.position=CGPoint(x:0,y:-115); b.addChild(l)
    }

    override func touchesEnded(_ touches:Set<UITouch>,with event:UIEvent?) {
        guard let p=touches.first?.location(in:self) else{return}; var n:SKNode?=atPoint(p)
        while let node=n {
            if node.name=="backButton" { back(); return }
            guard let name=node.name else { n=node.parent; continue }
            if name.hasPrefix("code_"),let v=Int(name.dropFirst(5)) { input.append(v); updateStatus(); if input.count==sequence.count { input == sequence ? complete() : resetInput() }; return }
            if name.hasPrefix("step_") { let parts=name.split(separator:"_"); if parts.count==3,let r=Int(parts[1]),let c=Int(parts[2]) { if c==sequence[r] { input.append(r); if input.count==4 {complete()} } else { failPulse(node); input.removeAll() } }; return }
            if name.hasPrefix("bell_"),let i=Int(name.dropFirst(5)) { input.append(i); let ok=input.indices.allSatisfy { input[$0]==sequence[$0] }; if !ok {resetInput()} else if input.count==sequence.count {complete()}; return }
            if name.hasPrefix("item_"),let i=Int(name.dropFirst(5)) { i==target ? complete() : failPulse(node); return }
            if name.hasPrefix("note_"),let i=Int(name.dropFirst(5)) {
                if !changed { failPulse(node); return }
                input.append(i)
                (childNode(withName:"//status") as? SKLabelNode)?.text="Теперь повтори • \(input.count) / \(sequence.count)"
                if input.count==sequence.count { input==sequence ? complete():resetInput() }
                return
            }
            if name=="stopClock" { if (childNode(withName:"//clock") as? SKLabelNode)?.text == "13:13" { complete() } else { failPulse(node) }; return }
            if name.hasPrefix("ending_"),let i=Int(name.dropFirst(7)) { SaveManager.shared.setEnding(i); complete(); return }
            n=node.parent
        }
    }

    private func updateStatus(){ (childNode(withName:"//status") as? SKLabelNode)?.text="Введено: "+input.map(String.init).joined(separator:" ") }
    private func resetInput(){
        input.removeAll()
        if trial == .notebook {
            (childNode(withName:"//status") as? SKLabelNode)?.text="ОШИБКА — снова: 0 / 4"
        } else {
            (childNode(withName:"//status") as? SKLabelNode)?.text="ОШИБКА — СНАЧАЛА"
        }
        failPulse(self)
    }
    private func failPulse(_ node:SKNode){ Haptics.error(); Audio.shared.tone(freq:90,duration:0.12,volume:0.16); node.run(.sequence([.scale(to:0.92,duration:0.06),.scale(to:1,duration:0.06)])) }
    private func complete(){
        guard !finished else{return}; finished=true; Audio.shared.tone(freq:760,duration:0.22,volume:0.22); FX.flash(on:self,color:Palette.magenta,duration:0.22)
        if trial == .lastDoor {
            sceneEnd()
        } else {
            GameFlow.completeAndReturn(self,trial:trial,time:Date().timeIntervalSince(startTime),delay:0.9)
        }
    }
    private func sceneEnd(){ SaveManager.shared.complete(trial.rawValue,time:Date().timeIntervalSince(startTime)); run(.sequence([.wait(forDuration:1.0),.run{[weak self] in guard let self else{return}; let e=EndingScene(size:self.size); e.scaleMode=self.scaleMode; self.view?.presentScene(e,transition:.fade(withDuration:0.7))}])) }
    private func back(){ let h=HubScene(size:size,act:3); h.scaleMode=scaleMode; view?.presentScene(h,transition:.fade(withDuration:0.25)) }
}

final class Trial15_Director: ActThreeTrialBase { init(size:CGSize){super.init(size:size,trial:.director)}; required init?(coder:NSCoder){fatalError()} }
final class Trial16_Stairs: ActThreeTrialBase { init(size:CGSize){super.init(size:size,trial:.stairs)}; required init?(coder:NSCoder){fatalError()} }
final class Trial17_Bell: ActThreeTrialBase { init(size:CGSize){super.init(size:size,trial:.bell)}; required init?(coder:NSCoder){fatalError()} }
final class Trial18_ClassZero: ActThreeTrialBase { init(size:CGSize){super.init(size:size,trial:.classZero)}; required init?(coder:NSCoder){fatalError()} }
final class Trial19_Notebook: ActThreeTrialBase { init(size:CGSize){super.init(size:size,trial:.notebook)}; required init?(coder:NSCoder){fatalError()} }
final class Trial20_SchoolBell: ActThreeTrialBase { init(size:CGSize){super.init(size:size,trial:.schoolBell)}; required init?(coder:NSCoder){fatalError()} }
final class Trial21_LastDoor: ActThreeTrialBase { init(size:CGSize){super.init(size:size,trial:.lastDoor)}; required init?(coder:NSCoder){fatalError()} }
