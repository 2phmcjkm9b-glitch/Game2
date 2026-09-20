import UIKit
import SpriteKit

final class GameViewController: UIViewController {
    private var didCreateScene = false

    override func loadView() {
        let sk = SKView(frame: UIScreen.main.bounds)
        sk.backgroundColor = .black
        sk.ignoresSiblingOrder = true
        sk.isMultipleTouchEnabled = false
        view = sk
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        createSceneIfNeeded()
    }

    private func createSceneIfNeeded() {
        guard !didCreateScene,
              let skView = view as? SKView,
              skView.bounds.width > 1,
              skView.bounds.height > 1 else { return }

        didCreateScene = true

        let scene = MenuScene(size: skView.bounds.size)
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }

    override var prefersStatusBarHidden: Bool { true }
    override var prefersHomeIndicatorAutoHidden: Bool { true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
}
