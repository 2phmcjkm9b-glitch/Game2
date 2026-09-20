import UIKit
import SpriteKit

final class GameViewController: UIViewController {
    override func loadView() {
        let sk = SKView(frame: .zero)
        sk.ignoresSiblingOrder = true
        sk.preferredFramesPerSecond = 60
        sk.isMultipleTouchEnabled = true
        view = sk
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let skView = view as? SKView else { return }
        guard skView.bounds.width > 1, skView.bounds.height > 1 else { return }
        guard skView.scene == nil else { return }

        let scene = MenuScene(size: skView.bounds.size)
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }

    override var prefersStatusBarHidden: Bool { true }
    override var prefersHomeIndicatorAutoHidden: Bool { true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
}
