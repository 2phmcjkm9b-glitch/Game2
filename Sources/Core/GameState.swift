import Foundation

enum Trial: Int, CaseIterable {
    case mirror = 1, melody = 2, darkCorridor = 3, doors = 4, dontLookAway = 5, notes = 6, finalChoice = 7
    case mirrorHall = 8, candles = 9, whispers = 10, shadows = 11, clock = 12, rhyme = 13, lastDesk = 14
    case director = 15, stairs = 16, bell = 17, classZero = 18, notebook = 19, schoolBell = 20, lastDoor = 21

    var act: Int { rawValue <= 7 ? 1 : (rawValue <= 14 ? 2 : 3) }

    var title: String {
        switch self {
        case .mirror: return "Зеркало"; case .melody: return "Мелодия"; case .darkCorridor: return "Тёмный коридор"
        case .doors: return "Двери"; case .dontLookAway: return "Не отводи взгляд"; case .notes: return "Записки"; case .finalChoice: return "Последний выбор"
        case .mirrorHall: return "Зеркальный коридор"; case .candles: return "Свечи"; case .whispers: return "Шёпот"; case .shadows: return "Тени на стене"
        case .clock: return "Часы"; case .rhyme: return "Считалка"; case .lastDesk: return "Последняя парта"
        case .director: return "Кабинет директора"; case .stairs: return "Лестница"; case .bell: return "Колокол"
        case .classZero: return "Класс 0"; case .notebook: return "Тетрадь"; case .schoolBell: return "Последний звонок"; case .lastDoor: return "Последняя дверь"
        }
    }

    var subtitle: String {
        switch self {
        case .mirror: return "Найди то, чего нет"; case .melody: return "Повтори то, что слышишь"; case .darkCorridor: return "Пройди по памяти"
        case .doors: return "Выбери верную"; case .dontLookAway: return "Смотри. Не мигай."; case .notes: return "Собери 5 обрывков"; case .finalChoice: return "Реши свою судьбу"
        case .mirrorHall: return "Одно отражение лжёт"; case .candles: return "Погаси все"; case .whispers: return "Собери слово"; case .shadows: return "Найди лишнюю тень"
        case .clock: return "Заметь изменения"; case .rhyme: return "Восстанови считалку"; case .lastDesk: return "Реши и подпиши"
        case .director: return "Введи код, который оставил директор"; case .stairs: return "Найди безопасный путь вниз"; case .bell: return "Повтори звон колокола"
        case .classZero: return "Найди предмет, которого не должно быть"; case .notebook: return "Запомни порядок знаков"; case .schoolBell: return "Останови время на 13:13"; case .lastDoor: return "Выбери, чем закончится школа"
        }
    }

    static var actOne: [Trial] { allCases.filter { $0.act == 1 } }
    static var actTwo: [Trial] { allCases.filter { $0.act == 2 } }
    static var actThree: [Trial] { allCases.filter { $0.act == 3 } }
}
