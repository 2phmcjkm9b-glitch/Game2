import Foundation

enum Trial: Int, CaseIterable {
    case mirror = 1
    case darkCorridor = 3
    case doors = 4
    case mirrorHall = 8
    case whispers = 10
    case shadows = 11
    case rhyme = 13
    case lastDesk = 14
    case stairs = 16
    case schoolBell = 20
    case archiveMemory = 22
    case archiveMirror = 23
    case archiveWord = 24
    case archiveChoice = 25
    case archiveBranch = 26
    case archiveCount = 27
    case lastDoor = 21

    var act: Int {
        switch self {
        case .mirror, .darkCorridor, .doors, .mirrorHall, .whispers: return 1
        case .lastDesk, .stairs, .schoolBell, .archiveMemory, .archiveMirror, .archiveWord, .archiveChoice, .archiveBranch, .archiveCount, .shadows, .rhyme, .lastDoor: return 2
        }
    }

    var isInterlude: Bool { self == .lastDesk || self == .lastDoor }

    var title: String {
        switch self {
        case .mirror: return "Зеркало"
        case .darkCorridor: return "Тёмный коридор"
        case .doors: return "Двери"
        case .mirrorHall: return "Зеркальный коридор"
        case .whispers: return "Шёпот"
        case .shadows: return "Тени на стене"
        case .rhyme: return "Считалка"
        case .lastDesk: return "Последняя парта"
        case .stairs: return "Лестница"
        case .schoolBell: return "Последний звонок"
        case .archiveMemory: return "След"
        case .archiveMirror: return "Отражение"
        case .archiveWord: return "Два слова"
        case .archiveChoice: return "Три двери"
        case .archiveBranch: return "Развилка"
        case .archiveCount: return "Финальный счёт"
        case .lastDoor: return "Последняя дверь"
        }
    }

    var subtitle: String {
        switch self {
        case .mirror: return "Найди то, чего нет"
        case .darkCorridor: return "Пройди по памяти"
        case .doors: return "Выбери верную"
        case .mirrorHall: return "Одно отражение лжёт"
        case .whispers: return "Собери слово из букв"
        case .shadows: return "Найди лишнюю тень"
        case .rhyme: return "Восстанови считалку"
        case .lastDesk: return "Реши и подпиши"
        case .stairs: return "Найди безопасный путь вниз"
        case .schoolBell: return "Останови время на 13:13"
        case .archiveMemory: return "Запомни исчезающие клетки"
        case .archiveMirror: return "Найди пару среди отражений"
        case .archiveWord: return "Собери слово по порядку"
        case .archiveChoice: return "Найди единственное чётное число"
        case .archiveBranch: return "Найди единственное простое число"
        case .archiveCount: return "Посчитай все огни"
        case .lastDoor: return "Выбери, чем закончится школа"
        }
    }

    static var actOne: [Trial] { allCases.filter { $0.act == 1 && !$0.isInterlude } }
    static var actTwo: [Trial] { allCases.filter { $0.act == 2 && !$0.isInterlude } }
    static var interludes: [Trial] { [.lastDesk, .lastDoor] }
    static var actThree: [Trial] { actTwo }
}
