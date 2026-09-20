import SpriteKit

final class MenuScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = Palette.bg
        let title=SKLabelNode(text:"ШКОЛА №13"); title.fontName="AvenirNext-Bold"; title.fontSize=42; title.fontColor=Palette.cyan; title.position=CGPoint(x:size.width/2,y:size.height*0.68); addChild(title)
        let start=SKLabelNode(text:"НАЧАТЬ"); start.fontName="AvenirNext-Bold"; start.fontSize=28; start.fontColor=.white; start.name="startButton"; start.position=CGPoint(x:size.width/2,y:size.height*0.45); addChild(start)
    }
    override func touchesEnded(_ touches:Set<UITouch>,with event:UIEvent?) {
        guard let p=touches.first?.location(in:self) else{return}
        if nodes(at:p).contains(where:{ n in var c:SKNode?=n; while let x=c { if x.name=="startButton"{return true}; c=x.parent }; return false }) {
            let h=HubScene(size:size,act:1); h.scaleMode=scaleMode; view?.presentScene(h,transition:.fade(withDuration:0.3))
        }
    }
}
