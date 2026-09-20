import SpriteKit

final class HundredLevelsScene: SKScene {
    private var chapter = 1
    private var titleLabel = SKLabelNode()
    private var page = 0

    override func didMove(to view: SKView) {
        build()
    }

    private func build() {
        removeAllChildren()
        backgroundColor = Palette.bgDeep
        FX.atmosphere(in: self, accent: Palette.blood)
        FX.scanline(in: self, color: Palette.blood)

        let top = SKLabelNode(text: "АРХИВ • 100 ИСПЫТАНИЙ")
        top.fontName = "AvenirNext-Bold"; top.fontSize = 11; top.fontColor = Palette.textDim
        top.position = CGPoint(x: size.width/2, y: size.height*0.90); top.zPosition = 20; addChild(top)

        titleLabel = SKLabelNode(text: "ГЛАВА \(chapter)")
        titleLabel.fontName = "AvenirNext-Heavy"; titleLabel.fontSize = 30; titleLabel.fontColor = Palette.blood
        titleLabel.position = CGPoint(x: size.width/2, y: size.height*0.82); titleLabel.zPosition = 20; addChild(titleLabel)

        let names = ["ТИШИНА","ЭХО","ТЕНИ","ЧАСЫ","ШЁПОТ","ЛАБИРИНТ","ОБРАТНОЕ","ДВОЙНИК","СЧИТАЛКА","ПОСЛЕДНЯЯ ПАРТА"]
        let sub = SKLabelNode(text: names[chapter-1] + " • 10 УРОВНЕЙ")
        sub.fontName = "AvenirNext-Medium"; sub.fontSize = 12; sub.fontColor = Palette.textDim
        sub.position = CGPoint(x: size.width/2, y: size.height*0.77); addChild(sub)

        let levels = Levels.all.filter { $0.chapter == chapter }
        let startY = size.height * 0.66
        for (i, level) in levels.enumerated() {
            let col = i % 2
            let row = i / 2
            let x = col == 0 ? size.width*0.29 : size.width*0.71
            let y = startY - CGFloat(row)*66
            let card = SKShapeNode(rectOf: CGSize(width: size.width*0.40, height: 52), cornerRadius: 12)
            card.position = CGPoint(x:x,y:y); card.fillColor = Palette.panel; card.strokeColor = level.id == 100 ? Palette.magenta : Palette.cyanSoft
            card.lineWidth = 1.5; card.name = "level_\(level.id)"; card.zPosition = 10
            let num = SKLabelNode(text: String(format:"%02d",level.id))
            num.fontName = "AvenirNext-Heavy"; num.fontSize = 18; num.fontColor = Palette.blood
            num.horizontalAlignmentMode = .left; num.verticalAlignmentMode = .center; num.position = CGPoint(x:-card.frame.width/2+12,y:0)
            num.name = card.name; card.addChild(num)
            let name = SKLabelNode(text: level.title.uppercased())
            name.fontName = "AvenirNext-Bold"; name.fontSize = 10; name.fontColor = Palette.text
            name.horizontalAlignmentMode = .left; name.verticalAlignmentMode = .center; name.position = CGPoint(x:-card.frame.width/2+50,y:0)
            name.name = card.name; card.addChild(name)
            addChild(card)
        }

        let back = button("← НАЗАД", x: 78, y: 35, name: "back")
        back.strokeColor = Palette.textDim
        let prev = button("‹", x: size.width/2-65, y: 35, name: "prev")
        let next = button("›", x: size.width/2+65, y: 35, name: "next")
        prev.alpha = chapter == 1 ? 0.35 : 1
        next.alpha = chapter == 10 ? 0.35 : 1
        _ = page
        addChild(FX.vignette(size: size, intensity: 0.70))
    }

    private func button(_ text:String,x:CGFloat,y:CGFloat,name:String)->SKShapeNode {
        let b=SKShapeNode(rectOf:CGSize(width:110,height:40),cornerRadius:10)
        b.position=CGPoint(x:x,y:y); b.fillColor=Palette.panel; b.strokeColor=Palette.cyan; b.name=name; b.zPosition=30
        let l=SKLabelNode(text:text); l.fontName="AvenirNext-Bold"; l.fontSize=13; l.fontColor=Palette.text; l.verticalAlignmentMode = .center; l.name=name; b.addChild(l)
        return b
    }

    override func touchesEnded(_ touches:Set<UITouch>,with event:UIEvent?) {
        guard let p=touches.first?.location(in:self) else{return}
        var n:SKNode?=atPoint(p)
        while let node=n {
            guard let name=node.name else { n=node.parent; continue }
            if name=="back" { goBack(); return }
            if name=="prev" { if chapter>1 { chapter-=1; build() }; return }
            if name=="next" { if chapter<10 { chapter+=1; build() }; return }
            if name.hasPrefix("level_"), let id=Int(name.dropFirst(6)), let level=Levels.all.first(where:{$0.id==id}) {
                let s=HundredTrialScene(size:size,level:level); s.scaleMode=scaleMode
                view?.presentScene(s,transition:.fade(withDuration:0.25)); return
            }
            n=node.parent
        }
    }

    private func goBack() {
        let s=MenuScene(size:size); s.scaleMode=scaleMode
        view?.presentScene(s,transition:.fade(withDuration:0.25))
    }
}
