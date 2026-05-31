//
//  AppStore.swift
//  Nibble — Sprout Snacks
//
//  Observable single source of truth. Holds SaveState, exposes domain actions,
//  and persists to disk after every mutation. Injected into the SwiftUI
//  environment from NibbleApp.
//
//  Design rule enforced here: the Sprout is never penalised for eating. Rewards
//  flow from logging, hydration and consistency — never from eating less.
//

import Foundation
import Observation

@Observable
final class AppStore {

    var state: SaveState

    /// Bumped whenever the Sprout should visibly react (drives a pop animation).
    var reactionTick: Int = 0
    /// The most recently earned milestone, surfaced as a celebration sheet.
    var pendingCelebration: Milestone? = nil

    private let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    init() {
        if let loaded = Persistence.load() {
            state = loaded
        } else {
            var fresh = SaveState()
            fresh.recent = Array(GameData.starterFoods.prefix(6))
            state = fresh
            Persistence.save(state)
        }
    }

    // MARK: - Date helpers

    func dayKey(_ date: Date = Date()) -> String { dayFormatter.string(from: date) }

    private func dayDiff(_ aKey: String, _ bKey: String) -> Int {
        guard let a = dayFormatter.date(from: aKey),
              let b = dayFormatter.date(from: bKey) else { return 0 }
        let days = Calendar.current.dateComponents([.day], from: a, to: b).day ?? 0
        return days
    }

    private func persist() { Persistence.save(state) }

    // MARK: - Day access

    func dayRecord(_ key: String? = nil) -> DayRecord {
        state.days[key ?? dayKey()] ?? DayRecord()
    }

    func total(for key: String? = nil) -> Int { dayRecord(key).total }

    private func mutateDay(_ key: String? = nil, _ body: (inout DayRecord) -> Void) {
        let k = key ?? dayKey()
        var rec = state.days[k] ?? DayRecord()
        body(&rec)
        state.days[k] = rec
    }

    // MARK: - Mood (derived; never tied to calories)

    var currentMood: Mood {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 22 || hour < 6 { return .sleepy }
        let loggedToday = !dayRecord().entries.isEmpty
        return loggedToday ? .happy : .neutral
    }

    // MARK: - Logging

    @discardableResult
    func addEntry(_ food: Food) -> Int {
        let entry = FoodEntry(name: food.name, cal: food.cal,
                              p: food.p, c: food.c, f: food.f, meal: food.meal)
        mutateDay { $0.entries.append(entry) }

        // Recents (dedupe by name, newest first)
        state.recent.removeAll { $0.name.lowercased() == food.name.lowercased() }
        state.recent.insert(food, at: 0)
        if state.recent.count > 20 { state.recent = Array(state.recent.prefix(20)) }

        // Lifetime stats
        state.stats.totalFoodsLogged += 1
        state.stats.uniqueFoods.insert(food.name.lowercased())

        // Streak + currency
        let wasNewDay = state.streak.lastLogDay != dayKey()
        touchStreak()
        var earned = GameData.Rewards.logMeal
        if wasNewDay { earned += GameData.Rewards.streakDay }
        addDewdrops(earned)

        checkMilestones()
        reactionTick += 1
        persist()
        return earned
    }

    func removeEntry(_ id: String, on key: String? = nil) {
        mutateDay(key) { rec in rec.entries.removeAll { $0.id == id } }
        persist()
    }

    private func touchStreak() {
        let today = dayKey()
        guard state.streak.lastLogDay != today else { return }

        if let last = state.streak.lastLogDay {
            let gap = dayDiff(last, today)
            if gap == 1 {
                state.streak.current += 1
            } else if gap == 2 && state.streak.freezes > 0 {
                // A single missed day is forgiven by a freeze (rest day).
                state.streak.freezes -= 1
                state.streak.current += 1
            } else if gap <= 0 {
                return
            } else {
                state.streak.current = 1   // gentle restart — no penalty
            }
        } else {
            state.streak.current = 1
        }
        state.streak.lastLogDay = today
        state.streak.best = max(state.streak.best, state.streak.current)
    }

    // MARK: - Water

    @discardableResult
    func addWater(_ cups: Int) -> Int {
        var earned = 0
        mutateDay { rec in
            rec.water = max(0, rec.water + cups)
            if cups > 0 { earned += GameData.Rewards.waterCup * cups }
            if !rec.waterRewarded && rec.water >= state.water.goal {
                rec.waterRewarded = true
                earned += GameData.Rewards.waterGoalBonus
                state.stats.waterGoalsHit += 1
            }
        }
        if earned > 0 { addDewdrops(earned) }
        checkMilestones()
        reactionTick += 1
        persist()
        return earned
    }

    /// Set the water level for today to an exact cup count (tap-to-fill).
    @discardableResult
    func setWater(to target: Int) -> Int {
        let current = dayRecord().water
        return addWater(target - current)
    }

    // MARK: - Currency

    func addDewdrops(_ n: Int) { state.dewdrops = max(0, state.dewdrops + n) }

    // MARK: - Favorites

    @discardableResult
    func toggleFavorite(_ food: Food) -> Bool {
        if let i = state.favorites.firstIndex(where: { $0.name.lowercased() == food.name.lowercased() }) {
            state.favorites.remove(at: i)
            persist()
            return false
        }
        state.favorites.insert(food, at: 0)
        persist()
        return true
    }

    func isFavorite(_ name: String) -> Bool {
        state.favorites.contains { $0.name.lowercased() == name.lowercased() }
    }

    // MARK: - Shop

    enum BuyResult { case ok(ShopItem), owned, needPro, insufficient, notFound }

    @discardableResult
    func buy(_ id: String) -> BuyResult {
        guard let item = GameData.item(id) else { return .notFound }
        if state.owned.contains(id) { return .owned }
        if item.pro && !state.pro { return .needPro }
        if state.dewdrops < item.price { return .insufficient }
        state.dewdrops -= item.price
        state.owned.append(id)
        checkMilestones()
        persist()
        return .ok(item)
    }

    func owns(_ id: String) -> Bool { state.owned.contains(id) }

    func equipSkin(_ id: String) {
        guard state.owned.contains(id) else { return }
        state.activeSkin = id
        persist()
    }

    func equipWall(_ id: String?) {
        if let id, !state.owned.contains(id) { return }
        state.activeWall = id
        persist()
    }

    /// Decorations currently placed in the room, keyed by slot.
    func placedDecor() -> [DecorSlot: ShopItem] {
        var out: [DecorSlot: ShopItem] = [:]
        for id in state.owned {
            if let item = GameData.item(id), item.type == .decor, item.slot != .none {
                out[item.slot] = item
            }
        }
        return out
    }

    // MARK: - Milestones

    func checkMilestones() {
        for m in GameData.milestones where !state.earnedMilestones.contains(m.id) {
            if m.check(state) {
                state.earnedMilestones.append(m.id)
                addDewdrops(GameData.Rewards.milestone)
                pendingCelebration = m
            }
        }
    }

    // MARK: - Settings

    func setGoal(_ value: Int?) {
        state.goal = value.map { max(0, $0) }
        persist()
    }
    func setName(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        state.sproutName = String((trimmed.isEmpty ? "Sprout" : trimmed).prefix(16))
        persist()
    }
    func setWaterGoal(_ n: Int) { state.water.goal = max(1, n); persist() }
    func setShowMacros(_ v: Bool) { state.settings.showMacros = v; persist() }
    func setReminders(_ v: Bool) {
        state.settings.remindersOn = v
        persist()
        if v { NotificationManager.scheduleMealReminders() }
        else { NotificationManager.cancelAll() }
    }
    func setPro(_ v: Bool) { state.pro = v; persist() }

    // MARK: - Backup / reset

    func exportSave() -> String { Persistence.encodeString(state) ?? "{}" }

    @discardableResult
    func importSave(_ json: String) -> Bool {
        guard let imported = Persistence.decodeString(json) else { return false }
        state = imported
        persist()
        return true
    }

    func resetAll() {
        Persistence.clear()
        var fresh = SaveState()
        fresh.recent = Array(GameData.starterFoods.prefix(6))
        state = fresh
        persist()
    }

    // MARK: - Stats helpers

    /// Totals for the last `n` days (oldest first).
    func recentDays(_ n: Int = 7) -> [(key: String, date: Date, total: Int, logged: Bool)] {
        var out: [(key: String, date: Date, total: Int, logged: Bool)] = []
        let cal = Calendar.current
        for i in stride(from: n - 1, through: 0, by: -1) {
            guard let d = cal.date(byAdding: .day, value: -i, to: Date()) else { continue }
            let key = dayKey(d)
            let rec = state.days[key]
            out.append((key: key, date: d, total: rec?.total ?? 0, logged: !(rec?.entries.isEmpty ?? true)))
        }
        return out
    }
}
