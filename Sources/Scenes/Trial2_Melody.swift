import SpriteKit
final class Trial2_Melody: SKScene {
    override func didMove(to view: SKView) { backgroundColor = Palette.bg; let n=SKLabelNode(text:"Испытание 2 — Мелодия"); n.fontColor=Palette.text; n.fontSize=24; n.position=CGPoint(x:size.width/2,y:size.height/2); addChild(n) }
}
