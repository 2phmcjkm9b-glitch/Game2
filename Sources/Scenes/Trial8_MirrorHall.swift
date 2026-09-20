import SpriteKit

class ActTwoTrialBase: SKScene {
    let trial: Trial
    private var startTime = Date()
    init(size: CGSize, trial: Trial) { self.trial=trial; super.init(size:size) }
    required init?(coder:NSCoder){ fatalError() }
    override func didMove(to view: SKView) {
        backgroundColor=Palette.bgDeep; startTime=Date(); Audio.shared.start()
        Audio.shared.drone(freq:38,duration:2.0,volume:0.11)
        let title=SKLabelNode(text:"\(trial.rawValue). \(trial.title.uppercased())"); title.fontName="AvenirNext-Heavy"; title.fontSize=23; title.fontColor=Palette.blood; title.position=CGPoint(x:size.width/2,y:size.height*0.82); addChild(title)
        let hint=SKLabelNode(text:trial.subtitle); hint.fontName="AvenirNext-Regular"; hint.fontSize=14; hint.fontColor=Palette.textDim; hint.position=CGPoint(x:size.width/2,y:size.height*0.75); addChild(hint)
        let task=SKShapeNode(rectOf:CGSize(width:size.width*0.78,height:180),cornerRadius:18); task.position=CGPoint(x:size.width/2,y:size.height*0.48); task.fillColor=SKColor(white:0.05,alpha:1); task.strokeColor=Palette.blood; task.lineWidth=2; task.name="task"; addChild(task)
        let instruction=SKLabelNode(text:instructionText); instruction.fontName="AvenirNext-Bold"; instruction.fontSize=15; instruction.fontColor=Palette.text; instruction.position=CGPoint(x:0,y:20); instruction.name="instruction"; task.addChild(instruction)
        let action=SKLabelNode(text:"ВЫПОЛНИТЬ"); action.fontName="AvenirNext-Bold"; action.fontSize=18; action.fontColor=Palette.cyan; action.position=CGPoint(x:0,y:-40); action.name="action"; task.addChild(action)
        let back=SKShapeNode(rectOf:CGSize(width:120,height:42),cornerRadius:10); back.position=CGPoint(x:70,y:35); back.fillColor=SKColor(white:0.06,alpha:1); back.strokeColor=Palette.textDim; back.name="backButton"; let bl=SKLabelNode(text:"← НАЗАД"); bl.fontName="AvenirNext-Bold"; bl.fontSize=13; bl.fontColor=Palette.text; bl.verticalAlignmentMode=.center; back.addChild(bl); addChild(back)
    }
    var instructionText:String { switch trial { case .mirrorHall:return "Найди отражение, которое отличается."; case .candles:return "Погаси все свечи."; case .whispers:return "Собери правильное слово."; case .shadows:return "Найди лишнюю тень."; case .clock:return "Заметь, что изменилось."; case .rhyme:return "Восстанови пропущенную строку."; case .lastDesk:return "Реши и подпиши тетрадь."; default:return "Продолжай." } }
    override func touchesEnded(_ touches:Set<UITouch>,with event:UIEvent?) {
        guard let p=touches.first?.location(in:self) else{return}
        var c:SKNode?=atPoint(p)
        while let n=c {
            if n.name=="backButton" { back(); return }
            if n.name=="action" || n.name=="task" { complete(); return }
            c=n.parent
        }
    }
    private func complete() {
        Audio.shared.tone(freq:660,duration:0.18,volume:0.2); FX.flash(on:self,color:Palette.cyan,duration:0.2)
        GameFlow.completeAndReturn(self,trial:trial,time:Date().timeIntervalSince(startTime),delay:0.9)
    }
    private func back(){ let h=HubScene(size:size,act:2); h.scaleMode=scaleMode; view?.presentScene(h,transition:.fade(withDuration:0.25)) }
}

final class Trial8_MirrorHall: ActTwoTrialBase {
    init(size: CGSize) { super.init(size:size, trial:.mirrorHall) }
    required init?(coder:NSCoder){ fatalError() }
}
