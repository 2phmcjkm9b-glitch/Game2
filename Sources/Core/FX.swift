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

    static func dust(in scene: SKScene, count: Int = 30) {
        for _ in 0..<count {
            let p = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.5...1.4))
            p.fillColor = SKColor(white: 1, alpha: 0.16)
            p.strokeColor = .clear
            p.position = CGPoint(x: .random(in: 0...scene.size.width),
                                 y: .random(in: 0...scene.size.height))
            p.zPosition = -1
            let dur = TimeInterval.random(in: 6...14)
            p.run(.repeatForever(.sequence([
                .group([
                    .moveBy(x: .random(in: -24...24), y: .random(in: 35...110), duration: dur),
                    .fadeAlpha(to: 0, duration: dur)
                ]),
                .run {
                    p.position = CGPoint(x: .random(in: 0...scene.size.width), y: -10)
                    p.alpha = 0.16
                }
            ])))
            scene.addChild(p)
        }
    }

    static func vignette(size: CGSize, intensity: CGFloat = 0.7) -> SKSpriteNode {
        return VignetteNode(size: size, intensity: intensity)
    }

    static func atmosphere(in scene: SKScene, accent: SKColor = Palette.cyan) {
        let glow = SKShapeNode(circleOfRadius: max(scene.size.width, scene.size.height) * 0.34)
        glow.position = CGPoint(x: scene.size.width * 0.50, y: scene.size.height * 0.47)
        glow.fillColor = accent.withAlphaComponent(0.025)
        glow.strokeColor = accent.withAlphaComponent(0.09)
        glow.lineWidth = 1
        glow.zPosition = -10
        scene.addChild(glow)
        glow.run(.repeatForever(.sequence([
            .group([.scale(to: 1.08, duration: 3.0), .fadeAlpha(to: 0.035, duration: 3.0)]),
            .group([.scale(to: 0.92, duration: 3.0), .fadeAlpha(to: 0.10, duration: 3.0)])
        ])))

        for i in 0..<22 {
            let line = SKShapeNode(rectOf: CGSize(width: scene.size.width, height: 1))
            line.position = CGPoint(x: scene.size.width / 2, y: CGFloat(i) * 30)
            line.fillColor = accent.withAlphaComponent(0.018)
            line.strokeColor = .clear
            line.zPosition = -5
            scene.addChild(line)
        }
        dust(in: scene, count: 22)
    }

    static func glitchTitle(_ node: SKNode) {
        node.run(.repeatForever(.sequence([
            .wait(forDuration: 2.8),
            .moveBy(x: -3, y: 0, duration: 0.025),
            .fadeAlpha(to: 0.68, duration: 0.025),
            .moveBy(x: 6, y: 0, duration: 0.025),
            .moveBy(x: -3, y: 0, duration: 0.025),
            .fadeAlpha(to: 1, duration: 0.06)
        ])))
    }

    static func successBurst(in scene: SKScene, at point: CGPoint, color: SKColor = Palette.cyan) {
        let ring = SKShapeNode(circleOfRadius: 10)
        ring.position = point
        ring.fillColor = .clear
        ring.strokeColor = color
        ring.lineWidth = 3
        ring.alpha = 0.9
        ring.zPosition = 1000
        scene.addChild(ring)
        ring.run(.group([
            .scale(to: 7, duration: 0.45),
            .fadeOut(withDuration: 0.45)
        ]), completion: { ring.removeFromParent() })
    }

    static func pulse(_ node: SKNode, scale: CGFloat = 1.04, duration: TimeInterval = 1.2) {
        node.run(.repeatForever(.sequence([
            .scale(to: scale, duration: duration),
            .scale(to: 1, duration: duration)
        ])))
    }

    static func cardGlow(_ node: SKNode, color: SKColor, radius: CGFloat = 8) {
        guard let shape = node as? SKShapeNode else { return }
        shape.glowWidth = radius
        shape.run(.repeatForever(.sequence([
            .fadeAlpha(to: 0.78, duration: 1.4),
            .fadeAlpha(to: 1.0, duration: 1.4)
        ])))
        shape.strokeColor = color
    }

    static func scanline(in scene: SKScene, color: SKColor = Palette.cyan) {
        let line = SKShapeNode(rectOf: CGSize(width: scene.size.width, height: 2))
        line.fillColor = color.withAlphaComponent(0.08)
        line.strokeColor = .clear
        line.position = CGPoint(x: scene.size.width / 2, y: scene.size.height + 5)
        line.zPosition = -2
        scene.addChild(line)
        line.run(.repeatForever(.sequence([
            .moveTo(y: -5, duration: 5.5),
            .moveTo(y: scene.size.height + 5, duration: 0.01)
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
