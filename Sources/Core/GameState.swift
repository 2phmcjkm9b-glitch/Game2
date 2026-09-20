import Foundation

enum Trial: Int, CaseIterable {
    case mirror = 1
    case melody = 2
    case darkCorridor = 3
    case doors = 4
    case dontLookAway = 5
    case notes = 6
    case finalChoice = 7
    case whisper = 8
    case classroom = 9
    case clock = 10
    case shadow = 11
    case locker = 12
    case footsteps = 13
    case lastBell = 14

    var title: String {
        switch self {
        case .mirror: return "Зеркало"
        case .melody: return "Мелодия"
        case .darkCorridor: return "Тёмный коридор"
        case .doors: return "Двери"
        case .dontLookAway: return "Не отводи взгляд"
        case .notes: return "Записки"
        case .finalChoice: return "Последний выбор"
        case .whisper: return "Шёпот"
        case .classroom: return "Пустой класс"
        case .clock: return "Остановившиеся часы"
        case .shadow: return "Чужая тень"
        case .locker: return "Шкафчик №13"
        case .footsteps: return "Шаги за спиной"
        case .lastBell: return "Последний звонок"
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
        case .whisper: return "Услышь имя в тишине"
        case .classroom: return "Найди лишний предмет"
        case .clock: return "Верни время назад"
        case .shadow: return "Не дай ей приблизиться"
        case .locker: return "Открой замок до звонка"
        case .footsteps: return "Не оборачивайся"
        case .lastBell: return "Дойди до конца"
        }
    }
}
