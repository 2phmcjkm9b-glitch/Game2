import SpriteKit

enum GameFlow {
    static func completeAndReturn(_ scene: SKScene, trial: Trial, time: Double? = nil, delay: TimeInterval = 1.2) {
        SaveManager.shared.complete(trial.rawValue, time: time)
        Haptics.success()
        Audio.shared.tone(freq: 1320, duration: 0.25, volume: 0.25)

        if let piece = trial.puzzlePiece {
            SaveManager.shared.collectPuzzlePiece(piece)
            showPuzzlePieceReward(in: scene, piece: piece, trial: trial)
            return
        }

        returnToHub(scene, trial: trial, delay: delay)
    }

    private static func returnToHub(_ scene: SKScene, trial: Trial, delay: TimeInterval) {
        scene.run(.sequence([
            .wait(forDuration: delay),
            .run {
                let hub = HubScene(size: scene.size, act: trial.act)
                hub.scaleMode = scene.scaleMode
                scene.view?.presentScene(hub, transition: .fade(withDuration: 0.5))
            }
        ]))
    }

    private static func showPuzzlePieceReward(in scene: SKScene, piece: Int, trial: Trial) {
        let overlay = SKNode()
        overlay.name = "puzzleReward"
        overlay.zPosition = 20000

        let dim = SKSpriteNode(color: .black, size: scene.size)
        dim.alpha = 0.88
        dim.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        overlay.addChild(dim)

        let title = SKLabelNode(text: "АКТ ЗАВЕРШЁН")
        title.fontName = "AvenirNext-Heavy"
        title.fontSize = 28
        title.fontColor = Palette.blood
        title.position = CGPoint(x: scene.size.width / 2, y: scene.size.height * 0.72)
        overlay.addChild(title)

        let sub = SKLabelNode(text: "ТЫ НАШЁЛ ФРАГМЕНТ ПАЗЛА")
        sub.fontName = "AvenirNext-Bold"
        sub.fontSize = 14
        sub.fontColor = Palette.textDim
        sub.position = CGPoint(x: scene.size.width / 2, y: scene.size.height * 0.64)
        overlay.addChild(sub)

        let board = SKShapeNode(rectOf: CGSize(width: 230, height: 230), cornerRadius: 18)
        board.position = CGPoint(x: scene.size.width / 2, y: scene.size.height * 0.47)
        board.fillColor = Palette.panel
        board.strokeColor = Palette.cyan
        board.lineWidth = 2
        board.glowWidth = 8
        overlay.addChild(board)

        // Five-piece silhouette: collected pieces glow, remaining pieces stay dark.
        for i in 1...5 {
            let col = (i - 1) % 3
            let row = (i - 1) / 3
            let w: CGFloat = 68
            let h: CGFloat = 68
            let x = CGFloat(col - 1) * 74
            let y: CGFloat = row == 0 ? 38 : -42
            let pieceNode = SKShapeNode(rectOf: CGSize(width: w, height: h), cornerRadius: 8)
            pieceNode.position = CGPoint(x: x, y: y)
            pieceNode.fillColor = i <= piece ? Palette.cyanSoft : SKColor(white: 0.05, alpha: 1)
            pieceNode.strokeColor = i <= piece ? Palette.cyan : Palette.textFaint
            pieceNode.lineWidth = 1.5
            let n = SKLabelNode(text: i <= piece ? "✦" : "?")
            n.fontName = "AvenirNext-Heavy"
            n.fontSize = 24
            n.fontColor = i <= piece ? Palette.text : Palette.textFaint
            n.verticalAlignmentMode = .center
            pieceNode.addChild(n)
            board.addChild(pieceNode)
        }

        let pieceLabel = SKLabelNode(text: "ФРАГМЕНТ \(piece) / 5")
        pieceLabel.fontName = "AvenirNext-Bold"
        pieceLabel.fontSize = 15
        pieceLabel.fontColor = Palette.amber
        pieceLabel.position = CGPoint(x: scene.size.width / 2, y: scene.size.height * 0.27)
        overlay.addChild(pieceLabel)

        let next = SKLabelNode(text: "ПРОДОЛЖИТЬ")
        next.fontName = "AvenirNext-Bold"
        next.fontSize = 16
        next.fontColor = Palette.text
        next.position = CGPoint(x: scene.size.width / 2, y: scene.size.height * 0.14)
        next.name = "continue"
        overlay.addChild(next)

        scene.addChild(overlay)
        Haptics.medium()
        Audio.shared.tone(freq: 740, duration: 0.18, volume: 0.20)
        Audio.shared.tone(freq: 1110, duration: 0.28, volume: 0.16)

        overlay.run(.sequence([
            .wait(forDuration: 0.15),
            .run { title.run(.sequence([.scale(to: 1.08, duration: 0.25), .scale(to: 1.0, duration: 0.25)])) },
            .wait(forDuration: 3.0),
            .run {
                overlay.removeFromParent()
                let hub = HubScene(size: scene.size, act: trialActForPiece(piece))
                hub.scaleMode = scene.scaleMode
                scene.view?.presentScene(hub, transition: .fade(withDuration: 0.6))
            }
        ]))
    }

    private static func trialActForPiece(_ piece: Int) -> Int {
        switch piece {
        case 1: return 1
        case 2: return 2
        case 3: return 3
        case 4: return 4
        default: return 5
        }
    }

    static func handleRewardTouch(_ scene: SKScene, point: CGPoint, trial: Trial) -> Bool {
        guard let reward = scene.childNode(withName: "puzzleReward") else { return false }
        for node in scene.nodes(at: point) {
            var current: SKNode? = node
            while let n = current {
                if n.name == "continue" {
                    reward.removeFromParent()
                    let hub = HubScene(size: scene.size, act: trial.act)
                    hub.scaleMode = scene.scaleMode
                    scene.view?.presentScene(hub, transition: .fade(withDuration: 0.6))
                    return true
                }
                current = n.parent
            }
        }
        return true
    }
}