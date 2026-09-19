import SpriteKit

final class NeonButton: SKNode {
    private let bg: SKShapeNode
    private let label: SKLabelNode
    private let glowColor: SKColor
    var action: (() -> Void)?

    init(title: String, size: CGSize, color: SKColor = Palette.cyan) {
        glowColor = color
        bg = SKShapeNode(rectOf: size, cornerRadius: 14)
        label = SKLabelNode(text: title)

        bg.fillColor = SKColor(white: 0.06, alpha: 0.9)
        bg.strokeColor = color
        bg.lineWidth = 2
        bg.glowWidth = 6

        label.fontName = "AvenirNext-Bold"
        label.fontSize = min(size.height * 0.42, 26)
        label.fontColor = Palette.text
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center

        super.init()
        isUserInteractionEnabled = true
        addChild(bg)
        addChild(label)

        run(.repeatForever(.sequence([
            .scale(to: 1.02, duration: 1.6),
            .scale(to: 1.0, duration: 1.6)
        ])))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setEnabled(_ on: Bool, dimmedColor: SKColor = Palette.textDim) {
        bg.strokeColor = on ? glowColor : dimmedColor
        bg.glowWidth = on ? 6 : 0
        label.fontColor = on ? Palette.text : dimmedColor
        alpha = on ? 1 : 0.6
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        run(.scale(to: 0.94, duration: 0.08))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        run(.scale(to: 1.0, duration: 0.10))
        Haptics.light()
        Audio.shared.tone(freq: 660, duration: 0.08, volume: 0.15)
        action?()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        run(.scale(to: 1.0, duration: 0.10))
    }
}
