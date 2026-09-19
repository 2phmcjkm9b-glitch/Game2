import SpriteKit

final class VignetteNode: SKSpriteNode {
    init(size: CGSize, intensity: CGFloat = 0.7) {
        let tex = VignetteTexture.make(size: size, intensity: intensity)
        super.init(texture: tex, color: .clear, size: size)
        position = CGPoint(x: size.width / 2, y: size.height / 2)
        zPosition = 9000
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
