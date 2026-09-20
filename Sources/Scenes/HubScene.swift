import SpriteKit

final class HubScene: SKScene {
    private var act: Int = 1
    private var levelNodes: [SKNode] = []

    init(size: CGSize, act: Int = 1) { super.init(size: size); self.act = min(5, max(1, act)) }
    required init?(coder: NSCoder) { super.init(coder: coder); self.act = 1 }

    override func didMove(to view: SKView) {
        removeAllChildren()
        backgroundColor = Palette.bg
        let accent = act == 1 || act == 3 || act == 5 ? Palette.cyan : Palette.blood
        FX.atmosphere(in: self, accent: accent)
        FX.scanline(in: self, color: accent)
        buildHeader()
        buildLevels()
        buildBackButton()
        addChild(FX.vignette(size: size, intensity: 0.68))
    }

    private func actTitle() -> String {
        switch act {
        case 1: return "АКТ I • ПРОБУЖДЕНИЕ"
        case 2: return "АКТ II • ШЁПОТЫ"
        case 3: return "АКТ III • ОТРАЖЕНИЯ"
        case 4: return "АКТ IV • НИЖНИЕ ЭТАЖИ"
        default: return "АКТ V • ПОСЛЕДНЯЯ НОЧЬ"
        }
    }

    private func buildHeader() {
        let tag = SKLabelNode(text: "ШКОЛА 13 • \(actTitle())")
        tag.fontName="AvenirNext-Bold"; tag.fontSize=10; tag.fontColor=act % 2 == 0 ? Palette.blood : Palette.cyan
        tag.position=CGPoint(x:size.width/2,y:size.height*0.88); tag.zPosition=20; addChild(tag)

        // Lowered so the title stays below the iPhone notch / safe area.
        let title = SKLabelNode(text: "КАРТА ШКОЛЫ")
        title.fontName="AvenirNext-Heavy"; title.fontSize=26; title.fontColor=Palette.text
        title.position=CGPoint(x:size.width/2,y:size.height*0.79); title.zPosition=20; addChild(title)

        let subtitle = SKLabelNode(text: "АКТ \(act) • \(act == 5 ? "ФИНАЛ" : "ПРОХОЖДЕНИЕ")")
        subtitle.fontName="AvenirNext-Medium"; subtitle.fontSize=11; subtitle.fontColor=Palette.textDim
        subtitle.position=CGPoint(x:size.width/2,y:size.height*0.745); subtitle.zPosition=20; addChild(subtitle)

        buildPuzzleProgress()
    }

    private func buildPuzzleProgress() {
        let collected = SaveManager.shared.data.puzzlePieces.count
        let label = SKLabelNode(text: "ПАЗЛ: \(collected)/5 ФРАГМЕНТОВ")
        label.fontName="AvenirNext-Bold"; label.fontSize=10; label.fontColor=Palette.amber
        label.position=CGPoint(x:size.width/2,y:size.height*0.70); label.zPosition=20; addChild(label)

        let startX = size.width/2 - 54
        for i in 1...5 {
            let piece = SKShapeNode(rectOf: CGSize(width:18,height:18), cornerRadius:4)
            piece.position=CGPoint(x:startX+CGFloat(i-1)*27,y:size.height*0.665)
            piece.fillColor=SaveManager.shared.hasPuzzlePiece(i) ? Palette.amber : Palette.panel
            piece.strokeColor=SaveManager.shared.hasPuzzlePiece(i) ? Palette.amber : Palette.textFaint
            piece.lineWidth=1.2; piece.zPosition=20; addChild(piece)
        }
    }

    private func buildLevels() {
        levelNodes.removeAll()
        let trials = Trial.storyOrder.filter { $0.act == act }
        let positions:[CGPoint] = [
            CGPoint(x:size.width*0.18,y:size.height*0.57), CGPoint(x:size.width*0.39,y:size.height*0.57),
            CGPoint(x:size.width*0.61,y:size.height*0.57), CGPoint(x:size.width*0.82,y:size.height*0.57),
            CGPoint(x:size.width*0.18,y:size.height*0.40), CGPoint(x:size.width*0.39,y:size.height*0.40),
            CGPoint(x:size.width*0.61,y:size.height*0.40), CGPoint(x:size.width*0.82,y:size.height*0.40)
        ]

        for (index,trial) in trials.enumerated() where index < positions.count {
            addTrialCard(trial, at: positions[index], accent: act % 2 == 0 ? Palette.blood : Palette.cyan)
        }

        let piece = [1:1,2:2,3:3,4:4,5:5][act]!
        let rewardText = SaveManager.shared.hasPuzzlePiece(piece)
            ? "ФРАГМЕНТ ПАЗЛА \(piece)/5 ПОЛУЧЕН"
            : "ФРАГМЕНТ ПАЗЛА \(piece)/5 — ЗА ФИНАЛ АКТА"
        let progress = SKLabelNode(text: rewardText)
        progress.fontName="AvenirNext-Medium"; progress.fontSize=9; progress.fontColor=Palette.textFaint
        progress.position=CGPoint(x:size.width/2,y:12); progress.zPosition=20; addChild(progress)
    }

    private func isUnlocked(_ trial: Trial) -> Bool {
        let n = trial.displayNumber
        if n == 1 { return true }
        guard let previous = Trial.storyOrder.first(where: { $0.displayNumber == n - 1 }) else { return false }
        return SaveManager.shared.data.completedTrials.contains(previous.rawValue)
    }

    private func addTrialCard(_ trial:Trial, at position:CGPoint, accent:SKColor) {
        let completed=SaveManager.shared.data.completedTrials.contains(trial.rawValue)
        let unlocked=isUnlocked(trial)
        let node=SKShapeNode(rectOf:CGSize(width:size.width*0.19,height:62),cornerRadius:12)
        node.position=position; node.name="level_\(trial.rawValue)"
        node.fillColor=unlocked ? Palette.panel : SKColor(white:0.025,alpha:1)
        node.strokeColor=completed ? Palette.amber : (unlocked ? accent : Palette.textFaint)
        node.lineWidth=completed ? 2.5 : 1.3; node.glowWidth=completed ? 7 : 0; node.zPosition=5

        let number=SKLabelNode(text:unlocked || completed ? String(format:"%02d",trial.displayNumber) : "🔒")
        number.fontName="AvenirNext-Heavy"; number.fontSize=21; number.fontColor=completed ? Palette.amber : Palette.text
        number.position=CGPoint(x:0,y:9); number.verticalAlignmentMode = .center; number.name=node.name; node.addChild(number)

        let label=SKLabelNode(text:unlocked || completed ? trial.title.uppercased() : "ЗАКРЫТО")
        label.fontName="AvenirNext-Bold"; label.fontSize=7.5; label.fontColor=Palette.textDim
        label.position=CGPoint(x:0,y:-16); label.verticalAlignmentMode = .center; label.name=node.name; node.addChild(label)
        addChild(node); levelNodes.append(node)
    }

    private func buildBackButton() {
        let back=SKLabelNode(text:"← МЕНЮ"); back.fontName="AvenirNext-Bold"; back.fontSize=16; back.fontColor=Palette.text
        back.name="back"; back.position=CGPoint(x:58,y:34); back.zPosition=30; addChild(back)

        if act > 1 {
            let prev=SKLabelNode(text:"← АКТ \(act-1)")
            prev.fontName="AvenirNext-Bold"; prev.fontSize=14; prev.fontColor=Palette.cyan
            prev.name="prevAct"; prev.position=CGPoint(x:size.width-98,y:34); prev.zPosition=30; addChild(prev)
        }
        if act < 5 {
            let next=SKLabelNode(text:"АКТ \(act+1) →")
            next.fontName="AvenirNext-Bold"; next.fontSize=14; next.fontColor=Palette.blood
            next.name="nextAct"; next.position=CGPoint(x:size.width-70,y:34); next.zPosition=30; addChild(next)
        }
    }

    override func touchesEnded(_ touches:Set<UITouch>,with event:UIEvent?) {
        guard let point=touches.first?.location(in:self) else{return}
        var node:SKNode?=atPoint(point)
        while let current=node {
            if current.name=="back" { let s=MenuScene(size:size); s.scaleMode=scaleMode; view?.presentScene(s,transition:.fade(withDuration:0.25)); return }
            if current.name=="prevAct" { let s=HubScene(size:size,act:act-1); s.scaleMode=scaleMode; view?.presentScene(s,transition:.fade(withDuration:0.25)); return }
            if current.name=="nextAct" { let s=HubScene(size:size,act:act+1); s.scaleMode=scaleMode; view?.presentScene(s,transition:.fade(withDuration:0.25)); return }
            if let name=current.name,name.hasPrefix("level_"),let raw=Int(name.dropFirst(6)),let trial=Trial(rawValue:raw) {
                if isUnlocked(trial) { launch(trial) } else { Audio.shared.tone(freq:120,duration:0.15,volume:0.15,type:.square); Haptics.error() }
                return
            }
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
