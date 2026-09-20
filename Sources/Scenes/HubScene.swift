import SpriteKit

final class HubScene: SKScene {
    private let act: Int
    private let layout: [(CGFloat, CGFloat)] = [(0.20,0.75),(0.50,0.75),(0.80,0.75),(0.20,0.50),(0.50,0.50),(0.80,0.50),(0.50,0.22)]

    init(size: CGSize, act: Int = 1) { self.act = act; super.init(size: size) }
    required init?(coder: NSCoder) { fatalError() }

    override func didMove(to view: SKView) {
        backgroundColor = Palette.bg
        FX.dust(in: self, count: 30)
        addChild(VignetteNode(size: size, intensity: act == 1 ? 0.8 : 0.92))
        buildHeader(); buildRooms(); buildBackButton(); buildActSwitch()
        Audio.shared.start()
        Audio.shared.drone(freq: act == 1 ? 52 : 38, duration: 2.5, volume: act == 1 ? 0.07 : 0.11)
    }

    private func buildHeader() {
        let h = SKLabelNode(text: act == 1 ? "КАРТА ШКОЛЫ" : "ПОДВАЛ")
        h.fontName = "AvenirNext-Bold"; h.fontSize = 24; h.fontColor = act == 1 ? Palette.text : Palette.blood
        h.position = CGPoint(x: size.width/2, y: size.height * 0.86); addChild(h)
    }

    private func buildRooms() {
        let trials = act == 1 ? Trial.actOne : Trial.actTwo
        for (i,t) in trials.enumerated() {
            let p = CGPoint(x:size.width*layout[i].0,y:size.height*layout[i].1)
            let done = SaveManager.shared.data.completedTrials.contains(t.rawValue)
            let locked = isLocked(t)
            let door = makeDoor(t, done: done, locked: locked); door.position=p; door.name="trial_(t.rawValue)"; addChild(door)
        }
    }

    private func isLocked(_ t: Trial) -> Bool {
        if t.act == 2 { return !SaveManager.shared.data.actTwoUnlocked }
        if t.rawValue == 1 { return false }
        return !SaveManager.shared.data.completedTrials.contains(t.rawValue - 1)
    }

    private func makeDoor(_ t: Trial, done: Bool, locked: Bool) -> SKNode {
        let n=SKNode(); let w=size.width*0.26; let h=size.height*0.14
        let r=SKShapeNode(rectOf:CGSize(width:w,height:h),cornerRadius:12)
        r.fillColor=SKColor(white:0.05,alpha:0.95); r.strokeColor=locked ? SKColor(white:0.25,alpha:1):(done ? Palette.amber:(act==1 ? Palette.cyan:Palette.blood))
        r.lineWidth=2; r.glowWidth=locked ? 0:(done ? 4:8); n.addChild(r)
        let num=SKLabelNode(text:"(t.rawValue)"); num.fontName="AvenirNext-Heavy"; num.fontSize=22; num.fontColor=locked ? Palette.textDim:Palette.text; num.position=CGPoint(x:-w/2+22,y:0); num.verticalAlignmentMode=.center; n.addChild(num)
        let name=SKLabelNode(text:t.title); name.fontName="AvenirNext-Bold"; name.fontSize=12; name.fontColor=locked ? Palette.textDim:Palette.text; name.position=CGPoint(x:12,y:8); name.verticalAlignmentMode=.center; n.addChild(name)
        let sub=SKLabelNode(text:locked ? "закрыто":(done ? "✓ пройдено":t.subtitle)); sub.fontName="AvenirNext-Regular"; sub.fontSize=9; sub.fontColor=locked ? Palette.textDim:(done ? Palette.amber:Palette.textDim); sub.position=CGPoint(x:12,y:-10); sub.verticalAlignmentMode=.center; n.addChild(sub)
        return n
    }

    private func buildBackButton() {
        let b=NeonButton(title:"←",size:CGSize(width:56,height:44),color:Palette.textDim); b.position=CGPoint(x:46,y:34)
        b.action={ [weak self] in guard let s=self else{return}; let m=MenuScene(size:s.size);m.scaleMode=s.scaleMode;s.view?.presentScene(m,transition:.fade(withDuration:0.4)) }; addChild(b)
    }

    private func buildActSwitch() {
        guard SaveManager.shared.data.actTwoUnlocked else{return}
        let b=NeonButton(title:act==1 ? "СПУСТИТЬСЯ В ПОДВАЛ ↓":"ВЕРНУТЬСЯ НАВЕРХ ↑",size:CGSize(width:size.width*0.72,height:46),color:act==1 ? Palette.blood:Palette.cyan)
        b.position=CGPoint(x:size.width/2,y:70); b.action={ [weak self] in guard let s=self else{return}; let next=s.act==1 ? 2:1; let n=HubScene(size:s.size,act:next);n.scaleMode=s.scaleMode; s.view?.presentScene(n,transition: next==2 ? .doorsOpenVertical(withDuration:0.7):.doorsCloseVertical(withDuration:0.7)) }; addChild(b)
    }

    override func touchesBegan(_ touches:Set<UITouch>,with event:UIEvent?) {
        guard let p=touches.first?.location(in:self) else{return}
        var current: SKNode? = atPoint(p)
        while let n=current {
            if let name=n.name, name.hasPrefix("trial_"), let raw=Int(name.dropFirst(6)), let t=Trial(rawValue:raw) {
                guard !isLocked(t) else { Haptics.error(); Audio.shared.tone(freq:120,duration:0.15,volume:0.2,type:.square); return }
                launch(t); return
            }
            current=n.parent
        }
    }

    private func launch(_ t: Trial) {
        Haptics.medium(); Audio.shared.tone(freq:880,duration:0.1,volume:0.2)
        let s: SKScene
        switch t {
        case .mirror: s=Trial1_Mirror(size:size); case .melody: s=Trial2_Melody(size:size); case .darkCorridor: s=Trial3_DarkCorridor(size:size)
        case .doors: s=Trial4_Doors(size:size); case .dontLookAway: s=Trial5_DontLookAway(size:size); case .notes: s=Trial6_Notes(size:size); case .finalChoice: s=Trial7_FinalChoice(size:size)
        case .mirrorHall: s=Trial8_MirrorHall(size:size); case .candles: s=Trial9_Candles(size:size); case .whispers: s=Trial10_Whispers(size:size); case .shadows: s=Trial11_Shadows(size:size); case .clock: s=Trial12_Clock(size:size); case .rhyme: s=Trial13_Rhyme(size:size); case .lastDesk: s=Trial14_LastDesk(size:size)
        }
        s.scaleMode=scaleMode
        view?.presentScene(s,transition:t.act==2 ? .doorsOpenVertical(withDuration:0.6):.doorsOpenHorizontal(withDuration:0.6))
    }
}
