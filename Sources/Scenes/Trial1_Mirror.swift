import SpriteKit
final class Trial1_Mirror: SKScene {
    override func didMove(to view: SKView) { backgroundColor = Palette.bg; addChild(titleNode("Испытание 1 — Зеркало")) }
    private func titleNode(_ text: String) -> SKLabelNode { let n=SKLabelNode(text:text); n.fontColor=Palette.text; n.fontSize=24; n.position=CGPoint(x:size.width/2,y:size.height/2); return n }
}
