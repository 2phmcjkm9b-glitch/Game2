import SpriteKit

final class HundredLevelsScene: SKScene {
    override func didMove(to view: SKView) {
        removeAllChildren()
        backgroundColor = Palette.bgDeep
        FX.atmosphere(in:self,accent:Palette.blood)
        FX.scanline(in:self,color:Palette.blood)

        let top=SKLabelNode(text:"АРХИВ • 6 ИСПЫТАНИЙ")
        top.fontName="AvenirNext-Bold"; top.fontSize=11; top.fontColor=Palette.textDim
        top.position=CGPoint(x:size.width/2,y:size.height*0.90); addChild(top)

        let title=SKLabelNode(text:"ИЗБРАННЫЕ ИСПЫТАНИЯ")
        title.fontName="AvenirNext-Heavy"; title.fontSize=25; title.fontColor=Palette.blood
        title.position=CGPoint(x:size.width/2,y:size.height*0.82); addChild(title)

        let levels=Levels.archive
        for (i,level) in levels.enumerated() {
            let col=i % 2
            let row=i / 2
            let x=col == 0 ? size.width*0.29 : size.width*0.71
            let y=size.height*0.66-CGFloat(row)*72
            let card=SKShapeNode(rectOf:CGSize(width:size.width*0.40,height:58),cornerRadius:12)
            card.position=CGPoint(x:x,y:y); card.fillColor=Palette.panel
            card.strokeColor=level.id == 97 ? Palette.magenta : Palette.cyanSoft
            card.lineWidth=1.5; card.name="level_(level.id)"; card.zPosition=10
            let num=SKLabelNode(text:String(format:"%02d",level.id))
            num.fontName="AvenirNext-Heavy"; num.fontSize=18; num.fontColor=Palette.blood
            num.horizontalAlignmentMode=.left; num.verticalAlignmentMode=.center
            num.position=CGPoint(x:-card.frame.width/2+12,y:0); num.name=card.name; card.addChild(num)
            let name=SKLabelNode(text:level.title.uppercased())
            name.fontName="AvenirNext-Bold"; name.fontSize=9; name.fontColor=Palette.text
            name.horizontalAlignmentMode=.left; name.verticalAlignmentMode=.center
            name.position=CGPoint(x:-card.frame.width/2+50,y:0); name.name=card.name; card.addChild(name)
            addChild(card)
        }

        let back=button("← НАЗАД",x:70,y:35,name:"back")
        addChild(back)
        addChild(FX.vignette(size:size,intensity:0.70))
    }

    private func button(_ text:String,x:CGFloat,y:CGFloat,name:String)->SKShapeNode {
        let b=SKShapeNode(rectOf:CGSize(width:120,height:42),cornerRadius:10)
        b.position=CGPoint(x:x,y:y); b.fillColor=Palette.panel; b.strokeColor=Palette.textDim; b.name=name; b.zPosition=30
        let l=SKLabelNode(text:text); l.fontName="AvenirNext-Bold"; l.fontSize=13; l.fontColor=Palette.text
        l.verticalAlignmentMode=.center; l.name=name; b.addChild(l)
        return b
    }

    override func touchesEnded(_ touches:Set<UITouch>,with event:UIEvent?) {
        guard let p=touches.first?.location(in:self) else{return}
        var n:SKNode?=atPoint(p)
        while let node=n {
            if node.name=="back" {
                let s=MenuScene(size:size); s.scaleMode=scaleMode
                view?.presentScene(s,transition:.fade(withDuration:0.25)); return
            }
            if let name=node.name,name.hasPrefix("level_"),let id=Int(name.dropFirst(6)),
               let level=Levels.archive.first(where:{$0.id==id}) {
                let s=HundredTrialScene(size:size,level:level); s.scaleMode=scaleMode
                view?.presentScene(s,transition:.fade(withDuration:0.25)); return
            }
            n=node.parent
        }
    }
}
