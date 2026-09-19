import SpriteKit
final class Trial3_DarkCorridor: SKScene {
    override func didMove(to view: SKView) { backgroundColor = Palette.bgDeep; let n=SKLabelNode(text:"Испытание 3 — Тёмный коридор"); n.fontColor=Palette.text; n.fontSize=22; n.position=CGPoint(x:size.width/2,y:size.height/2); addChild(n) }
}
