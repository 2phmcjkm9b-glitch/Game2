import Foundation

enum Trial: Int, CaseIterable {
    case mirror = 1, melody = 2, darkCorridor = 3, doors = 4, dontLookAway = 5, notes = 6, finalChoice = 7
    case mirrorHall = 8, candles = 9, whispers = 10, shadows = 11, clock = 12, rhyme = 13, lastDesk = 14

    var act: Int { rawValue <= 7 ? 1 : 2 }

    var title: String {
        switch self {
        case .mirror: return "Зеркало"; case .melody: return "Мелодия"; case .darkCorridor: return "Тёмный коридор"
        case .doors: return "Двери"; case .dontLookAway: return "Не отводи взгляд"; case .notes: return "Записки"; case .finalChoice: return "Последний выбор"
        case .mirrorHall: return "Зеркальный коридор"; case .candles: return "Свечи"; case .whispers: return "Шёпот"; case .shadows: return "Тени на стене"
        case .clock: return "Часы"; case .rhyme: return "Считалка"; case .lastDesk: return "Последняя парта"
        }
    }

    var subtitle: String {
        switch self {
        case .mirror: return "Найди то, чего нет"; case .melody: return "Повтори то, что слышишь"; case .darkCorridor: return "Пройди по памяти"
        case .doors: return "Выбери верную"; case .dontLookAway: return "Смотри. Не мигай."; case .notes: return "Собери 5 обрывков"; case .finalChoice: return "Реши свою судьбу"
        case .mirrorHall: return "Одно отражение лжёт"; case .candles: return "Погаси все"; case .whispers: return "Собери слово"; case .shadows: return "Найди лишнюю тень"
        case .clock: return "Заметь изменения"; case .rhyme: return "Восстанови считалку"; case .lastDesk: return "Реши и подпиши"
        }
    }

    static var actOne: [Trial] { allCases.filter { $0.act == 1 } }
    static var actTwo: [Trial] { allCases.filter { $0.act == 2 } }
}
