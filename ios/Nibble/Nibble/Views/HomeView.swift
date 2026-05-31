//
//  HomeView.swift
//  Nibble — Sprout Snacks
//
//  The centerpiece: the Sprout in its decorated room, a gentle progress element
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

        return ZStack {
            // wall + floor
            VStack(spacing: 0) {
                wall
                LinearGradient(colors: [Color(hex: "EFE2CF"), Color(hex: "E7D6BD")],
                               startPoint: .top, endPoint: .bottom)
                    .frame(height: 106)
            }

            // decorations
            if let d = decor[.shelf] {
                Text(d.emoji).font(.system(size: 30)).position(x: 250, y: 34)
            }
            if let d = decor[.rug] {
                Text(d.emoji).font(.system(size: 58)).opacity(0.9).position(x: 160, y: 252)
            }
            if let d = decor[.floorLeft] {
                Text(d.emoji).font(.system(size: 34)).position(x: 48, y: 232)
            }
            if let d = decor[.floorRight] {
                Text(d.emoji).font(.system(size: 34)).position(x: 272, y: 232)
            }

            // the Sprout
            VStack {
                Spacer()
                SproutView(skinID: store.state.activeSkin, mood: store.currentMood, size: 168)
                    .id(store.reactionTick) // re-trigger pulse on log
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
                .padding(.vertical, 3).padding(.horizontal, 12)
                .background(Capsule().fill(.white.opacity(0.7)))
                .padding(.bottom, 8)
            }
        }
        .frame(height: 280)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Theme.cardShadow, radius: 10, y: 4)
    }

    // MARK: Progress

    private var progressCard: some View {
        let total = store.total()
        return Card {
            if let goal = store.state.goal {
                let pct = goal > 0 ? min(1, Double(total) / Double(goal)) : 0
                VStack(spacing: 10) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("\(total)").font(.system(size: 34, weight: .heavy, design: .rounded)).foregroundStyle(Theme.greenD)
                        Text("of \(goal) kcal").font(.system(size: 15, weight: .semibold, design: .rounded)).foregroundStyle(Theme.inkSoft)
                    }
                    WateringCan(progress: pct)
                    Text(total > goal
                         ? "You've passed your goal — and that's completely okay. 🌿"
                         : "Filling up nicely. No pressure, just logging.")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(Theme.inkSoft)
                        .multilineTextAlignment(.center)
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
        Card(padding: 14) {
            HStack {
                Text("💧 Water · \(store.dayRecord().water)/\(store.state.water.goal) cups")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
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

// MARK: - Watering-can progress

private struct WateringCan: View {
    var progress: Double
    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "EEF6F0"))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.greenL, lineWidth: 2))
            RoundedRectangle(cornerRadius: 14)
                .fill(LinearGradient(colors: [Color(hex: "9BD9A0"), Theme.green], startPoint: .top, endPoint: .bottom))
                .frame(height: CGFloat(70 * progress))
                .padding(2)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
            Text("🌱").font(.system(size: 20)).offset(y: -48)
        }
        .frame(width: 70, height: 70)
    }
}
