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
                } label: {
                    Label("Log food", systemImage: "plus")
                }
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
            RoomBackdrop(wall: wall, night: isNight)

            // decorations (drawn vector art with soft contact shadows)
            if let d = decor[.shelf] {
                VStack(spacing: 0) {
                    DecorArt(id: d.id, size: 46)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(hex: "C9A87C").gradient)
                        .frame(width: 62, height: 7)
                    Rectangle().fill(Color.black.opacity(0.08)).frame(width: 62, height: 3).blur(radius: 2)
                }
                .position(x: 254, y: 56)
            }
            if let d = decor[.rug] {
                DecorArt(id: d.id, size: 96).position(x: 160, y: 248)
            }
            if let d = decor[.floorLeft] {
                placedOnFloor(d, x: 46)
            }
            if let d = decor[.floorRight] {
                placedOnFloor(d, x: 274)
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
                .background(Capsule().fill(.white.opacity(0.8)))
                .padding(.bottom, 8)
            }
        }
        .frame(height: 290)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Theme.cardShadow, radius: 12, y: 5)
    }

    private func placedOnFloor(_ item: ShopItem, x: CGFloat) -> some View {
        ZStack {
            Ellipse().fill(Color.black.opacity(0.10))
                .frame(width: 52, height: 12)
                .blur(radius: 2)
                .offset(y: 26)
            DecorArt(id: item.id, size: 58)
        }
        .position(x: x, y: 222)
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
                             ? "You've passed your goal — and that's completely okay."
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
                    Text("Goal-free mode. You're tracking for awareness, not limits.")
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
            HStack(spacing: 12) {
                IconChip(symbol: "drop.fill", tint: Theme.drop, size: 34)
                VStack(alignment: .leading, spacing: 5) {
                    Text("Water · \(cups)/\(goal) cups")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
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
                    bus.say("Sip! +\(earned) Dewdrops")
                }
                .buttonStyle(GhostButtonStyle())
            }
        }
    }
}

// MARK: - Room backdrop (wall, molding, window, plank floor)

private struct RoomBackdrop: View {
    let wall: Color
    let night: Bool

    var body: some View {
        ZStack {
            // wall with soft vertical light
            VStack(spacing: 0) {
                LinearGradient(colors: [wall.opacity(0.62), wall],
                               startPoint: .top, endPoint: .bottom)
                // baseboard
                Rectangle().fill(Color.white.opacity(0.7)).frame(height: 8)
                Rectangle().fill(Color.black.opacity(0.06)).frame(height: 2)
                // plank floor
                floor.frame(height: 92)
            }

            // crown molding
            VStack {
                Rectangle().fill(Color.white.opacity(0.5)).frame(height: 5)
                Spacer()
            }

            window.position(x: 70, y: 62)
        }
    }

    private var floor: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "E8D5B8"), Color(hex: "D9C19D")],
                           startPoint: .top, endPoint: .bottom)
            // plank seams
            HStack(spacing: 0) {
                ForEach(0..<8, id: \.self) { _ in
                    Rectangle().fill(.clear)
                    Rectangle().fill(Color(hex: "C9AE87")).frame(width: 2)
                }
            }
            // horizontal seam
            VStack {
                Spacer()
                Rectangle().fill(Color(hex: "C9AE87")).frame(height: 2)
                Spacer().frame(height: 30)
            }
            // sheen
            LinearGradient(colors: [Color.white.opacity(0.14), .clear],
                           startPoint: .top, endPoint: .bottom)
        }
    }

    private var window: some View {
        ZStack {
            // sky
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(LinearGradient(
                    colors: night
                        ? [Color(hex: "2B3A5C"), Color(hex: "4A5E8A")]
                        : [Color(hex: "A8D8FF"), Color(hex: "E2F3FF")],
                    startPoint: .top, endPoint: .bottom))
                .frame(width: 86, height: 68)

            if night {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 17))
                    .foregroundStyle(Color(hex: "FFE08A"))
                    .offset(x: 16, y: -14)
                Circle().fill(.white.opacity(0.9)).frame(width: 2.5).offset(x: -20, y: -8)
                Circle().fill(.white.opacity(0.7)).frame(width: 2).offset(x: -8, y: 12)
            } else {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color(hex: "F4C542"))
                    .offset(x: 16, y: -14)
                Image(systemName: "cloud.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.9))
                    .offset(x: -16, y: 8)
            }

            // panes + frame
            Rectangle().fill(.white).frame(width: 5, height: 68)
            Rectangle().fill(.white).frame(width: 86, height: 5)
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(.white, lineWidth: 7)
                .frame(width: 86, height: 68)
            // sill
            RoundedRectangle(cornerRadius: 3)
                .fill(.white)
                .frame(width: 98, height: 7)
                .offset(y: 38)
                .shadow(color: .black.opacity(0.10), radius: 2, y: 2)
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
            Image(systemName: "leaf.fill")
                .font(.system(size: 22))
                .foregroundStyle(Theme.green.gradient)
        }
        .frame(width: 76, height: 76)
    }
}
