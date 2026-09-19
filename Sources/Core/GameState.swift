import Foundation

enum Trial: Int, CaseIterable {
    case mirror = 1
    case melody = 2
    case darkCorridor = 3
    case doors = 4
    case dontLookAway = 5
    case notes = 6
    case finalChoice = 7

    var title: String {
        switch self {
        case .mirror: return "Зеркало"
        case .melody: return "Мелодия"
        case .darkCorridor: return "Тёмный коридор"
        case .doors: return "Двери"
        case .dontLookAway: return "Не отводи взгляд"
        case .notes: return "Записки"
        case .finalChoice: return "Последний выбор"
        }
    }

    var subtitle: String {
        switch self {
        case .mirror: return "Найди то, чего нет"
        case .melody: return "Повтори то, что слышишь"
        case .darkCorridor: return "Пройди по памяти"
        case .doors: return "Выбери верную"
        case .dontLookAway: return "Смотри. Не мигай."
        case .notes: return "Собери 5 обрывков"
        case .finalChoice: return "Реши свою судьбу"
        }
    }
}
