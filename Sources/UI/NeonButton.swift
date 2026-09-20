import SpriteKit

final class NeonButton: SKShapeNode {
    private let label: SKLabelNode
    private let glowColor: SKColor
    var action: (() -> Void)?
    private(set) var isEnabled = true

    init(title: String, size: CGSize, color: SKColor = Palette.cyan) {
        self.label = SKLabelNode(text: title)
        self.glowColor = color

        super.init(rectOf: size, cornerRadius: 14)

        fillColor = SKColor(white: 0.06, alpha: 0.92)
        strokeColor = color
        lineWidth = 2
        glowWidth = 6
        isUserInteractionEnabled = true
        zPosition = 100

        label.fontName = "AvenirNext-Bold"
        label.fontSize = min(size.height * 0.42, 26)
        label.fontColor = Palette.text
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.isUserInteractionEnabled = false
        addChild(label)

        run(.repeatForever(.sequence([
            .scale(to: 1.02, duration: 1.6),
            .scale(to: 1.0, duration: 1.6)
        ])))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setEnabled(_ on: Bool, dimmedColor: SKColor = Palette.textDim) {
        isEnabled = on
        strokeColor = on ? glowColor : dimmedColor
        glowWidth = on ? 6 : 0
        label.fontColor = on ? Palette.text : dimmedColor
        alpha = on ? 1 : 0.6
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isEnabled else { return }
        removeAction(forKey: "press")
        run(.sequence([
            .scale(to: 0.94, duration: 0.08),
            .run { [weak self] in self?.run(.scale(to: 1.0, duration: 0.10), withKey: "press") }
        ]))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isEnabled else { return }
        removeAction(forKey: "press")
        run(.scale(to: 1.0, duration: 0.10))
        Haptics.light()
        action?()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeAction(forKey: "press")
        run(.scale(to: 1.0, duration: 0.10))
    }
}
