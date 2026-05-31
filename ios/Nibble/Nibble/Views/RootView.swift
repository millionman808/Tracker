//
//  RootView.swift
//  Nibble — Sprout Snacks
//
//  Shell: top bar (streak + Dewdrops), the active screen, a custom bottom tab
//  bar with a centre "+" to log, a transient toast, and milestone celebrations.
//

import SwiftUI

enum Tab: Hashable { case home, today, log, shop, stats }

// Lightweight environment plumbing so any screen can raise a toast / change tab.
@Observable
final class UIBus {
    var tab: Tab = .home
    var toast: ToastData? = nil
    func say(_ message: String) {
        toast = ToastData(message: message)
        let current = toast?.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) { [weak self] in
            if self?.toast?.id == current { self?.toast = nil }
        }
    }
}

struct RootView: View {
    @Environment(AppStore.self) private var store
    @State private var bus = UIBus()

    var body: some View {
        ZStack(alignment: .bottom) {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                TopBar()
                Group {
                    switch bus.tab {
                    case .home:  HomeView()
                    case .today: TodayView()
                    case .log:   LogView()
                    case .shop:  ShopView()
                    case .stats: StatsView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            TabBar(selection: $bus.tab)

            if let toast = bus.toast {
                ToastView(message: toast.message)
                    .padding(.bottom, 92)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .id(toast.id)
            }
        }
        .environment(bus)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: bus.toast)
        .animation(.easeInOut(duration: 0.2), value: bus.tab)
        .sheet(item: celebrationBinding) { milestone in
            CelebrationSheet(milestone: milestone)
                .presentationDetents([.height(360)])
        }
    }

    // Bridge the store's pendingCelebration to a sheet item binding.
    private var celebrationBinding: Binding<Milestone?> {
        Binding(
            get: { store.pendingCelebration },
            set: { store.pendingCelebration = $0 }
        )
    }
}

// MARK: - Top bar

private struct TopBar: View {
    @Environment(AppStore.self) private var store
    var body: some View {
        HStack {
            Pill { Text("🔥"); Text("\(store.state.streak.current)") }
            Spacer()
            Text("Nibble")
                .font(.system(size: 17, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.greenD)
                .tracking(0.5)
            Spacer()
            Pill { Text("💧"); Text("\(store.state.dewdrops)") }
        }
        .padding(.horizontal, 18)
        .padding(.top, 6)
        .padding(.bottom, 8)
    }

    private struct Pill<C: View>: View {
        @ViewBuilder var content: () -> C
        var body: some View {
            HStack(spacing: 5) { content() }
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.ink)
                .padding(.vertical, 6).padding(.horizontal, 11)
                .background(Capsule().fill(Theme.card))
                .shadow(color: Theme.cardShadow, radius: 6, y: 2)
        }
    }
}

// MARK: - Bottom tab bar

private struct TabBar: View {
    @Binding var selection: Tab
    var body: some View {
        HStack(alignment: .bottom) {
            item(.home, "house.fill", "Home")
            item(.today, "list.bullet.clipboard.fill", "Today")
            centerButton
            item(.shop, "bag.fill", "Shop")
            item(.stats, "chart.bar.fill", "Stats")
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
        .padding(.horizontal, 8)
        .background(
            Theme.card.opacity(0.97)
                .overlay(Rectangle().frame(height: 1).foregroundStyle(Color(hex: "E7F0E8")), alignment: .top)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func item(_ tab: Tab, _ symbol: String, _ label: String) -> some View {
        Button {
            selection = tab
        } label: {
            VStack(spacing: 3) {
                Image(systemName: symbol)
                    .font(.system(size: 19))
                    .scaleEffect(selection == tab ? 1.1 : 1)
                Text(label).font(.system(size: 10, weight: .bold, design: .rounded))
            }
            .foregroundStyle(selection == tab ? Theme.greenD : Theme.inkSoft)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selection)
    }

    private var centerButton: some View {
        Button {
            selection = .log
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(
                    Circle().fill(LinearGradient(colors: [Theme.green, Theme.greenD],
                                                 startPoint: .topLeading, endPoint: .bottomTrailing))
                )
                .shadow(color: Theme.green.opacity(0.45), radius: 10, y: 4)
        }
        .buttonStyle(.plain)
        .offset(y: -16)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Celebration sheet

struct CelebrationSheet: View {
    let milestone: Milestone
    @Environment(\.dismiss) private var dismiss
    @State private var bounce = false

    var body: some View {
        VStack(spacing: 12) {
            Text(milestone.icon)
                .font(.system(size: 64))
                .offset(y: bounce ? -8 : 0)
                .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: bounce)
            Text("Milestone!").font(.system(size: 22, weight: .heavy, design: .rounded))
            Text(milestone.label)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.greenD)
            Text(milestone.desc)
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(Theme.inkSoft)
                .multilineTextAlignment(.center)
            Text("+\(GameData.Rewards.milestone) 💧 Dewdrops")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.drop)
            Button("Yay!") { dismiss() }
                .buttonStyle(PrimaryButtonStyle(big: true))
                .padding(.top, 6)
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(Theme.bg)
        .onAppear { bounce = true }
    }
}
