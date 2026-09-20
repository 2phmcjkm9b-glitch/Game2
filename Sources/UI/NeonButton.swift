import SpriteKit

final class NeonButton: SKShapeNode {
    private let label: SKLabelNode
    private let glowColor: SKColor
    var action: (() -> Void)?
    private(set) var isEnabled = true

    init(title: String, size: CGSize, color: SKColor = Palette.cyan) {
        label = SKLabelNode(text: title)
        glowColor = color
        super.init(rectOf: size, cornerRadius: 14)
        fillColor = SKColor(white: 0.06, alpha: 0.92)
        strokeColor = color
        lineWidth = 2
        glowWidth = 6
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

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setEnabled(_ on: Bool, dimmedColor: SKColor = Palette.textDim) {
        isEnabled = on
        strokeColor = on ? glowColor : dimmedColor
        glowWidth = on ? 6 : 0
        label.fontColor = on ? Palette.text : dimmedColor
        alpha = on ? 1 : 0.6
    }
}
