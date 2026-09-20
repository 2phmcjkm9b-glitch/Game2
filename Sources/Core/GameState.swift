import Foundation

enum Trial: Int, CaseIterable {
    case mirror = 1, melody = 2, darkCorridor = 3, doors = 4, dontLookAway = 5, notes = 6, finalChoice = 7
    case mirrorHall = 8, candles = 9, whispers = 10, shadows = 11, clock = 12, rhyme = 13, lastDesk = 14
    case director = 15, stairs = 16, classZero = 18, schoolBell = 20, lastDoor = 21
    case archiveMemory = 22, archiveMirror = 23, archiveWord = 24, archiveChoice = 25, archiveBranch = 26, archiveCount = 27

    static let storyOrder: [Trial] = [.mirror,.darkCorridor,.doors,.mirrorHall,.archiveMemory,.whispers,.shadows,.archiveMirror,.rhyme,.archiveWord,.lastDesk,.stairs,.archiveChoice,.archiveBranch,.schoolBell,.archiveCount,.lastDoor]

    var displayNumber: Int { (Self.storyOrder.firstIndex(of: self) ?? 0) + 1 }

    // 17 levels are split into 5 acts: 3 / 3 / 3 / 4 / 4.
    var act: Int {
        switch displayNumber {
        case 1...3: return 1
        case 4...6: return 2
        case 7...9: return 3
        case 10...13: return 4
        default: return 5
        }
    }

    var isActFinale: Bool { [3,6,9,13,17].contains(displayNumber) }
    var puzzlePiece: Int? { isActFinale ? ([3:1,6:2,9:3,13:4,17:5][displayNumber]) : nil }

    var title: String {
        switch self {
        case .mirror: return "Зеркало"; case .melody: return "Мелодия"; case .darkCorridor: return "Тёмный коридор"
        case .doors: return "Двери"; case .dontLookAway: return "Не отводи взгляд"; case .notes: return "Записки"; case .finalChoice: return "Последний выбор"
        case .mirrorHall: return "Зеркальный коридор"; case .candles: return "Свечи"; case .whispers: return "Шёпот"; case .shadows: return "Тени на стене"
        case .clock: return "Часы"; case .rhyme: return "Считалка"; case .lastDesk: return "Последняя парта"; case .director: return "Кабинет директора"
        case .stairs: return "Лестница"; case .classZero: return "Класс 0"; case .schoolBell: return "Последний звонок"; case .lastDoor: return "Последняя дверь"
        case .archiveMemory: return "След"; case .archiveMirror: return "Отражение"; case .archiveWord: return "Два слова"
        case .archiveChoice: return "Три двери"; case .archiveBranch: return "Развилка"; case .archiveCount: return "Финальный счёт"
        }
    }

    var subtitle: String {
        switch self {
        case .mirror: return "Найди то, чего нет"; case .melody: return "Повтори то, что слышишь"; case .darkCorridor: return "Пройди по памяти"
        case .doors: return "Выбери верную"; case .dontLookAway: return "Смотри. Не мигай."; case .notes: return "Собери 5 обрывков"; case .finalChoice: return "Реши свою судьбу"
        case .mirrorHall: return "Одно отражение лжёт"; case .candles: return "Погаси все"; case .whispers: return "Собери длинное послание"; case .shadows: return "Найди лишнюю тень"
        case .clock: return "Заметь изменения"; case .rhyme: return "Продолжи закономерность"; case .lastDesk: return "Реши и подпиши"; case .director: return "Введи код, который оставил директор"
        case .stairs: return "Найди безопасный путь вниз"; case .classZero: return "Найди предмет, которого не должно быть"; case .schoolBell: return "Останови время на 13:13"; case .lastDoor: return "Выбери, чем закончится школа"
        case .archiveMemory: return "Запомни исчезающие клетки"; case .archiveMirror: return "Найди пару среди отражений"; case .archiveWord: return "Собери слово по порядку"
        case .archiveChoice: return "Найди единственное чётное число"; case .archiveBranch: return "Найди единственное простое число"; case .archiveCount: return "Посчитай все огни"
        }
    }
}