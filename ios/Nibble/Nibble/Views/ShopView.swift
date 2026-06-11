//
//  ShopView.swift
//  Nibble — Sprout Snacks
//
//  Spend Dewdrops on skins, wallpapers and themed decorations. Preview-before-
//  buy for skins. A mock Pro unlock gates a few cosmetics — never any tracking.
//

import SwiftUI

struct ShopView: View {
    @Environment(AppStore.self) private var store
    @Environment(UIBus.self) private var bus

    @State private var theme = "skins"
    @State private var previewSkin: ShopItem? = nil

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    private var items: [ShopItem] { GameData.shop.filter { $0.theme == theme } }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ScreenTitle(text: "Shop & Decorate")

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(GameData.shopThemes) { t in
                            SubTab(title: t.label, active: theme == t.id) { theme = t.id }
                        }
                    }
                    .padding(.horizontal, 2)
                }

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(items) { item in
                        ShopCard(item: item,
                                 onPreview: { if item.type == .skin { previewSkin = item } },
                                 onBuy: { buy(item) },
                                 onEquip: { equip(item) })
                    }
                }

                if !store.state.pro {
                    Button {
                        store.setPro(true)
                        bus.say("Pro unlocked (demo mode)")
                    } label: {
                        Label("Unlock Pro (demo)", systemImage: "sparkles")
                    }
                    .buttonStyle(ProButtonStyle(big: true))
                } else {
                    Label("Pro is active — enjoy your perks!", systemImage: "sparkles")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.proB)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 96)
        }
        .sheet(item: $previewSkin) { item in
            SkinPreviewSheet(item: item)
                .environment(store)
                .environment(bus)
                .presentationDetents([.height(420)])
        }
    }

    private func buy(_ item: ShopItem) {
        switch store.buy(item.id) {
        case .ok(let bought):     bus.say("Got it: \(bought.name)!")
        case .insufficient:       bus.say("Not enough Dewdrops yet — keep logging!")
        case .needPro:            bus.say("That's a Pro item")
        case .owned, .notFound:   break
        }
    }

    private func equip(_ item: ShopItem) {
        if item.type == .skin { store.equipSkin(item.id) }
        else if item.type == .wallpaper { store.equipWall(item.id) }
        bus.say("Equipped!")
    }
}

// MARK: - Shop card

private struct ShopCard: View {
    @Environment(AppStore.self) private var store
    let item: ShopItem
    let onPreview: () -> Void
    let onBuy: () -> Void
    let onEquip: () -> Void

    private var owned: Bool { store.owns(item.id) }
    private var equipped: Bool {
        (item.type == .skin && store.state.activeSkin == item.id) ||
        (item.type == .wallpaper && store.state.activeWall == item.id)
    }
    private var locked: Bool { item.pro && !store.state.pro }

    var body: some View {
        VStack(spacing: 6) {
            Button(action: onPreview) {
                preview.frame(height: 70).frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .disabled(item.type != .skin)

            HStack(spacing: 4) {
                Text(item.name).font(.system(size: 14, weight: .bold, design: .rounded)).foregroundStyle(Theme.ink)
                if item.pro { ProTag() }
            }
            Text(item.desc)
                .font(.system(size: 11.5, design: .rounded))
                .foregroundStyle(Theme.inkSoft)
                .multilineTextAlignment(.center)
                .frame(minHeight: 30)

            action
        }
        .padding(.vertical, 14).padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.radius, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Theme.radius).stroke(equipped ? Theme.green : .clear, lineWidth: 2))
        .shadow(color: Theme.cardShadow, radius: 6, y: 2)
    }

    @ViewBuilder private var preview: some View {
        switch item.type {
        case .skin:
            SproutView(skinID: item.id, mood: .happy, size: 64, animated: false)
        case .wallpaper:
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(hex: item.colorHex ?? "FFFFFF"))
                .frame(width: 54, height: 54)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(.black.opacity(0.06), lineWidth: 2))
        case .decor:
            DecorArt(id: item.id, size: 60)
        }
    }

    @ViewBuilder private var action: some View {
        if equipped {
            Text("Equipped ✓").font(.system(size: 13, weight: .bold, design: .rounded)).foregroundStyle(Theme.greenD)
        } else if owned && (item.type == .skin || item.type == .wallpaper) {
            Button("Equip", action: onEquip).buttonStyle(PrimaryButtonStyle())
        } else if owned {
            Text("Owned ✓").font(.system(size: 13, weight: .bold, design: .rounded)).foregroundStyle(Theme.greenD)
        } else if locked {
            Button {} label: { Label("Pro", systemImage: "lock.fill") }
                .buttonStyle(ProButtonStyle()).disabled(true).opacity(0.9)
        } else {
            let affordable = store.state.dewdrops >= item.price
            Button(action: onBuy) {
                Label("\(item.price)", systemImage: "drop.fill")
            }
            .buttonStyle(PrimaryButtonStyle(enabled: affordable))
        }
    }
}

struct ProTag: View {
    var body: some View {
        Text("PRO")
            .font(.system(size: 8, weight: .heavy, design: .rounded))
            .foregroundStyle(.white)
            .padding(.vertical, 2).padding(.horizontal, 5)
            .background(Capsule().fill(LinearGradient(colors: [Theme.proA, Theme.proB], startPoint: .leading, endPoint: .trailing)))
    }
}

// MARK: - Skin preview sheet

private struct SkinPreviewSheet: View {
    @Environment(AppStore.self) private var store
    @Environment(UIBus.self) private var bus
    @Environment(\.dismiss) private var dismiss
    let item: ShopItem

    private var owned: Bool { store.owns(item.id) }
    private var locked: Bool { item.pro && !store.state.pro }

    var body: some View {
        VStack(spacing: 14) {
            Text("Preview · \(item.name)").font(.system(size: 18, weight: .heavy, design: .rounded))
            SproutView(skinID: item.id, mood: .happy, size: 150)
            Text(item.desc).font(.system(size: 14, design: .rounded)).foregroundStyle(Theme.inkSoft)

            if owned {
                Button("Equip") { store.equipSkin(item.id); bus.say("Equipped!"); dismiss() }
                    .buttonStyle(PrimaryButtonStyle(big: true))
            } else if locked {
                Button {} label: { Label("Pro item", systemImage: "lock.fill") }
                    .buttonStyle(ProButtonStyle(big: true)).disabled(true)
            } else {
                Button {
                    if case .ok(let bought) = store.buy(item.id) {
                        store.equipSkin(item.id)
                        bus.say("Got \(bought.name)!")
                        dismiss()
                    } else {
                        bus.say("Not enough Dewdrops yet")
                    }
                } label: {
                    Label("Buy · \(item.price)", systemImage: "drop.fill")
                }
                .buttonStyle(PrimaryButtonStyle(big: true, enabled: store.state.dewdrops >= item.price))
            }
            Button("Close") { dismiss() }.buttonStyle(GhostButtonStyle(big: true))
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Theme.bg)
    }
}
