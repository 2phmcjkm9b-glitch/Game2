import SpriteKit
final class EndingScene: SKScene {
 override func didMove(to view: SKView) { backgroundColor=Palette.bgDeep; let n=SKLabelNode(text:"КОНЕЦ"); n.fontColor=Palette.text; n.fontSize=30; n.position=CGPoint(x:size.width/2,y:size.height/2); addChild(n) }
}