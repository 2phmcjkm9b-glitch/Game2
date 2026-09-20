import SpriteKit

enum GameFlow {
    static func completeAndReturn(_ scene: SKScene, trial: Trial, time: Double? = nil, delay: TimeInterval = 1.2) {
        SaveManager.shared.complete(trial.rawValue, time: time)
        Haptics.success()
        Audio.shared.tone(freq: 1320, duration: 0.25, volume: 0.25)
        if trial == .finalChoice && SaveManager.shared.data.actTwoUnlocked && !UserDefaults.standard.bool(forKey: "school13.actTwoAnnounced") {
            UserDefaults.standard.set(true, forKey: "school13.actTwoAnnounced")
            showActTwoBanner(in: scene)
            return
        }
        scene.run(.sequence([
            .wait(forDuration: delay),
            .run {
                let hub = HubScene(size: scene.size, act: trial.act)
                hub.scaleMode = scene.scaleMode
                scene.view?.presentScene(hub, transition: .fade(withDuration: 0.5))
            }
        ]))
    }

    private static func showActTwoBanner(in scene: SKScene) {
        let overlay = SKNode(); overlay.zPosition = 20000
        let dim = SKSpriteNode(color: .black, size: scene.size); dim.alpha = 0; dim.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2); overlay.addChild(dim)
        let title = SKLabelNode(text: "АКТ II"); title.fontName = "AvenirNext-Heavy"; title.fontSize = 42; title.fontColor = Palette.blood; title.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2 + 20); title.alpha = 0; overlay.addChild(title)
        let sub = SKLabelNode(text: "Школа проснулась"); sub.fontName = "AvenirNext-Medium"; sub.fontSize = 20; sub.fontColor = Palette.textDim; sub.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2 - 30); sub.alpha = 0; overlay.addChild(sub)
        scene.addChild(overlay)
        FX.shake(overlay, intensity: 14, duration: 0.8)
        Audio.shared.tone(freq: 80, duration: 1.2, volume: 0.35, type: .noise)
        overlay.run(.sequence([
            .run { dim.run(.fadeAlpha(to: 0.85, duration: 0.6)) }, .wait(forDuration: 0.5),
            .run { title.run(.fadeIn(withDuration: 0.6)) }, .wait(forDuration: 0.4),
            .run { sub.run(.fadeIn(withDuration: 0.5)) }, .wait(forDuration: 2.2),
            .run { let hub = HubScene(size: scene.size, act: 2); hub.scaleMode = scene.scaleMode; scene.view?.presentScene(hub, transition: .fade(withDuration: 0.8)) }
        ]))
    }
}
