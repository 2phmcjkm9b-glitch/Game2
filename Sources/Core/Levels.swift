import Foundation

enum Levels {
    // Only these six remain in the optional 100-trial archive.
    static let archive: [Level] = [
        make(12, 2, .memoryGrid, "След", "Запомни клетки", 5, ["cols": 4, "rows": 4, "cells": 5, "show": 1.0]),
        make(21, 3, .mirrorMatch, "Отражение", "Найди пару", 6, ["pairs": 8, "time": 24]),
        make(44, 5, .wordChain, "Два слова", "Собери слово", 7, ["len": 7]),
        make(51, 6, .choice, "Три двери", "Найди единственное чётное число", 7, ["options": 3]),
        make(52, 6, .choice, "Развилка", "Найди единственное простое число", 8, ["options": 5]),
        make(97, 10, .countTrap, "Финальный счёт", "Посчитай все огни", 10, ["objects": 24, "time": 8])
    ]

    // Main-story versions of the six selected archive trials.
    static let migrated: [Trial: Level] = [
        .archiveMemory: make(12, 2, .memoryGrid, "След", "Запомни исчезающие клетки", 5, ["cols": 4, "rows": 4, "cells": 5, "show": 1.0]),
        .archiveMirror: make(21, 3, .mirrorMatch, "Отражение", "Найди пару среди отражений", 6, ["pairs": 8, "time": 24]),
        .archiveWord: make(44, 5, .wordChain, "Два слова", "Собери слово по порядку", 7, ["len": 7]),
        .archiveChoice: make(51, 6, .choice, "Три двери", "Найди единственное чётное число", 7, ["options": 3]),
        .archiveBranch: make(52, 6, .choice, "Развилка", "Найди единственное простое число", 8, ["options": 5]),
        .archiveCount: make(97, 10, .countTrap, "Финальный счёт", "Посчитай все огни", 10, ["objects": 24, "time": 8])
    ]

    static let all: [Level] = migrated.values.sorted { $0.id < $1.id }

    private static func make(_ id: Int, _ chapter: Int, _ type: LevelType, _ title: String, _ hint: String?, _ difficulty: Int, _ params: [String: Double] = [:]) -> Level {
        Level(id: id, chapter: chapter, type: type, title: title, hint: hint, difficulty: difficulty, params: params)
    }
}
