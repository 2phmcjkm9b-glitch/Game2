import SpriteKit

final class HubScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = Palette.bg
        let title = SKLabelNode(text: "ИСПЫТАНИЯ")
        title.fontName = "AvenirNext-Bold"
        title.fontSize = 30
        title.fontColor = Palette.text
        title.position = CGPoint(x: size.width/2, y: size.height*0.84)
        addChild(title)

        for trial in Trial.allCases {
            let button = NeonButton(title: "\(trial.rawValue). \(trial.title)",
                                    size: CGSize(width: min(size.width-48, 330), height: 48),
                                    color: trial.rawValue == 7 ? Palette.magenta : Palette.cyan)
            button.position = CGPoint(x: size.width/2,
                                      y: size.height*0.75 - CGFloat(trial.rawValue-1)*58)
            button.setEnabled(trial.rawValue == 1 || SaveManager.shared.data.completedTrials.contains(trial.rawValue))
            addChild(button)
        }
        addChild(FX.vignette(size: size))
    }
}
