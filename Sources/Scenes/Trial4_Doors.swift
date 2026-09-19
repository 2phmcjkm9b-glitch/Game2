import SpriteKit
final class Trial4_Doors: SKScene {
    override func didMove(to view: SKView) { backgroundColor = Palette.bg; let n=SKLabelNode(text:"Испытание 4 — Двери"); n.fontColor=Palette.text; n.fontSize=24; n.position=CGPoint(x:size.width/2,y:size.height/2); addChild(n) }
}
