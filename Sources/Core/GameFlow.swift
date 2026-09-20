import SpriteKit

enum GameFlow {
    static func completeAndReturn(
        _ scene: SKScene,
        trial: Trial,
        time: Double? = nil,
        delay: TimeInterval = 1.2
    ) {
        SaveManager.shared.complete(trial.rawValue, time: time)
        Haptics.success()
        Audio.shared.tone(freq: 1320, duration: 0.25, volume: 0.25)

        scene.run(.sequence([
            .wait(forDuration: delay),
            .run {
                let hub = HubScene(size: scene.size)
                hub.scaleMode = scene.scaleMode
                scene.view?.presentScene(hub, transition: .fade(withDuration: 0.5))
            }
        ]))
    }
}
