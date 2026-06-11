//
//  TodayView.swift
//  Nibble — Sprout Snacks
//
//  Chronological log grouped by meal, running total, swipe-to-delete, and a
//  satisfying tap-to-fill water tracker.
//

import SwiftUI

struct TodayView: View {
    @Environment(AppStore.self) private var store
    @Environment(UIBus.self) private var bus

    private var record: DayRecord { store.dayRecord() }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                ScreenTitle(text: "Today")
                summary
                if record.entries.isEmpty {
                    Text("No entries yet today. Tap ＋ to log your first meal.")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(Theme.inkSoft)
                        .padding(.vertical, 24)
                } else {
                    ForEach(Meal.allCases) { meal in
                        mealGroup(meal)
                    }
                }
                waterCard
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 96)
        }
    }

    private var summary: some View {
        Card {
            VStack(spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(record.total)").font(.system(size: 32, weight: .heavy, design: .rounded)).foregroundStyle(Theme.greenD)
                    Text("kcal").font(.system(size: 18, weight: .semibold, design: .rounded)).foregroundStyle(Theme.ink)
                    if let goal = store.state.goal {
                        Text("/ \(goal)").font(.system(size: 15, design: .rounded)).foregroundStyle(Theme.inkSoft)
                    }
                }
                if store.state.settings.showMacros {
                    Text("\(record.protein)g P · \(record.carbs)g C · \(record.fat)g F")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.inkSoft)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private func mealGroup(_ meal: Meal) -> some View {
        let items = record.entries.filter { $0.meal == meal }.sorted { $0.at < $1.at }
        if !items.isEmpty {
            let sub = items.reduce(0) { $0 + $1.cal }
            Card(padding: 14) {
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        IconChip(symbol: meal.symbol, tint: Color(hex: meal.tintHex), size: 26)
                        Text(meal.label).font(.system(size: 15, weight: .bold, design: .rounded))
                        Spacer()
                        Text("\(sub) kcal").font(.system(size: 13, weight: .semibold, design: .rounded)).foregroundStyle(Theme.inkSoft)
                    }
                    ForEach(items) { entry in
                        EntryRow(entry: entry) {
                            store.removeEntry(entry.id)
                            bus.say("Entry removed.")
                        }
                    }
                }
            }
        }
    }

    private var waterCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    IconChip(symbol: "drop.fill", tint: Theme.drop, size: 26)
                    Text("Water").font(.system(size: 15, weight: .bold, design: .rounded))
                    Spacer()
                    let extra = max(0, record.water - store.state.water.goal)
                    Text("\(record.water)/\(store.state.water.goal) cups\(extra > 0 ? " · +\(extra) extra" : "")")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(extra > 0 ? Theme.gold : Theme.inkSoft)
                }
                let cols = [GridItem(.adaptive(minimum: 40), spacing: 6)]
                LazyVGrid(columns: cols, spacing: 6) {
                    ForEach(0..<store.state.water.goal, id: \.self) { i in
                        let filled = i < record.water
                        Button {
                            let earned = store.setWater(to: i + 1)
                            if earned > 0 { bus.say("+\(earned) Dewdrops") }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(filled ? Color(hex: "E2F4FB") : Color(hex: "F3FAF4"))
                                    .overlay(RoundedRectangle(cornerRadius: 10)
                                        .stroke(filled ? Color(hex: "BFE6F5") : Theme.greenL, lineWidth: 2))
                                Image(systemName: filled ? "drop.fill" : "drop")
                                    .font(.system(size: 15))
                                    .foregroundStyle(filled ? Theme.drop : Color(hex: "C2D4C6"))
                            }
                            .frame(height: 38)
                        }
                        .buttonStyle(.plain)
                    }
                }
                Button {
                    let earned = store.addWater(1)
                    if earned > 0 { bus.say("Sip! +\(earned) Dewdrops") }
                } label: {
                    Label("Add a cup", systemImage: "plus")
                }
                .buttonStyle(GhostButtonStyle())
            }
        }
    }
}

private struct EntryRow: View {
    let entry: FoodEntry
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Text(entry.at, format: .dateTime.hour().minute())
                .font(.system(size: 11, design: .rounded)).foregroundStyle(Theme.inkSoft)
                .frame(width: 58, alignment: .leading)
            Text(entry.name).font(.system(size: 14, weight: .semibold, design: .rounded)).foregroundStyle(Theme.ink)
            Spacer()
            Text("\(entry.cal)").font(.system(size: 14, weight: .bold, design: .rounded)).foregroundStyle(Theme.greenD)
            Button(action: onDelete) {
                Image(systemName: "xmark").font(.system(size: 12, weight: .bold)).foregroundStyle(Color(hex: "C9D4CB")).padding(4)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 5)
    }
}
