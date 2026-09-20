import SpriteKit

final class HubScene: SKScene {
    private var act: Int = 1
    private var levelNodes: [SKNode] = []

    init(size: CGSize, act: Int = 1) { super.init(size: size); self.act = act }
    required init?(coder: NSCoder) { super.init(coder: coder); self.act = 1 }

    override func didMove(to view: SKView) {
        removeAllChildren()
        backgroundColor = Palette.bg
        let accent = act == 2 ? Palette.blood : Palette.cyan
        FX.atmosphere(in: self, accent: accent)
        FX.scanline(in: self, color: accent)
        buildHeader(); buildLevels(); buildBackButton()
        addChild(FX.vignette(size: size, intensity: 0.68))
    }

    private func buildHeader() {
        let tag = SKLabelNode(text: act == 1 ? "ЗАПАДНОЕ КРЫЛО" : "НИЖНИЙ УРОВЕНЬ")
        tag.fontName="AvenirNext-Bold"; tag.fontSize=10; tag.fontColor=act == 1 ? Palette.cyan : Palette.blood
        tag.position=CGPoint(x:size.width/2,y:size.height*0.86); tag.zPosition=20; addChild(tag)
        let title = SKLabelNode(text: act == 1 ? "КАРТА ШКОЛЫ" : "ПОДВАЛ")
        title.fontName="AvenirNext-Heavy"; title.fontSize=26; title.fontColor=Palette.text
        title.position=CGPoint(x:size.width/2,y:size.height*0.775); title.zPosition=20; addChild(title)
        let subtitle = SKLabelNode(text: act == 1 ? "АКТ I • НАЧАЛО" : "АКТ II • НИЖЕ УЖЕ НЕКУДА")
        subtitle.fontName="AvenirNext-Medium"; subtitle.fontSize=11; subtitle.fontColor=Palette.textDim
        subtitle.position=CGPoint(x:size.width/2,y:size.height*0.735); subtitle.zPosition=20; addChild(subtitle)
    }

    private func buildLevels() {
        levelNodes.removeAll()
        let trials = act == 1 ? Trial.actOne : Trial.actTwo
        let positions:[CGPoint] = [
            CGPoint(x:size.width*0.18,y:size.height*0.59), CGPoint(x:size.width*0.39,y:size.height*0.59),
            CGPoint(x:size.width*0.61,y:size.height*0.59), CGPoint(x:size.width*0.82,y:size.height*0.59),
            CGPoint(x:size.width*0.18,y:size.height*0.43), CGPoint(x:size.width*0.39,y:size.height*0.43),
            CGPoint(x:size.width*0.61,y:size.height*0.43), CGPoint(x:size.width*0.82,y:size.height*0.43),
            CGPoint(x:size.width*0.29,y:size.height*0.27), CGPoint(x:size.width*0.50,y:size.height*0.27),
            CGPoint(x:size.width*0.71,y:size.height*0.27)
        ]
        for (index,trial) in trials.enumerated() where index < positions.count {
            addTrialCard(trial,at:positions[index],accent:act == 1 ? Palette.cyan : Palette.blood)
        }
        if act == 1 {
            let bridge = SKLabelNode(text:"МЕЖДУ АКТАМИ")
            bridge.fontName="AvenirNext-Bold"; bridge.fontSize=9; bridge.fontColor=Palette.amber
            bridge.position=CGPoint(x:size.width/2,y:size.height*0.205); bridge.zPosition=20; addChild(bridge)
            addSpecialCard(.lastDesk,at:CGPoint(x:size.width*0.31,y:size.height*0.12))
            addSpecialCard(.lastDoor,at:CGPoint(x:size.width*0.69,y:size.height*0.12))
        }
        let progress = SKLabelNode(text:act == 1 ? "(trials.count) ОСНОВНЫХ • 2 ПЕРЕХОДА" : "(trials.count) ОСНОВНЫХ • ВСЕ ДОСТУПНЫ")
        progress.fontName="AvenirNext-Medium"; progress.fontSize=9; progress.fontColor=Palette.textFaint
        progress.position=CGPoint(x:size.width/2,y:12); progress.zPosition=20; addChild(progress)
    }

    private func addTrialCard(_ trial:Trial,at position:CGPoint,accent:SKColor) {
        let completed=SaveManager.shared.data.completedTrials.contains(trial.rawValue)
        let node=SKShapeNode(rectOf:CGSize(width:size.width*0.19,height:62),cornerRadius:12)
        node.position=position; node.name="level_\(trial.rawValue)"; node.fillColor=Palette.panel
        node.strokeColor=completed ? Palette.amber : accent; node.lineWidth=completed ? 2.5 : 1.3; node.glowWidth=completed ? 7 : 3; node.zPosition=5
        let number=SKLabelNode(text:String(format:"%02d",trial.displayNumber))
        number.fontName="AvenirNext-Heavy"; number.fontSize=21; number.fontColor=Palette.text; number.position=CGPoint(x:0,y:9)
        number.verticalAlignmentMode = .center; number.name=node.name; node.addChild(number)
        let label=SKLabelNode(text:trial.title.uppercased())
        label.fontName="AvenirNext-Bold"; label.fontSize=7.5; label.fontColor=Palette.textDim; label.position=CGPoint(x:0,y:-16)
        label.verticalAlignmentMode = .center; label.name=node.name; node.addChild(label)
        addChild(node); FX.cardGlow(node,color:completed ? Palette.amber : accent,radius:completed ? 7 : 4); levelNodes.append(node)
    }

    private func addSpecialCard(_ trial:Trial,at position:CGPoint) {
        let node=SKShapeNode(rectOf:CGSize(width:size.width*0.30,height:42),cornerRadius:10)
        node.position=position; node.name="level_\(trial.rawValue)"; node.fillColor=Palette.panel; node.strokeColor=Palette.amber
        node.lineWidth=1.4; node.zPosition=10
        let label=SKLabelNode(text:"\(String(format: "%02d", trial.rawValue)) • \(trial.title.uppercased())")
        label.fontName="AvenirNext-Bold"; label.fontSize=9; label.fontColor=Palette.amber; label.verticalAlignmentMode = .center
        label.name=node.name; node.addChild(label); addChild(node)
    }

    private func buildBackButton() {
        let back=SKLabelNode(text:"← МЕНЮ"); back.fontName="AvenirNext-Bold"; back.fontSize=16; back.fontColor=Palette.text
        back.name="back"; back.position=CGPoint(x:58,y:34); back.zPosition=30; addChild(back)
        let sw=SKLabelNode(text:act == 1 ? "АКТ II  →" : "←  АКТ I")
        sw.fontName="AvenirNext-Bold"; sw.fontSize=16; sw.fontColor=act == 1 ? Palette.blood : Palette.cyan
        sw.name="switchAct"; sw.position=CGPoint(x:size.width-58,y:34); sw.zPosition=30; addChild(sw)
    }

    override func touchesEnded(_ touches:Set<UITouch>,with event:UIEvent?) {
        guard let point=touches.first?.location(in:self) else{return}
        var node:SKNode?=atPoint(point)
        while let current=node {
            if current.name=="back" { let s=MenuScene(size:size); s.scaleMode=scaleMode; view?.presentScene(s,transition:.fade(withDuration:0.25)); return }
            if current.name=="switchAct" { let s=HubScene(size:size,act:act == 1 ? 2 : 1); s.scaleMode=scaleMode; view?.presentScene(s,transition:.fade(withDuration:0.25)); return }
            if let name=current.name,name.hasPrefix("level_"),let raw=Int(name.dropFirst(6)),let trial=Trial(rawValue:raw) { launch(trial); return }
            node=current.parent
        }
    }

    private func launch(_ trial:Trial) {
        let scene:SKScene
        switch trial {
        case .melody: scene=Trial2_Melody(size:size)
        case .dontLookAway: scene=Trial5_DontLookAway(size:size)
        case .notes: scene=Trial6_Notes(size:size)
        case .finalChoice: scene=Trial7_FinalChoice(size:size)
        case .mirror: scene=Trial1_Mirror(size:size)
        case .darkCorridor: scene=Trial3_DarkCorridor(size:size)
        case .doors: scene=Trial4_Doors(size:size)
        case .mirrorHall: scene=Trial8_MirrorHall(size:size)
        case .candles: scene=Trial9_Candles(size:size)
        case .whispers: scene=Trial10_Whispers(size:size)
        case .shadows: scene=Trial11_Shadows(size:size)
        case .clock: scene=Trial12_Clock(size:size)
        case .rhyme: scene=Trial13_Rhyme(size:size)
        case .lastDesk: scene=Trial14_LastDesk(size:size)
        case .director: scene=Trial15_Director(size:size)
        case .stairs: scene=Trial16_Stairs(size:size)
        case .classZero: scene=Trial18_ClassZero(size:size)
        case .schoolBell: scene=Trial20_SchoolBell(size:size)
        case .lastDoor: scene=Trial21_LastDoor(size:size)
        case .archiveMemory,.archiveMirror,.archiveWord,.archiveChoice,.archiveBranch,.archiveCount:
            guard let level=Levels.migrated[trial] else{return}
            let s=HundredTrialScene(size:size,level:level,mainTrial:trial); s.scaleMode=scaleMode
            view?.presentScene(s,transition:.fade(withDuration:0.25)); return
        }
        scene.scaleMode=scaleMode; view?.presentScene(scene,transition:.fade(withDuration:0.25))
    }
}
