import Foundation

enum Trial: Int, CaseIterable {
    case mirror = 1
    case melody = 2
    case darkCorridor = 3
    case doors = 4
    case dontLookAway = 5
    case notes = 6
    case finalChoice = 7
    case mirrorHall = 8
    case candles = 9
    case whispers = 10
    case shadows = 11
    case clock = 12
    case rhyme = 13
    case lastDesk = 14
    case director = 15
    case stairs = 16
    case classZero = 18
    case schoolBell = 20
    case lastDoor = 21
    case archiveMemory = 22
    case archiveMirror = 23
    case archiveWord = 24
    case archiveChoice = 25
    case archiveBranch = 26
    case archiveCount = 27

    static let storyOrder: [Trial] = [
        .mirror, .darkCorridor, .doors, .mirrorHall,
        .archiveMemory, .whispers, .shadows, .archiveMirror,
        .rhyme, .archiveWord, .lastDesk,
        .stairs, .archiveChoice, .archiveBranch, .schoolBell,
        .archiveCount, .lastDoor
    ]

    var displayNumber: Int {
        (Self.storyOrder.firstIndex(of: self) ?? 0) + 1
    }

    var act: Int {
        switch self {
        case .mirror, .darkCorridor, .doors, .mirrorHall, .archiveMemory, .whispers, .shadows, .archiveMirror, .rhyme, .archiveWord:
            return 1
        case .lastDesk, .stairs, .archiveChoice, .archiveBranch, .schoolBell, .archiveCount, .lastDoor:
            return 2
        default:
            return 1
        }
    }

    var isInterlude: Bool { self == .lastDesk || self == .lastDoor }

    var title: String {
        switch self {
        case .mirror: return "Зеркало"; case .melody: return "Мелодия"; case .darkCorridor: return "Тёмный коридор"
        case .doors: return "Двери"; case .dontLookAway: return "Не отводи взгляд"; case .notes: return "Записки"; case .finalChoice: return "Последний выбор"
        case .mirrorHall: return "Зеркальный коридор"; case .candles: return "Свечи"; case .whispers: return "Шёпот"; case .shadows: return "Тени на стене"
        case .clock: return "Часы"; case .rhyme: return "Считалка"; case .lastDesk: return "Последняя парта"
        case .director: return "Кабинет директора"; case .stairs: return "Лестница"; case .classZero: return "Класс 0"
        case .schoolBell: return "Последний звонок"; case .lastDoor: return "Последняя дверь"
        case .archiveMemory: return "След"; case .archiveMirror: return "Отражение"; case .archiveWord: return "Два слова"
        case .archiveChoice: return "Три двери"; case .archiveBranch: return "Развилка"; case .archiveCount: return "Финальный счёт"
        }
    }

    var subtitle: String {
        switch self {
        case .mirror: return "Найди то, чего нет"; case .melody: return "Повтори то, что слышишь"; case .darkCorridor: return "Пройди по памяти"
        case .doors: return "Выбери верную"; case .dontLookAway: return "Смотри. Не мигай."; case .notes: return "Собери 5 обрывков"; case .finalChoice: return "Реши свою судьбу"
        case .mirrorHall: return "Одно отражение лжёт"; case .candles: return "Погаси все"; case .whispers: return "Собери длинное послание"; case .shadows: return "Найди лишнюю тень"
        case .clock: return "Заметь изменения"; case .rhyme: return "Продолжи закономерность"; case .lastDesk: return "Реши и подпиши"
        case .director: return "Введи код, который оставил директор"; case .stairs: return "Найди безопасный путь вниз"; case .classZero: return "Найди предмет, которого не должно быть"
        case .schoolBell: return "Останови время на 13:13"; case .lastDoor: return "Выбери, чем закончится школа"
        case .archiveMemory: return "Запомни исчезающие клетки"; case .archiveMirror: return "Найди пару среди отражений"; case .archiveWord: return "Собери слово по порядку"
        case .archiveChoice: return "Найди единственное чётное число"; case .archiveBranch: return "Найди единственное простое число"; case .archiveCount: return "Посчитай все огни"
        }
    }

    static var actOne: [Trial] { storyOrder.filter { $0.act == 1 } }
    static var actTwo: [Trial] { storyOrder.filter { $0.act == 2 } }
    static var interludes: [Trial] { [.lastDesk, .lastDoor] }
    static var actThree: [Trial] { actTwo }
}
