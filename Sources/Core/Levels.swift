import Foundation

enum Levels {
    static let all: [Level] = chapter1 + chapter2 + chapter3 + chapter4 + chapter5 + chapter6 + chapter7 + chapter8 + chapter9 + chapter10

    private static func p(_ values: [String: Double]) -> [String: Double] { values }
    private static func make(_ id: Int, _ chapter: Int, _ type: LevelType, _ title: String, _ hint: String?, _ difficulty: Int, _ params: [String: Double] = [:]) -> Level {
        Level(id: id, chapter: chapter, type: type, title: title, hint: hint, difficulty: difficulty, params: p(params))
    }

    static let chapter1: [Level] = [
        make(1,1,.findOdd,"Первый взгляд","Одна плитка — не такая",1,["cols":3,"rows":3,"time":25]),
        make(2,1,.findOdd,"Взгляд в угол",nil,1,["cols":3,"rows":4,"time":25]),
        make(3,1,.lightsOut,"Погаси свет","Тап переключает крест",2,["cols":3,"rows":3]),
        make(4,1,.findOdd,"Мелькание","Плитки дрожат",2,["cols":4,"rows":4,"time":22]),
        make(5,1,.lightsOut,"Свечи",nil,2,["cols":3,"rows":3,"preLit":3]),
        make(6,1,.sequence,"Три стука","Повтори",3,["len":3,"speed":0.7]),
        make(7,1,.findOdd,"Толпа",nil,3,["cols":5,"rows":5,"time":20]),
        make(8,1,.lightsOut,"Полутьма",nil,3,["cols":4,"rows":4,"preLit":5]),
        make(9,1,.sequence,"Пять ударов","Будь внимателен",4,["len":5,"speed":0.55]),
        make(10,1,.findOdd,"Тишина","Найди то, чего нет",4,["cols":6,"rows":5,"time":15])
    ]
    static let chapter2: [Level] = [
        make(11,2,.sequence,"Эхо I","Теперь наоборот",4,["len":4,"speed":0.6,"reverse":1]),
        make(12,2,.memoryGrid,"След","Запомни клетки",4,["cols":3,"rows":3,"cells":3,"show":1.2]),
        make(13,2,.sequence,"Эхо II",nil,5,["len":5,"speed":0.5,"reverse":1]),
        make(14,2,.memoryGrid,"Больше следов",nil,5,["cols":4,"rows":4,"cells":4,"show":1]),
        make(15,2,.findOdd,"Дрожь",nil,5,["cols":5,"rows":6,"time":18]),
        make(16,2,.sequence,"Долгое эхо",nil,6,["len":7,"speed":0.45,"reverse":1]),
        make(17,2,.memoryGrid,"Память подвалов","Клетки исчезают быстрее",6,["cols":4,"rows":4,"cells":5,"show":0.8]),
        make(18,2,.lightsOut,"Мерцание",nil,6,["cols":5,"rows":5,"preLit":7]),
        make(19,2,.sequence,"Шёпот цифр",nil,7,["len":8,"speed":0.4,"reverse":1]),
        make(20,2,.memoryGrid,"Эхо в темноте","Экран почти тёмный",7,["cols":5,"rows":5,"cells":6,"show":0.7])
    ]
    static let chapter3: [Level] = [
        make(21,3,.mirrorMatch,"Отражение","Найди пару",4,["pairs":4,"time":30]),
        make(22,3,.shadows,"Тень и предмет","Соедини",5,["items":4,"time":30]),
        make(23,3,.mirrorMatch,"Кривое зеркало",nil,5,["pairs":6,"time":28]),
        make(24,3,.shadows,"Лишняя тень","Одна не имеет пары",5,["items":5,"time":28]),
        make(25,3,.mirrorMatch,"Двойник",nil,6,["pairs":8,"time":26]),
        make(26,3,.findOdd,"Один из тени",nil,6,["cols":5,"rows":6,"time":15]),
        make(27,3,.shadows,"Тени удлиняются",nil,7,["items":6,"time":24]),
        make(28,3,.mirrorMatch,"Зеркальный зал",nil,7,["pairs":10,"time":24]),
        make(29,3,.memoryGrid,"Тени запомнились",nil,8,["cols":5,"rows":5,"cells":8,"show":0.6]),
        make(30,3,.shadows,"Зеркало разбилось","Осколки перепутались",8,["items":7,"time":22])
    ]
    static let chapter4: [Level] = [
        make(31,4,.findOdd,"Стрелки замерли","Найди, что изменилось",5,["cols":4,"rows":4,"time":20]),
        make(32,4,.sequence,"Тик-так","Повтори ритм",5,["len":4,"speed":0.5,"reverse":1]),
        make(33,4,.memoryGrid,"Застывшее время",nil,6,["cols":5,"rows":5,"cells":5,"show":0.7]),
        make(34,4,.findOdd,"Пропущенный удар",nil,6,["cols":5,"rows":6,"time":15]),
        make(35,4,.sequence,"Долгий бой",nil,7,["len":6,"speed":0.4,"reverse":1]),
        make(36,4,.lightsOut,"Часы бьют",nil,7,["cols":5,"rows":5,"preLit":8]),
        make(37,4,.findOdd,"Полночь",nil,7,["cols":6,"rows":6,"time":13]),
        make(38,4,.memoryGrid,"Часы сломались","Запомни порядок",8,["cols":5,"rows":5,"cells":7,"show":0.6]),
        make(39,4,.sequence,"Обратный отсчёт","Задом наперёд",8,["len":8,"speed":0.35,"reverse":1]),
        make(40,4,.findOdd,"Последний удар",nil,9,["cols":6,"rows":6,"time":10])
    ]
    static let chapter5: [Level] = [
        make(41,5,.wordChain,"Первое слово","Собери слово",5,["len":4]),
        make(42,5,.wordChain,"Шёпот",nil,5,["len":5]),
        make(43,5,.sequence,"Буквы поют",nil,6,["len":4,"speed":0.55]),
        make(44,5,.wordChain,"Два слова",nil,6,["len":5]),
        make(45,5,.memoryGrid,"Запомни буквы",nil,6,["cols":4,"rows":4,"cells":5]),
        make(46,5,.wordChain,"Длинное слово",nil,7,["len":7]),
        make(47,5,.wordChain,"Три слова",nil,7,["len":5]),
        make(48,5,.findOdd,"Лишняя буква",nil,7,["cols":6,"rows":6,"time":12]),
        make(49,5,.wordChain,"Шёпот в темноте",nil,8,["len":6]),
        make(50,5,.sequence,"Хор",nil,8,["len":8,"speed":0.3])
    ]
    static let chapter6: [Level] = [
        make(51,6,.choice,"Три двери","Одна ведёт дальше",5,["options":3]),
        make(52,6,.choice,"Развилка",nil,6,["options":3]),
        make(53,6,.memoryGrid,"Карта","Запомни путь",6,["cols":5,"rows":5,"cells":6]),
        make(54,6,.choice,"Четыре двери",nil,7,["options":4]),
        make(55,6,.sequence,"След в пыли",nil,7,["len":6,"speed":0.4]),
        make(56,6,.choice,"Подвал",nil,7,["options":4]),
        make(57,6,.lightsOut,"Факелы",nil,8,["cols":6,"rows":6,"preLit":10]),
        make(58,6,.choice,"Ловушка","Одна из дверей — обман",8,["options":4]),
        make(59,6,.memoryGrid,"Тёмный лабиринт",nil,9,["cols":6,"rows":6,"cells":8]),
        make(60,6,.choice,"Выход",nil,9,["options":5])
    ]
    static let chapter7: [Level] = [
        make(61,7,.reversedInput,"Зеркало входа","Управление перевёрнуто",6,["cols":4,"rows":4,"time":25]),
        make(62,7,.findOdd,"Найди правильную","Отличие — не то, что кажется",6,["cols":5,"rows":5,"time":18]),
        make(63,7,.reversedInput,"Отражённое касание",nil,7,["cols":5,"rows":5]),
        make(64,7,.lightsOut,"Наоборот","Тап переключает крест наоборот",7,["cols":4,"rows":4,"preLit":6]),
        make(65,7,.reversedInput,"Левый-правый",nil,7,["cols":5,"rows":6]),
        make(66,7,.sequence,"Обратный ритм",nil,8,["len":7,"speed":0.35,"reverse":1]),
        make(67,7,.findOdd,"Ложное отличие",nil,8,["cols":6,"rows":6,"time":14]),
        make(68,7,.reversedInput,"Кривое зеркало",nil,8,["cols":6,"rows":6]),
        make(69,7,.lightsOut,"Инверсия",nil,9,["cols":6,"rows":6,"preLit":12]),
        make(70,7,.findOdd,"Против правил",nil,9,["cols":7,"rows":7,"time":12])
    ]
    static let chapter8: [Level] = [
        make(71,8,.mirrorMatch,"Встреча",nil,6,["pairs":8,"time":28]),
        make(72,8,.choice,"Выбери себя","Один из вас — ты",7,["options":3]),
        make(73,8,.mirrorMatch,"Петля",nil,7,["pairs":10,"time":26]),
        make(74,8,.sequence,"Эхо двойника",nil,8,["len":8,"speed":0.35]),
        make(75,8,.shadows,"Две тени",nil,8,["items":7,"time":22]),
        make(76,8,.choice,"Парадокс",nil,8,["options":4]),
        make(77,8,.mirrorMatch,"Зеркальный лабиринт",nil,9,["pairs":12,"time":24]),
        make(78,8,.memoryGrid,"Память двойника",nil,9,["cols":6,"rows":6,"cells":9]),
        make(79,8,.choice,"Ловушка двойника",nil,9,["options":5]),
        make(80,8,.findOdd,"Один из двух",nil,10,["cols":7,"rows":7,"time":10])
    ]
    static let chapter9: [Level] = [
        make(81,9,.countTrap,"Посчитай","Сколько огней?",6,["objects":6,"time":10]),
        make(82,9,.countTrap,"Считалка",nil,7,["objects":8,"time":8]),
        make(83,9,.sequence,"Ритм",nil,7,["len":7,"speed":0.35]),
        make(84,9,.countTrap,"Ловушка в счёте","Один исчезает",7,["objects":9,"time":8]),
        make(85,9,.lightsOut,"Все огни",nil,8,["cols":6,"rows":6,"preLit":14]),
        make(86,9,.countTrap,"Много огней",nil,8,["objects":12,"time":6]),
        make(87,9,.memoryGrid,"Числа на стене",nil,8,["cols":5,"rows":5,"cells":8]),
        make(88,9,.countTrap,"Обратный счёт",nil,9,["objects":14,"time":5]),
        make(89,9,.sequence,"Считалка теней",nil,9,["len":9,"speed":0.3]),
        make(90,9,.countTrap,"Не ошибись",nil,10,["objects":16,"time":5])
    ]
    static let chapter10: [Level] = [
        make(91,10,.choice,"Тетрадь","Подпиши или оставь пустой",8,["options":3]),
        make(92,10,.mirrorMatch,"Отражения класса",nil,9,["pairs":12,"time":22]),
        make(93,10,.findOdd,"Один лишний",nil,10,["cols":8,"rows":7,"time":9]),
        make(94,10,.sequence,"Последний звонок",nil,10,["len":10,"speed":0.28]),
        make(95,10,.memoryGrid,"Память школы",nil,10,["cols":6,"rows":6,"cells":10]),
        make(96,10,.lightsOut,"Все свечи",nil,10,["cols":7,"rows":7,"preLit":16]),
        make(97,10,.countTrap,"Финальный счёт",nil,10,["objects":18,"time":5]),
        make(98,10,.choice,"Дверь",nil,10,["options":5]),
        make(99,10,.memoryGrid,"Всё, что помнишь",nil,10,["cols":7,"rows":7,"cells":12]),
        make(100,10,.findOdd,"Последняя парта","Найди себя среди теней",10,["cols":8,"rows":8,"time":8,"final":1])
    ]
}
