//
//  StatsView.swift
//  Nibble — Sprout Snacks
//
//  The streak is the hero. A calm 7-day chart, lifetime totals and badges.
//  Deliberately not weight-focused — we celebrate the habit.
//

import SwiftUI

struct StatsView: View {
    @Environment(AppStore.self) private var store
    @State private var showSettings = false

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                ScreenTitle(text: "Progress")
                streakHero
                weekChart
                lifetime
                badges
                Button("⚙️ Settings") { showSettings = true }
                    .buttonStyle(GhostButtonStyle(big: true))
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 96)
        }
        .sheet(isPresented: $showSettings) { SettingsView().environment(store) }
    }

    private var streakHero: some View {
        VStack(spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(store.state.streak.current)").font(.system(size: 48, weight: .heavy, design: .rounded))
                Text("🔥").font(.system(size: 26))
            }
            Text("day logging streak").font(.system(size: 15, weight: .bold, design: .rounded))
            Text("Best: \(store.state.streak.best) · Streak freezes left: \(store.state.streak.freezes)")
                .font(.system(size: 12, design: .rounded)).opacity(0.9)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: Theme.radius, style: .continuous)
                .fill(LinearGradient(colors: [Theme.green, Theme.greenD], startPoint: .topLeading, endPoint: .bottomTrailing))
        )
        .shadow(color: Theme.green.opacity(0.3), radius: 10, y: 4)
    }

    private var weekChart: some View {
        let days = store.recentDays(7)
        let maxTotal = max(1, days.map(\.total).max() ?? 1)
        let avg = days.isEmpty ? 0 : days.reduce(0) { $0 + $1.total } / days.count
        return Card {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Last 7 days").font(.system(size: 15, weight: .bold, design: .rounded))
                    Spacer()
                    Text("avg \(avg) kcal").font(.system(size: 13, weight: .semibold, design: .rounded)).foregroundStyle(Theme.inkSoft)
                }
                HStack(alignment: .bottom, spacing: 6) {
                    ForEach(days, id: \.key) { day in
                        VStack(spacing: 6) {
                            GeometryReader { geo in
                                VStack {
                                    Spacer(minLength: 0)
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(day.logged
                                              ? AnyShapeStyle(LinearGradient(colors: [Color(hex: "9BD9A0"), Theme.green], startPoint: .top, endPoint: .bottom))
                                              : AnyShapeStyle(Color(hex: "E6EFE7")))
                                        .frame(height: max(4, geo.size.height * CGFloat(day.total) / CGFloat(maxTotal)))
                                }
                            }
                            .frame(height: 90)
                            Text(weekdayLetter(day.date)).font(.system(size: 11, weight: .semibold, design: .rounded)).foregroundStyle(Theme.inkSoft)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                Text("We celebrate the habit, not a number on a scale. 🌿")
                    .font(.system(size: 12, design: .rounded)).foregroundStyle(Theme.inkSoft)
            }
        }
    }

    private var lifetime: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                Text("Lifetime").font(.system(size: 15, weight: .bold, design: .rounded))
                let cols = [GridItem(.flexible()), GridItem(.flexible())]
                LazyVGrid(columns: cols, spacing: 12) {
                    stat("\(store.state.stats.totalFoodsLogged)", "foods logged")
                    stat("\(store.state.stats.uniqueFoods.count)", "unique foods")
                    stat("\(store.state.stats.waterGoalsHit)", "water goals hit")
                    stat("\(store.state.owned.count)", "things owned")
                }
            }
        }
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.system(size: 24, weight: .heavy, design: .rounded)).foregroundStyle(Theme.greenD)
            Text(label).font(.system(size: 12, design: .rounded)).foregroundStyle(Theme.inkSoft)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: Theme.radiusSm).fill(Color(hex: "F3FAF4")))
    }

    private var badges: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                Text("Badges").font(.system(size: 15, weight: .bold, design: .rounded))
                let cols = [GridItem(.adaptive(minimum: 78), spacing: 10)]
                LazyVGrid(columns: cols, spacing: 10) {
                    ForEach(GameData.milestones) { m in
                        let earned = store.state.earnedMilestones.contains(m.id)
                        VStack(spacing: 4) {
                            Text(earned ? m.icon : "🔒").font(.system(size: 26))
                            Text(m.label).font(.system(size: 10.5, weight: .bold, design: .rounded))
                                .foregroundStyle(Theme.inkSoft).multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10).padding(.horizontal, 4)
                        .background(RoundedRectangle(cornerRadius: Theme.radiusSm)
                            .fill(earned ? Color(hex: "FFF7E0") : Color(hex: "F3FAF4")))
                        .overlay(RoundedRectangle(cornerRadius: Theme.radiusSm)
                            .stroke(earned ? Theme.gold : .clear, lineWidth: 1.5))
                        .opacity(earned ? 1 : 0.55)
                    }
                }
            }
        }
    }

    private func weekdayLetter(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "EEE"
        return String(f.string(from: date).prefix(1))
    }
}
