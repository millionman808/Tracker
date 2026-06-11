//
//  Models.swift
//  Nibble — Sprout Snacks
//
//  Core data types. Everything that needs to persist is Codable and lives in
//  SaveState, which the AppStore serialises to disk as JSON.
//

import Foundation

// MARK: - Meals

enum Meal: String, Codable, CaseIterable, Identifiable {
    case breakfast, lunch, dinner, snack
    var id: String { rawValue }

    var label: String {
        switch self {
        case .breakfast: return "Breakfast"
        case .lunch:     return "Lunch"
        case .dinner:    return "Dinner"
        case .snack:     return "Snack"
        }
    }

    /// SF Symbol for this meal.
    var symbol: String {
        switch self {
        case .breakfast: return "sun.horizon.fill"
        case .lunch:     return "takeoutbag.and.cup.and.straw.fill"
        case .dinner:    return "fork.knife"
        case .snack:     return "carrot.fill"
        }
    }

    /// Tint hex for this meal's icon chip.
    var tintHex: String {
        switch self {
        case .breakfast: return "F4A259"
        case .lunch:     return "5FA8D3"
        case .dinner:    return "9B7CD4"
        case .snack:     return "E76F51"
        }
    }

    /// Sensible default meal based on the time of day.
    static func suggested(for date: Date = Date()) -> Meal {
        let h = Calendar.current.component(.hour, from: date)
        switch h {
        case ..<11:  return .breakfast
        case ..<15:  return .lunch
        case ..<21:  return .dinner
        default:     return .snack
        }
    }
}

// MARK: - Food

/// A reusable food template (used for recents & favorites).
struct Food: Codable, Hashable, Identifiable {
    var id: String { name.lowercased() }
    var name: String
    var cal: Int
    var p: Int = 0
    var c: Int = 0
    var f: Int = 0
    var meal: Meal = .snack
}

/// A concrete logged entry for a given day.
struct FoodEntry: Codable, Identifiable, Hashable {
    var id: String = UUID().uuidString
    var name: String
    var cal: Int
    var p: Int = 0
    var c: Int = 0
    var f: Int = 0
    var meal: Meal = .snack
    var at: Date = Date()
}

// MARK: - Day record

struct DayRecord: Codable {
    var entries: [FoodEntry] = []
    var water: Int = 0
    var waterRewarded: Bool = false

    var total: Int { entries.reduce(0) { $0 + $1.cal } }
    var protein: Int { entries.reduce(0) { $0 + $1.p } }
    var carbs: Int { entries.reduce(0) { $0 + $1.c } }
    var fat: Int { entries.reduce(0) { $0 + $1.f } }
}

// MARK: - Shop

enum ShopItemType: String, Codable {
    case skin, wallpaper, decor
}

/// Where a decoration sits in the Sprout's room.
enum DecorSlot: String, Codable {
    case shelf, floorLeft, floorRight, rug, none
}

struct ShopItem: Identifiable, Hashable {
    let id: String
    let type: ShopItemType
    let name: String
    let price: Int
    let theme: String
    let desc: String
    var emoji: String = ""
    var colorHex: String? = nil   // wallpapers
    var pro: Bool = false
    var slot: DecorSlot = .none
}

struct ShopTheme: Identifiable, Hashable {
    let id: String
    let label: String
}

// MARK: - Milestones

struct Milestone: Identifiable {
    let id: String
    let label: String
    let icon: String        // SF Symbol name
    let tintHex: String     // chip color
    let desc: String
    /// Returns true when this milestone has been achieved for the given state.
    let check: (SaveState) -> Bool
}

// MARK: - Sub-state structs

struct Streak: Codable {
    var current: Int = 0
    var best: Int = 0
    var lastLogDay: String? = nil   // "yyyy-MM-dd"
    var freezes: Int = 1
}

struct WaterConfig: Codable {
    var goal: Int = 8
}

struct AppSettings: Codable {
    var remindersOn: Bool = false
    var showMacros: Bool = false
}

struct LifetimeStats: Codable {
    var totalFoodsLogged: Int = 0
    var waterGoalsHit: Int = 0
    var uniqueFoods: Set<String> = []
}

// MARK: - Companion mood

enum Mood: String {
    case neutral, happy, eating, sleepy, celebrating

    var word: String {
        switch self {
        case .happy:       return "happy"
        case .neutral:     return "content"
        case .sleepy:      return "sleepy"
        case .eating:      return "nibbling"
        case .celebrating: return "thrilled"
        }
    }
}

// MARK: - Persisted save state

struct SaveState: Codable {
    var createdAt: Date = Date()
    var dewdrops: Int = 25
    var goal: Int? = nil               // nil == goal-free mode
    var sproutName: String = "Sprout"
    var activeSkin: String = "skin_sprout"
    var activeWall: String? = nil
    var owned: [String] = ["skin_sprout"]
    var pro: Bool = false
    var water = WaterConfig()
    var streak = Streak()
    var settings = AppSettings()
    var days: [String: DayRecord] = [:]
    var recent: [Food] = []
    var favorites: [Food] = []
    var earnedMilestones: [String] = []
    var stats = LifetimeStats()
}
