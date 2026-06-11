//
//  HomeView.swift
//  Nibble — Sprout Snacks
//
//  The centerpiece: the Sprout in its decorated room, a gentle progress ring
//  toward an optional goal (never a red "over limit" warning), quick-add, and a
//  one-tap water cup.
//

import SwiftUI

struct HomeView: View {
    @Environment(AppStore.self) private var store
    @Environment(UIBus.self) private var bus

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                room
                progressCard
                Button {
                    bus.tab = .log
                } label: { Text("＋ Log food") }
                .buttonStyle(PrimaryButtonStyle(big: true))

                waterRow
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 96)
        }
    }

    // MARK: Room

    private var room: some View {
        let decor = store.placedDecor()
        let wall = store.state.activeWall.flatMap { GameData.item($0)?.colorHex }.map { Color(hex: $0) }
            ?? Color(hex: "E9F7EC")
        let hour = Calendar.current.component(.hour, from: Date())
        let isNight = hour >= 20 || hour < 6

        return ZStack {
            // wall with soft vertical depth + floor
            VStack(spacing: 0) {
                LinearGradient(colors: [wall.opacity(0.65), wall],
                               startPoint: .top, endPoint: .bottom)
                // baseboard
                Rectangle().fill(Color.white.opacity(0.55)).frame(height: 7)
                LinearGradient(colors: [Color(hex: "EFE2CF"), Color(hex: "E7D6BD")],
                               startPoint: .top, endPoint: .bottom)
                    .frame(height: 100)
            }

            // window with day/night sky
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(LinearGradient(
                    colors: isNight
                        ? [Color(hex: "2B3A5C"), Color(hex: "4A5E8A")]
                        : [Color(hex: "BFE3FF"), Color(hex: "E8F6FF")],
                    startPoint: .top, endPoint: .bottom))
                .frame(width: 84, height: 64)
                .overlay(
                    Text(isNight ? "🌙" : "☀️").font(.system(size: 20))
                        .offset(x: 18, y: -12)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(0.85), lineWidth: 5)
                )
                .overlay(Rectangle().fill(Color.white.opacity(0.85)).frame(width: 4))
                .overlay(Rectangle().fill(Color.white.opacity(0.85)).frame(height: 4))
                .position(x: 70, y: 60)

            // decorations
            if let d = decor[.shelf] {
                // a little shelf under the item
                VStack(spacing: 2) {
                    Text(d.emoji).font(.system(size: 30))
                    Capsule().fill(Color(hex: "C9A87C")).frame(width: 54, height: 6)
                }
                .position(x: 252, y: 48)
            }
            if let d = decor[.rug] {
                Text(d.emoji).font(.system(size: 58)).opacity(0.9).position(x: 160, y: 252)
            }
            if let d = decor[.floorLeft] {
                Text(d.emoji).font(.system(size: 34)).position(x: 48, y: 230)
            }
            if let d = decor[.floorRight] {
                Text(d.emoji).font(.system(size: 34)).position(x: 272, y: 230)
            }

            // the Sprout
            VStack {
                Spacer()
                SproutView(skinID: store.state.activeSkin, mood: store.currentMood, size: 168)
                    .id(store.reactionTick)
            }
            .padding(.bottom, 14)

            // nameplate
            VStack {
                Spacer()
                HStack(spacing: 4) {
                    Text(store.state.sproutName).fontWeight(.bold)
                    Text("· \(store.currentMood.word)").foregroundStyle(Theme.greenD)
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.ink)
                .padding(.vertical, 4).padding(.horizontal, 13)
                .background(Capsule().fill(.white.opacity(0.78)))
                .padding(.bottom, 8)
            }
        }
        .frame(height: 290)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Theme.cardShadow, radius: 12, y: 5)
    }

    // MARK: Progress

    private var progressCard: some View {
        let total = store.total()
        return Card {
            if let goal = store.state.goal {
                let pct = goal > 0 ? min(1, Double(total) / Double(goal)) : 0
                HStack(spacing: 18) {
                    GrowthRing(progress: pct)
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Text("\(total)")
                                .font(.system(size: 32, weight: .heavy, design: .rounded))
                                .foregroundStyle(Theme.greenD)
                            Text("/ \(goal) kcal")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(Theme.inkSoft)
                        }
                        Text(total > goal
                             ? "You've passed your goal — and that's completely okay. 🌿"
                             : "Filling up nicely. No pressure, just logging.")
                            .font(.system(size: 12.5, design: .rounded))
                            .foregroundStyle(Theme.inkSoft)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                }
            } else {
                VStack(spacing: 8) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("\(total)").font(.system(size: 34, weight: .heavy, design: .rounded)).foregroundStyle(Theme.greenD)
                        Text("kcal today").font(.system(size: 15, weight: .semibold, design: .rounded)).foregroundStyle(Theme.inkSoft)
                    }
                    Text("Goal-free mode. You're tracking for awareness, not limits. 🌱")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(Theme.inkSoft)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }

    // MARK: Water

    private var waterRow: some View {
        let cups = store.dayRecord().water
        let goal = store.state.water.goal
        return Card(padding: 14) {
            HStack(spacing: 10) {
                Text("💧").font(.system(size: 18))
                VStack(alignment: .leading, spacing: 5) {
                    Text("Water · \(cups)/\(goal) cups")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                    // mini cup dots
                    HStack(spacing: 4) {
                        ForEach(0..<min(goal, 12), id: \.self) { i in
                            Circle()
                                .fill(i < cups ? Theme.drop : Color(hex: "E3EFE4"))
                                .frame(width: 9, height: 9)
                        }
                    }
                }
                Spacer()
                Button("Add a cup") {
                    let earned = store.addWater(1)
                    bus.say("Sip! +\(earned) 💧")
                }
                .buttonStyle(GhostButtonStyle())
            }
        }
    }
}

// MARK: - Growth ring progress

private struct GrowthRing: View {
    var progress: Double
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(hex: "EEF6F0"), lineWidth: 10)
            Circle()
                .trim(from: 0, to: CGFloat(max(0.001, progress)))
                .stroke(
                    AngularGradient(colors: [Color(hex: "9BD9A0"), Theme.green, Theme.greenD],
                                    center: .center,
                                    startAngle: .degrees(0), endAngle: .degrees(360)),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
            Text("🌱").font(.system(size: 24))
        }
        .frame(width: 76, height: 76)
    }
}
