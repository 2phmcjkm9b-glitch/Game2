import UIKit
import SpriteKit

final class GameViewController: UIViewController {
    override func loadView() {
        let sk = SKView(frame: UIScreen.main.bounds)
        sk.ignoresSiblingOrder = true
        sk.preferredFramesPerSecond = 60
        sk.isMultipleTouchEnabled = true
        view = sk
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let sk = view as? SKView else { return }
        let scene = MenuScene(size: sk.bounds.size)
        scene.scaleMode = .resizeFill
        sk.presentScene(scene)
    }

    override var prefersStatusBarHidden: Bool { true }
    override var prefersHomeIndicatorAutoHidden: Bool { true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
}
