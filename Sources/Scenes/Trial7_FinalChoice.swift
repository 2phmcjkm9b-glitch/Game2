import SpriteKit
final class Trial7_FinalChoice: SKScene {
 override func didMove(to view: SKView) { backgroundColor=Palette.bgDeep; let n=SKLabelNode(text:"Испытание 7 — Последний выбор"); n.fontColor=Palette.text; n.fontSize=21; n.position=CGPoint(x:size.width/2,y:size.height/2); addChild(n) }
}