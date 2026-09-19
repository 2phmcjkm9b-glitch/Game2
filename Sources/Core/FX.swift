import SpriteKit
import UIKit

enum FX {
    static func flash(on scene: SKScene, color: SKColor, duration: TimeInterval = 0.18) {
        let n = SKSpriteNode(color: color, size: scene.size)
        n.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        n.alpha = 0
        n.zPosition = 9999
        scene.addChild(n)
        n.run(.sequence([
            .fadeAlpha(to: 0.55, duration: duration * 0.3),
            .fadeOut(withDuration: duration * 0.7),
            .removeFromParent()
        ]))
    }

    static func shake(_ node: SKNode, intensity: CGFloat = 8, duration: TimeInterval = 0.25) {
        let count = max(1, Int(duration / 0.04))
        let action = SKAction.run { [weak node] in
            guard let n = node else { return }
            n.run(.moveBy(x: .random(in: -intensity...intensity),
                          y: .random(in: -intensity...intensity), duration: 0.02))
        }
        node.run(.repeat(action, count: count))
    }

    static func dust(in scene: SKScene, count: Int = 40) {
        for _ in 0..<count {
            let p = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.6...1.6))
            p.fillColor = SKColor(white: 1, alpha: 0.25)
            p.strokeColor = .clear
            p.position = CGPoint(x: .random(in: 0...scene.size.width),
                                 y: .random(in: 0...scene.size.height))
            p.zPosition = 500
            scene.addChild(p)
            let dur = TimeInterval.random(in: 6...14)
            p.run(.repeatForever(.sequence([
                .group([
                    .moveBy(x: .random(in: -30...30), y: .random(in: 40...120), duration: dur),
                    .fadeAlpha(to: 0, duration: dur)
                ]),
                .run {
                    p.position = CGPoint(x: .random(in: 0...scene.size.width), y: -10)
                    p.alpha = 0.25
                }
            ])))
        }
    }

    static func vignette(size: CGSize, intensity: CGFloat = 0.7) -> SKSpriteNode {
        let n = VignetteNode(size: size, intensity: intensity)
        return n
    }

    static func pulse(_ node: SKNode, scale: CGFloat = 1.06, duration: TimeInterval = 1.2) {
        node.run(.repeatForever(.sequence([
            .scale(to: scale, duration: duration),
            .scale(to: 1, duration: duration)
        ])))
    }
}

enum VignetteTexture {
    static func make(size: CGSize, intensity: CGFloat) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            let cg = ctx.cgContext
            let colors = [
                UIColor.clear.cgColor,
                UIColor.black.withAlphaComponent(intensity).cgColor
            ] as CFArray
            let locations: [CGFloat] = [0.45, 1.0]
            guard let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                        colors: colors, locations: locations) else { return }
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            cg.drawRadialGradient(grad, startCenter: center, startRadius: 0,
                                  endCenter: center,
                                  endRadius: max(size.width, size.height) * 0.75,
                                  options: [])
        }
        return SKTexture(image: img)
    }
}
